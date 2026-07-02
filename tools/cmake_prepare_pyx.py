#!/usr/bin/env python3
"""Prepare .pyx files for Cython compilation.

Replaces copy_and_fix_pyx_files() in build.py.
Copies src/*.pyx and src/handlers/*.pyx to an output stage directory,
fixing include paths and stripping redundant include statements.
Also prepends module version variables to the main cefpython.pyx.

Called by CMake:
    cmake_prepare_pyx.py --src <src_dir> --out <out_dir>
                         --pyversion <ver> --cef-version-header <path>
"""
import argparse
import glob
import os
import re
import shutil
import sys


def get_cefpython_version(header_file):
    ret = {}
    with open(header_file, "r") as f:
        contents = f.read()
    for match in re.finditer(r'^#define (\w+) "?([^\s"]+)"?', contents, re.MULTILINE):
        ret[match.group(1)] = match.group(2)
    return ret


# The build compiles with CEF's default API version, which cef_api_hash.h sets
# to CEF_API_VERSION_EXPERIMENTAL (999999) when CEF_API_VERSION is not defined.
CEF_API_VERSION_EXPERIMENTAL = 999999


def get_host_os_macro():
    """Return the CEF OS_* macro for the build host (builds are always native)."""
    if sys.platform.startswith("win"):
        return "OS_WIN"
    if sys.platform == "darwin":
        return "OS_MAC"
    return "OS_LINUX"


def get_cef_api_hash(api_versions_header, api_version, os_macro):
    """Extract the CEF API hash for a version+platform from cef_api_versions.h.

    That generated header defines the hash per platform, e.g.:
        #if defined(OS_WIN)
        #define CEF_API_HASH_999999 "..."
        #elif defined(OS_MAC)
        #define CEF_API_HASH_999999 "..."
        #elif defined(OS_LINUX)
        #define CEF_API_HASH_999999 "..."
        #endif
    Each hash define is immediately preceded by its platform guard, so pick the
    one whose guard matches the build host.  This replaces hand-copying the hash
    into src/version/cef_version_*.h (the hash is authoritative here).
    """
    define = "CEF_API_HASH_{}".format(api_version)
    with open(api_versions_header, "r") as f:
        lines = f.read().splitlines()
    guard_re = re.compile(r"\s*#(?:if|elif)\s+defined\((OS_\w+)\)")
    define_re = re.compile(
        r'\s*#define\s+' + re.escape(define) + r'\s+"([0-9a-fA-F]+)"')
    for i, line in enumerate(lines):
        m = define_re.match(line)
        if not m or i == 0:
            continue
        guard = guard_re.match(lines[i - 1])
        if guard and guard.group(1) == os_macro:
            return m.group(1)
    raise RuntimeError(
        "Could not find {define} for {os} in {path}".format(
            define=define, os=os_macro, path=api_versions_header))


