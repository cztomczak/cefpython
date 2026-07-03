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
                                            and the subprocess helper.
      4. stage into cefpython3/           - copy the compiled module, the
                                            subprocess binary and the CEF
                                            runtime files next to __init__.py.
      5. build_distrib.py (this script)   - zip cefpython3/ into a PEP 427 wheel
                                            with a generated .dist-info
                                            (METADATA, WHEEL, top_level.txt,
                                            RECORD). No compilation happens here.
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

The cefpython3/ directory must already contain the compiled outputs:
    cefpython_py<XY>.pyd, subprocess.exe, CEF runtime files, __init__.py

The base version is read automatically from src/version/cef_version_*.h.
Wheel metadata (name, summary, author, URLs, keywords, classifiers) is read
from the [project] table in pyproject.toml, so the wheel and pyproject stay a
single source of truth.
"""

import base64
import glob
import hashlib
import os
import re
import subprocess
import sys
import sysconfig
import zipfile

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
    platform = sysconfig.get_platform().replace("-", "_").replace(".", "_")

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

    return ("\n".join(lines) + "\n").encode("utf-8")


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
    if sys.platform == "win32":
        name = "cef_version_win.h"
    elif sys.platform == "darwin":
        name = "cef_version_macarm64.h"
    else:
        name = "cef_version_linux.h"
    header = os.path.join("src", "version", name)
    with open(header) as f:
        for line in f:
            m = re.match(r"#define CHROME_VERSION_MAJOR\s+(\d+)", line)
            if m:
                return "{major}.0".format(major=m.group(1))
    raise RuntimeError(
        "CHROME_VERSION_MAJOR not found in " + header)


if __name__ == "__main__":
    main()
