# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Create a distributable wheel from the pre-built cefpython3/ package directory.

Packaging workflow (current):
    This script performs only the final packaging step. The full pipeline is
    driven by the CI workflows (.github/workflows/ci-*.yml):
      1. tools/download_cef.py            - fetch the CEF binary distribution.
      2. tools/automate.py --prebuilt-cef - lay out CEF_ROOT for the build.
      3. CMake build                      - compile cefpython_py<XY>.{so,pyd}
                                            and the subprocess helper(s).
      4. stage into cefpython3/           - copy the compiled module, the
                                            platform subprocess artifact(s)
                                            and CEF runtime files next to
                                            __init__.py. macOS uses five
                                            process-specific Helper.app bundles.
      5. build_distrib.py (this script)   - zip cefpython3/ into a PEP 427 wheel
                                            with a generated .dist-info
                                            (METADATA, WHEEL, top_level.txt,
                                            RECORD). No compilation happens here.
                                            On Linux, libcef.so is stripped of
                                            debug symbols first (Issue #262; it
                                            ships ~1.3 GB with them). On Windows,
                                            msvcp140.dll is bundled next to the
                                            extension (Issue #359).
      6. (CI) install the wheel and run the unit tests against it.

Usage:
    build_distrib.py [--out-dir DIR] [--dev | --version VERSION]

Options:
    --out-dir DIR       Output directory for the .whl file (default: build/dist).
    --dev               Produce a unique PEP 440 development version derived from
                        git: <major>.0.dev<commit-count>+g<short-hash>
                        (e.g. 147.0.dev5231+g98cd08e). Used by CI so every build
                        has a distinct, commit-identifiable version. Requires the
                        full git history (checkout with fetch-depth: 0).
    --version VERSION   Use VERSION verbatim (overrides --dev and the header).

The cefpython3/ directory must already contain the compiled outputs and CEF
runtime. Windows/Linux use a flat subprocess executable; macOS uses five
sibling ``cefpython Helper*.app`` bundles.

The base version is read automatically from src/version/cef_version_*.h.
Wheel metadata (name, summary, author, URLs, keywords, classifiers) is read
from the [project] table in pyproject.toml, so the wheel and pyproject stay a
single source of truth.
"""

import base64
import glob
import hashlib
import os
import platform
import shutil
import stat
import subprocess
import sys
import sysconfig
import zipfile

import cef_version


MAC_HELPER_APP_NAMES = [
    "cefpython Helper.app",
    "cefpython Helper (Alerts).app",
    "cefpython Helper (GPU).app",
    "cefpython Helper (Plugin).app",
    "cefpython Helper (Renderer).app",
]

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # Python 3.10
    import tomli as tomllib


def main():
    out_dir = "build/dist"
    if "--out-dir" in sys.argv:
        out_dir = sys.argv[sys.argv.index("--out-dir") + 1]

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(repo_root)
    os.makedirs(out_dir, exist_ok=True)

    if "--version" in sys.argv:
        version = sys.argv[sys.argv.index("--version") + 1]
    elif "--dev" in sys.argv:
        version = _dev_version(_read_version())
    else:
        version = _read_version()
    print("[build_distrib.py] Version:", version)
    vi = sys.version_info
    cp = "cp{0}{1}".format(vi.major, vi.minor)
    platform = _wheel_platform_tag()

    wheel_name = "cefpython3-{v}-{cp}-{cp}-{p}.whl".format(
        v=version, cp=cp, p=platform)
    wheel_path = os.path.join(out_dir, wheel_name)
    dist_info = "cefpython3-{v}.dist-info".format(v=version)

    pkg_dir = "cefpython3"
    if not os.path.isdir(pkg_dir):
        print("[build_distrib.py] ERROR: {pkg_dir}/ not found".format(
            pkg_dir=pkg_dir))
        sys.exit(1)
    ext = ".pyd" if sys.platform == "win32" else ".so"
    if not glob.glob(os.path.join(pkg_dir, "cefpython_py*" + ext)):
        print("[build_distrib.py] ERROR: no cefpython_py*{ext} in {pkg_dir}/,"
              " run compile step first".format(ext=ext, pkg_dir=pkg_dir))
        sys.exit(1)

    _validate_macos_helpers(pkg_dir)
    _reduce_package_size_issue262(pkg_dir)
    _bundle_msvcp140_issue359(pkg_dir)

    records = []

    def _add_bytes(arcname, data):
        digest = base64.urlsafe_b64encode(
            hashlib.sha256(data).digest()).rstrip(b"=").decode()
        records.append((arcname, "sha256=" + digest, str(len(data))))
        zf.writestr(arcname, data)

    print("[build_distrib.py] Creating:", wheel_path)

    with zipfile.ZipFile(wheel_path, "w", zipfile.ZIP_DEFLATED) as zf:
        # Package files
        for root, dirs, files in os.walk(pkg_dir):
            dirs[:] = sorted(d for d in dirs if d != "__pycache__")
            for filename in sorted(files):
                if filename.endswith(".pyc"):
                    continue
                filepath = os.path.join(root, filename)
                arcname = filepath.replace(os.sep, "/")
                data = open(filepath, "rb").read()
                digest = base64.urlsafe_b64encode(
                    hashlib.sha256(data).digest()).rstrip(b"=").decode()
                records.append((arcname, "sha256=" + digest, str(len(data))))
                info = zipfile.ZipInfo.from_file(filepath, arcname)
                # ZipInfo.from_file() defaults to ZIP_STORED; deflate so the
                # wheel is actually compressed (matches the ZipFile mode).
                info.compress_type = zipfile.ZIP_DEFLATED
                zf.writestr(info, data)

        # dist-info/METADATA (all fields sourced from [project] in pyproject.toml
        # so the wheel and pyproject stay a single source of truth)
        _add_bytes(dist_info + "/METADATA",
                   _core_metadata(version, _read_project_metadata()))

        # dist-info/WHEEL
        _add_bytes(dist_info + "/WHEEL", (
            "Wheel-Version: 1.0\n"
            "Generator: cefpython-build_distrib\n"
            "Root-Is-Purelib: False\n"
            "Tag: {cp}-{cp}-{p}\n"
        ).format(cp=cp, p=platform).encode())

        # dist-info/top_level.txt
        _add_bytes(dist_info + "/top_level.txt", b"cefpython3\n")

        # dist-info/RECORD (no hash for RECORD itself per wheel spec)
        record_arcname = dist_info + "/RECORD"
        records.append((record_arcname, "", ""))
        record_data = "\n".join(
            "{r},{h},{s}".format(r=r, h=h, s=s) for r, h, s in records) + "\n"
        zf.writestr(record_arcname, record_data)

    print("[build_distrib.py] Done:", wheel_path)


def _wheel_platform_tag():
    platform_tag = (sysconfig.get_platform()
                    .replace("-", "_").replace(".", "_"))
    if sys.platform == "darwin":
        # setup-python provides a universal2 interpreter whose sysconfig tag
        # remains universal2 even while its native arm64 slice is executing.
        # The packaged CEF framework and helpers are arm64-only, so tag the
        # payload architecture instead of copying the interpreter's tag.
        machine = platform.machine().lower()
        if machine != "arm64":
            raise RuntimeError(
                "macOS CEF distribution requires native arm64 Python; "
                "got {0} ({1})".format(machine, platform_tag))
        return "macosx_12_0_arm64"
    return platform_tag


def _validate_macos_helpers(pkg_dir):
    """Fail before packaging an incomplete or non-executable helper set."""
    if sys.platform != "darwin":
        return

    expected = set(MAC_HELPER_APP_NAMES)
    found = {
        os.path.basename(path)
        for path in glob.glob(os.path.join(pkg_dir, "cefpython Helper*.app"))
        if os.path.isdir(path)
    }
    if found != expected:
        missing = sorted(expected - found)
        unexpected = sorted(found - expected)
        details = []
        if missing:
            details.append("missing: " + ", ".join(missing))
        if unexpected:
            details.append("unexpected: " + ", ".join(unexpected))
        raise RuntimeError("invalid macOS helper bundle set ({0})".format(
            "; ".join(details)))

    for name in MAC_HELPER_APP_NAMES:
        app = os.path.join(pkg_dir, name)
        executable = os.path.join(
            app, "Contents", "MacOS", os.path.splitext(name)[0])
        info_plist = os.path.join(app, "Contents", "Info.plist")
        if not os.path.isfile(info_plist):
            raise RuntimeError("missing helper Info.plist: " + info_plist)
        if not os.path.isfile(executable):
            raise RuntimeError("missing helper executable: " + executable)
        if not os.stat(executable).st_mode & stat.S_IXUSR:
            raise RuntimeError("helper is not executable: " + executable)


def _read_project_metadata():
    """Return the [project] table from pyproject.toml (CWD is the repo root)."""
    with open("pyproject.toml", "rb") as f:
        return tomllib.load(f).get("project", {})


def _core_metadata(version, project):
    """Build wheel core metadata (METADATA) from the [project] table.

    Version is passed in (it is dynamic, computed from the CEF header / git);
    everything else comes from pyproject.toml so there is a single source.
    """
    lines = [
        "Metadata-Version: 2.1",
        "Name: " + project.get("name", "cefpython3"),
        "Version: " + version,
    ]
    if project.get("description"):
        lines.append("Summary: " + project["description"])
    for author in project.get("authors", []):
        if author.get("name"):
            lines.append("Author: " + author["name"])
        if author.get("email"):
            lines.append("Author-email: " + author["email"])
    lic = project.get("license")
    if isinstance(lic, dict) and lic.get("text"):
        lines.append("License: " + lic["text"])
    elif isinstance(lic, str):
        lines.append("License: " + lic)
    if project.get("requires-python"):
        lines.append("Requires-Python: " + project["requires-python"])
    if project.get("keywords"):
        lines.append("Keywords: " + ",".join(project["keywords"]))
    for label, url in project.get("urls", {}).items():
        lines.append("Project-URL: {0}, {1}".format(label, url))
    for classifier in project.get("classifiers", []):
        lines.append("Classifier: " + classifier)

    # Long description (Description body). PEP 621 readme: a table with an
    # inline "text" (+ "content-type") or a "file", or a bare filename string.
    body = ""
    readme = project.get("readme")
    if isinstance(readme, dict):
        content_type = readme.get("content-type", "text/plain")
        if readme.get("text"):
            body = readme["text"]
        elif readme.get("file"):
            with open(readme["file"], encoding="utf-8") as f:
                body = f.read()
        if body:
            lines.append("Description-Content-Type: " + content_type)
    elif isinstance(readme, str):
        with open(readme, encoding="utf-8") as f:
            body = f.read()
        lines.append("Description-Content-Type: text/markdown")

    header = "\n".join(lines) + "\n"
    # The description body follows the headers, separated by one blank line.
    if body:
        return (header + "\n" + body + "\n").encode("utf-8")
    return header.encode("utf-8")


def _reduce_package_size_issue262(pkg_dir):
    """Linux only: strip DWARF debug info from libcef.so (Issue #262).

    CEF ships libcef.so at ~1.3 GB, almost all of it DWARF debug info
    (.debug_*), which would bloat the Linux wheel far beyond the other
    platforms. `strip --strip-debug` removes the DWARF sections but KEEPS the
    symbol table (.symtab), so CEF crash backtraces still symbolize to function
    names when reporting issues upstream. A full `strip` would also drop
    .symtab and leave crashes unsymbolized (only the ~1.6k exported .dynsym
    names would resolve). Keeping .symtab costs ~25 MB compressed per wheel
    (libcef.so ~252 MB -> ~428 MB uncompressed) but not the DWARF's ~1 GB.
    """
    if not sys.platform.startswith("linux"):
        return
    libcef_so = os.path.join(pkg_dir, "libcef.so")
    if not os.path.exists(libcef_so):
        return
    before = os.path.getsize(libcef_so)
    print("[build_distrib.py] Strip {0} (Issue #262)".format(
        os.path.basename(libcef_so)))
    code = subprocess.call(["strip", "--strip-debug", libcef_so])
    assert code == 0, "strip command failed"
    print("[build_distrib.py] libcef.so: {0:.0f} MB -> {1:.0f} MB".format(
        before / 1e6, os.path.getsize(libcef_so) / 1e6))


def _bundle_msvcp140_issue359(pkg_dir):
    """CEF Python module is written in Cython and is a Python C++
    extension and depends on msvcp140.dll. See Issue #359. These
    dependencies are not included with Python binaries from Python.org.

    Ported from make_installer.py (copy_cpp_extension_dependencies_issue359):
    copy msvcp140.dll from %SYSTEMROOT%\\System32 next to the extension.
    Python does ship vcruntime140.dll / vcruntime140_1.dll, so msvcp140.dll
    is the only gap.
    """
    if sys.platform != "win32":
        return
    system32 = os.path.join(os.environ.get("SYSTEMROOT", r"C:\Windows"),
                            "System32")
    src = os.path.join(system32, "msvcp140.dll")
    if not os.path.exists(src):
        raise Exception("C++ extension dll dependency not found: {0}"
                        " (Issue #359)".format(src))
    shutil.copy2(src, os.path.join(pkg_dir, "msvcp140.dll"))
    print("[build_distrib.py] Bundle msvcp140.dll (Issue #359)")


def _dev_version(base):
    """<base>.dev<commit-count>+g<short-hash> from git (PEP 440 dev version).

    Gives every CI build a unique, commit-identifiable version, e.g.
    147.0.dev5231+g98cd08e. Falls back to <base>.dev0 if git is unavailable.
    """
    try:
        count = subprocess.check_output(
            ["git", "rev-list", "--count", "HEAD"]).decode().strip()
        short = subprocess.check_output(
            ["git", "rev-parse", "--short", "HEAD"]).decode().strip()
        return "{base}.dev{count}+g{short}".format(
            base=base, count=count, short=short)
    except Exception as exc:
        print("[build_distrib.py] WARNING: git version derivation failed"
              " (%s); using %s.dev0" % (exc, base))
        return base + ".dev0"


def _read_version():
    """Base wheel version <major>.0 from the CEF version header."""
    return cef_version.read()["CHROME_VERSION_MAJOR"] + ".0"


if __name__ == "__main__":
    main()
