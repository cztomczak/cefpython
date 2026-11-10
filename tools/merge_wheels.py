#!/usr/bin/env python3
# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Merge the per-Python cefpython3 wheels of one platform into one wheel.

build_distrib.py creates one wheel per Python version. Only the
cefpython_pyXY extension module depends on the Python version; the CEF
runtime, subprocess and the rest of the package do not. So the merged wheel
is the wheel of the lowest Python version (the base wheel) plus the
cefpython_pyXY modules of the other wheels, with the Tag lines in WHEEL, the
RECORD and the filename updated:

    cefpython3-147.0-cp310-cp310-win_amd64.whl + cp311 + cp312
        -> cefpython3-147.0-cp310.cp311.cp312-cp310.cp311.cp312-win_amd64.whl

Files other than the modules are taken from the base wheel without comparing
them with the other wheels' copies, which can differ (on Windows,
subprocess.exe differs in its link timestamps). The wheels must be built
from the same commit; the script checks that they have the same name,
version and platform tag.
"""

import argparse
import base64
import csv
import glob
import hashlib
import io
import os
import re
import shutil
import sys
import zipfile

WHEEL_FILENAME_RE = re.compile(
    r"^(?P<name>[^-]+)-(?P<version>[^-]+)"
    r"-(?P<python_tag>cp\d+)-(?P=python_tag)-(?P<platform>[^-]+)\.whl$")


def fail(message):
    print("[merge_wheels.py] ERROR:", message)
    sys.exit(1)


def parse_wheel_filename(path):
    match = WHEEL_FILENAME_RE.match(os.path.basename(path))
    if not match:
        fail("{0}: not a cpXY-cpXY wheel built by build_distrib.py".format(
            os.path.basename(path)))
    return match.groupdict()


def find_module(zf, python_tag):
    """Path of the cefpython3/cefpython_pyXY.{pyd,so} module in a per-Python
    wheel."""
    pattern = re.compile(
        r"^cefpython3/cefpython_py{0}\.(pyd|so)$".format(python_tag[2:]))
    modules = [n for n in zf.namelist() if pattern.match(n)]
    if len(modules) != 1:
        fail("{0}: expected one cefpython_py{1} module, found {2}".format(
            os.path.basename(zf.filename), python_tag[2:], len(modules)))
    return modules[0]


def record_row(member, data):
    digest = base64.urlsafe_b64encode(
        hashlib.sha256(data).digest()).rstrip(b"=").decode()
    return [member, "sha256=" + digest, str(len(data))]


def copy_member(src_zf, info, out):
    """Copy one member, keeping its timestamp and mode bits (the executable
    bit of subprocess and the macOS helpers matters)."""
    new = zipfile.ZipInfo(info.filename, info.date_time)
    new.create_system = info.create_system
    new.external_attr = info.external_attr
    new.compress_type = zipfile.ZIP_DEFLATED
    new.file_size = info.file_size  # lets zipfile decide on ZIP64 up front
    with src_zf.open(info) as src, out.open(new, "w") as dst:
        shutil.copyfileobj(src, dst, 1024 * 1024)


def merge(paths, out_dir):
    if len(paths) < 2:
        fail("need at least two wheels to merge")
    wheels = sorted((dict(parse_wheel_filename(p), path=p) for p in paths),
                    key=lambda w: int(w["python_tag"][2:]))
    base = wheels[0]
    for wheel in wheels[1:]:
        for key in ("name", "version", "platform"):
            if wheel[key] != base[key]:
                fail("{0} differs: {1} in {2}, {3} in {4}".format(
                    key, base[key], os.path.basename(base["path"]),
                    wheel[key], os.path.basename(wheel["path"])))
    python_tags = [w["python_tag"] for w in wheels]
    if len(set(python_tags)) != len(python_tags):
        fail("more than one wheel for the same Python version: "
             + ", ".join(python_tags))
    for wheel in wheels:
        with zipfile.ZipFile(wheel["path"]) as zf:
            wheel["module"] = find_module(zf, wheel["python_tag"])

    tag_set = ".".join(python_tags)
    filename = "{0}-{1}-{2}-{2}-{3}.whl".format(
        base["name"], base["version"], tag_set, base["platform"])
    out_path = os.path.join(out_dir, filename)

    dist_info = "{0}-{1}.dist-info/".format(base["name"], base["version"])
    wheel_member = dist_info + "WHEEL"
    record_member = dist_info + "RECORD"

    os.makedirs(out_dir, exist_ok=True)
    tmp_path = out_path + ".tmp"
    try:
        with zipfile.ZipFile(base["path"]) as base_zf, \
                zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as out:
            # The compressed tag set in the filename expands to every
            # python-abi pair, including pairs like cp310-cp311 that no
            # interpreter matches. WHEEL lists the same expansion, as
            # "wheel tags" does. (WHEEL_FILENAME_RE makes sure that each input
            # wheel's abi tag equals its python tag.)
            lines = [line for line in
                     base_zf.read(wheel_member).decode().splitlines()
                     if not line.startswith("Tag:")]
            lines += ["Tag: {0}-{0}-{1}".format(python_tag, base["platform"])
                      for python_tag in python_tags]
            wheel_member_data = ("\n".join(lines) + "\n").encode()

            rows = [row for row in csv.reader(
                        io.StringIO(base_zf.read(record_member).decode()))
                    if row and row[0] not in (wheel_member, record_member)]
            members = [i for i in base_zf.infolist()
                       if i.filename not in (wheel_member, record_member)]
            package_files = [i for i in members
                             if not i.filename.startswith(dist_info)]
            dist_info_files = [i for i in members
                               if i.filename.startswith(dist_info)]

            # The .dist-info files go last, as the wheel spec recommends.
            for info in package_files:
                copy_member(base_zf, info, out)
            for wheel in wheels[1:]:
                with zipfile.ZipFile(wheel["path"]) as zf:
                    info = zf.getinfo(wheel["module"])
                    copy_member(zf, info, out)
                    rows.append(record_row(info.filename, zf.read(info)))
            for info in dist_info_files:
                copy_member(base_zf, info, out)
            out.writestr(wheel_member, wheel_member_data)
            rows.append(record_row(wheel_member, wheel_member_data))
            rows.append([record_member, "", ""])
            record = io.StringIO()
            csv.writer(record, lineterminator="\n").writerows(rows)
            out.writestr(record_member, record.getvalue())
        os.replace(tmp_path, out_path)
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
    return out_path


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("wheels", nargs="+", metavar="WHEEL")
    parser.add_argument("--out-dir",
                        default=os.path.join(repo_root, "build", "merged"),
                        help="default: %(default)s")
    args = parser.parse_args()

    paths = []
    for pattern in args.wheels:  # Windows shells do not expand globs
        paths.extend(glob.glob(pattern) or [pattern])
    for path in paths:
        if not os.path.isfile(path):
            fail("not a file: " + path)

    out_path = merge(paths, args.out_dir)
    print("[merge_wheels.py] Merged {0} wheels into {1} ({2:.0f} MB)".format(
        len(paths), out_path, os.path.getsize(out_path) / 1e6))


if __name__ == "__main__":
    main()