def except_all_missing(content):
    """Return the line number of a cdef/cpdef returning a C type (built-in,
    pointer, template or reference) whose signature declares no exception
    handling, or None if all look fine.

    A signature is considered fine if it carries any exception specification
    between ')' and ':' - 'except *', 'except? val', 'except +', 'except val'
    or 'noexcept'. Bare 'gil'/'nogil' and 'with gil'/'with nogil' modifiers are
    tolerated (they are not exception specs), so e.g. 'cdef int f() nogil:' is
    flagged while 'cdef int f() noexcept nogil:' is not."""
    patterns = [
        (r"\bcp?def\s+"
         r"((int|short|long|double|char|unsigned|float|cpp_bool"
         r"|cpp_string|cpp_wstring|uintptr_t|void"
         r"|int32|uint32|int64|uint64"
         r"|int32_t|uint32_t|int64_t|uint64_t"
         r"|CefString)\s+)+"
         r"\w+\([^)]*\)\s*((with\s+)?(gil|nogil)\s*)*:"),
        r"\bcp?def\s+[^\s]+[\]*]\s+\w+\([^)]*\)\s*((with\s+)?(gil|nogil)\s*)*:",
        r"\bcp?def\s+[^\s]+&\s+\w+\([^)]*\)\s*((with\s+)?(gil|nogil)\s*)*:",
    ]
    for pattern in patterns:
        match = re.search(pattern, content)
        if match:
            return content.count("\n", 0, match.start()) + 1
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", required=True, help="Path to src/")
    parser.add_argument("--out", required=True, help="Stage output directory")
    parser.add_argument("--pyversion", required=True, help="e.g. 310")
    parser.add_argument("--cef-version-header", required=True)
    parser.add_argument("--cef-api-versions-header", required=True,
                        help="Path to CEF's generated cef_api_versions.h "
                             "(in CEF_ROOT/include); source of the API hash.")
    args = parser.parse_args()

    src_dir = args.src
    out_dir = args.out
    pyversion = args.pyversion

    os.makedirs(out_dir, exist_ok=True)

    # Read version metadata
    ver = get_cefpython_version(args.cef_version_header)
    version_str = "{major}.0".format(major=ver["CHROME_VERSION_MAJOR"])
    chrome_ver = "{major}.{minor}.{build}.{patch}".format(
        major=ver["CHROME_VERSION_MAJOR"],
        minor=ver["CHROME_VERSION_MINOR"],
        build=ver["CHROME_VERSION_BUILD"],
        patch=ver["CHROME_VERSION_PATCH"],
    )
    # API hash comes from CEF's generated cef_api_versions.h, not from a value
    # hand-copied into cef_version_*.h. CEF_API_HASH_UNIVERSAL is deprecated and
    # upstream defines it as the same value as the platform hash.
    api_hash = get_cef_api_hash(args.cef_api_versions_header,
                                CEF_API_VERSION_EXPERIMENTAL,
                                get_host_os_macro())
    module_vars = (
        '__version__ = "{v}"\n'.format(v=version_str)
        + '__chrome_version__ = "{v}"\n'.format(v=chrome_ver)
        + '__cef_version__ = "{v}"\n'.format(v=ver["CEF_VERSION"])
        + '__cef_api_hash_platform__ = "{v}"\n'.format(v=api_hash)
        + '__cef_api_hash_universal__ = "{v}"\n'.format(v=api_hash)
        + '__cef_commit_hash__ = "{v}"\n'.format(v=ver["CEF_COMMIT_HASH"])
        + '__cef_commit_number__ = "{v}"\n'.format(v=ver["CEF_COMMIT_NUMBER"])
    )

    # --- Main file: cefpython.pyx → cefpython_pyXX.pyx ---
    main_src = os.path.join(src_dir, "cefpython.pyx")
    main_dst = os.path.join(out_dir, "cefpython_py{}.pyx".format(pyversion))
    with open(main_src, "rb") as f:
        content = f.read().decode("utf-8")
    # Flatten handlers/ include path: include "handlers/foo.pyx" → include "foo.pyx"
    content, n_subs = re.subn(r'^include "handlers/', 'include "', content, flags=re.MULTILINE)
    content = module_vars + content
    with open(main_dst, "wb") as f:
        f.write(content.encode("utf-8"))
    print("[cmake_prepare_pyx] Main: {} -> {} ({} include paths fixed)".format(
        os.path.basename(main_src), os.path.basename(main_dst), n_subs))

    # --- Other pyx files: copy, validate, strip include statements ---
    other_files = glob.glob(os.path.join(src_dir, "*.pyx"))
    other_files += glob.glob(os.path.join(src_dir, "handlers", "*.pyx"))
    other_files = [f for f in other_files if os.path.basename(f) != "cefpython.pyx"]

    for src_file in other_files:
        dst_file = os.path.join(out_dir, os.path.basename(src_file))
        shutil.copy(src_file, dst_file)
        with open(dst_file, "rb") as f:
            content = f.read().decode("utf-8")
        line = except_all_missing(content)
        if line:
            print("ERROR: 'except *' missing in {} at line {}".format(
                os.path.basename(src_file), line))
            sys.exit(1)
        # Remove include statements — they exist only for IDE support; Cython
        # includes everything through the main file's includes.
        content, _ = re.subn(
            r"^include[\t ]+[\"'][^\"'\n\r]+[\"'][\t ]*",
            "",
            content,
            flags=re.MULTILINE,
        )
        with open(dst_file, "wb") as f:
            f.write(content.encode("utf-8"))

    print("[cmake_prepare_pyx] Prepared {} .pyx files in {}".format(
        len(other_files) + 1, out_dir))


if __name__ == "__main__":
    main()
