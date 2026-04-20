# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Create a distributable wheel from the pre-built cefpython3/ package directory.

Usage:
    build_distrib.py [--out-dir DIR]

Options:
    --out-dir DIR   Output directory for the .whl file (default: build/dist).

The cefpython3/ directory must already contain the compiled outputs:
    cefpython_py<XY>.pyd, subprocess.exe, CEF runtime files, __init__.py

Version is read automatically from src/version/cef_version_win.h.
"""

import base64
import glob
import hashlib
import os
import re
import sys
import zipfile


def main():
    out_dir = "build/dist"
    if "--out-dir" in sys.argv:
        out_dir = sys.argv[sys.argv.index("--out-dir") + 1]

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(repo_root)
    os.makedirs(out_dir, exist_ok=True)

    version = _read_version()
    vi = sys.version_info
    cp = "cp{0}{1}".format(vi.major, vi.minor)
    platform = "win_amd64"

    wheel_name = "cefpython3-{v}-{cp}-{cp}-{p}.whl".format(
        v=version, cp=cp, p=platform)
    wheel_path = os.path.join(out_dir, wheel_name)
    dist_info = "cefpython3-{v}.dist-info".format(v=version)

    pkg_dir = "cefpython3"
    if not os.path.isdir(pkg_dir):
        print("[build_distrib.py] ERROR: {pkg_dir}/ not found".format(
            pkg_dir=pkg_dir))
        sys.exit(1)
    if not glob.glob(os.path.join(pkg_dir, "cefpython_py*.pyd")):
        print("[build_distrib.py] ERROR: no cefpython_py*.pyd in {pkg_dir}/,"
              " run compile step first".format(pkg_dir=pkg_dir))
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
                zf.write(filepath, arcname)

        # dist-info/METADATA
        _add_bytes(dist_info + "/METADATA", (
            "Metadata-Version: 2.1\n"
            "Name: cefpython3\n"
            "Version: {v}\n"
            "Summary: Python bindings for the Chromium Embedded Framework\n"
            "Requires-Python: >=3.10\n"
            "License: BSD-3-Clause\n"
        ).format(v=version).encode())

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


def _read_version():
    header = os.path.join("src", "version", "cef_version_win.h")
    with open(header) as f:
        for line in f:
            m = re.match(r"#define CHROME_VERSION_MAJOR\s+(\d+)", line)
            if m:
                return "{major}.0".format(major=m.group(1))
    raise RuntimeError(
        "CHROME_VERSION_MAJOR not found in " + header)


if __name__ == "__main__":
    main()
