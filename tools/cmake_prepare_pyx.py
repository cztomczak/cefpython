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


def except_all_missing(content):
    """Return the line number of a cdef/cpdef returning a C type without 'except *',
    or None if all look fine."""
    patterns = [
        (r"\bcp?def\s+"
         r"((int|short|long|double|char|unsigned|float|cpp_bool"
         r"|cpp_string|cpp_wstring|uintptr_t|void"
         r"|int32|uint32|int64|uint64"
         r"|int32_t|uint32_t|int64_t|uint64_t"
         r"|CefString)\s+)+"
         r"\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:"),
        r"\bcp?def\s+[^\s]+[\]*]\s+\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:",
        r"\bcp?def\s+[^\s]+&\s+\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:",
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
    module_vars = (
        '__version__ = "{v}"\n'.format(v=version_str)
        + '__chrome_version__ = "{v}"\n'.format(v=chrome_ver)
        + '__cef_version__ = "{v}"\n'.format(v=ver["CEF_VERSION"])
        + '__cef_api_hash_platform__ = "{v}"\n'.format(v=ver["CEF_API_HASH_PLATFORM"])
        + '__cef_api_hash_universal__ = "{v}"\n'.format(v=ver["CEF_API_HASH_UNIVERSAL"])
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
