#!/usr/bin/env python3
# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Merge the per-Python cefpython3 wheels of one platform into a single wheel.

build_distrib.py creates one wheel per Python version, each with its own
cefpython_pyXY extension module and a full copy of the CEF runtime. This tool
combines wheels built from the same commit into one wheel that has every
module and a single copy of the runtime:

    cefpython3-147.0-cp310-cp310-win_amd64.whl + cp311 + cp312
        -> cefpython3-147.0-cp310.cp311.cp312-cp310.cp311.cp312-win_amd64.whl

pip accepts the merged wheel only for the Python versions in its tag set.
The inputs must share the name, version and platform tag, and every file
other than the extension module must be byte-for-byte identical; otherwise
the merge fails.
"""

import argparse
import base64
import glob
import hashlib
import os
import re
import sys
import zipfile

CHUNK_SIZE = 1024 * 1024

WHEEL_FILENAME_RE = re.compile(
    r"^(?P<name>[^-]+)-(?P<version>[^-]+)"
    r"-(?P<python>cp\d+)-(?P<abi>cp\d+)-(?P<platform>[^-]+)\.whl$")
MODULE_RE = re.compile(r"^cefpython3/cefpython_py(\d+)\.(pyd|so)$")


def fail(message):
    print("[merge_wheels.py] ERROR:", message)
    sys.exit(1)


class Wheel(object):
    """One input wheel. Also keeps the zip file open until close()."""

    def __init__(self, path):
        self.path = path
        match = WHEEL_FILENAME_RE.match(os.path.basename(path))
        if not match or match.group("python") != match.group("abi"):
            fail("{0}: not a cpXY-cpXY wheel built by build_distrib.py".format(
                os.path.basename(path)))
        self.name = match.group("name")
        self.version = match.group("version")
        self.python = match.group("python")
        self.platform = match.group("platform")
        self.dist_info = "{0}-{1}.dist-info/".format(self.name, self.version)
        self.zf = zipfile.ZipFile(path)

        names = [i.filename for i in self.zf.infolist() if not i.is_dir()]
        modules = [n for n in names if MODULE_RE.match(n)]
        expected = "cefpython3/cefpython_py{0}.".format(self.python[2:])
        if len(modules) != 1 or not modules[0].startswith(expected):
            fail("{0}: expected exactly one {1}* module, found {2}".format(
                os.path.basename(path), expected, modules or "none"))
        self.module = modules[0]
        self.dist_files = {
            n: self.zf.read(n) for n in names if n.startswith(self.dist_info)}
        for required in ("METADATA", "WHEEL", "RECORD"):
            if self.dist_info + required not in self.dist_files:
                fail("{0}: {1}{2} is missing".format(
                    os.path.basename(path), self.dist_info, required))
        tag = "{0}-{1}-{2}".format(self.python, self.python, self.platform)
        wheel_text = self.dist_files[self.dist_info + "WHEEL"].decode()
        if "Tag: " + tag not in wheel_text.splitlines():
            fail("{0}: WHEEL does not contain 'Tag: {1}'".format(
                os.path.basename(path), tag))

    def metadata_files(self):
        """The dist-info files that are copied as they are, i.e. all but the
        ones that are regenerated for the merged wheel."""
        return {n: d for n, d in self.dist_files.items()
                if n.rsplit("/", 1)[-1] not in ("WHEEL", "RECORD")}

    def shared_infos(self):
        """Members that must be identical in all wheels: everything except
        the extension module and the dist-info directory."""
        return [i for i in self.zf.infolist()
                if not i.is_dir() and i.filename != self.module
                and not i.filename.startswith(self.dist_info)]

    def shared_manifest(self):
        manifest = {}
        for info in self.shared_infos():
            digest = hashlib.sha256()
            with self.zf.open(info) as src:
                for chunk in iter(lambda: src.read(CHUNK_SIZE), b""):
                    digest.update(chunk)
            manifest[info.filename] = (digest.hexdigest(), info.file_size)
        return manifest

    def close(self):
        self.zf.close()


def check_compatible(wheels):
    base = wheels[0]
    for wheel in wheels[1:]:
        for attr in ("name", "version", "platform"):
            if getattr(wheel, attr) != getattr(base, attr):
                fail("{0} differs between {1} ({2}) and {3} ({4})".format(
                    attr, os.path.basename(base.path), getattr(base, attr),
                    os.path.basename(wheel.path), getattr(wheel, attr)))
    pythons = [w.python for w in wheels]
    if len(set(pythons)) != len(pythons):
        fail("more than one wheel for the same Python version: {0}".format(
            ", ".join(pythons)))
    base_meta = base.metadata_files()
    for wheel in wheels[1:]:
        meta = wheel.metadata_files()
        for name in sorted(set(base_meta) | set(meta)):
            if base_meta.get(name) != meta.get(name):
                fail("{0} differs between {1} and {2}".format(
                    name, os.path.basename(base.path),
                    os.path.basename(wheel.path)))


def supported_pythons(repo_root):
    """Python tags (cp310, ...) of the versions listed in the classifiers of
    pyproject.toml."""
    try:
        import tomllib  # Python 3.11+
    except ModuleNotFoundError:  # Python 3.10
        import tomli as tomllib
    with open(os.path.join(repo_root, "pyproject.toml"), "rb") as f:
        classifiers = tomllib.load(f)["project"]["classifiers"]
    pattern = re.compile(r"^Programming Language :: Python :: 3\.(\d+)$")
    return {"cp3" + m.group(1) for m in map(pattern.match, classifiers) if m}


def check_all_supported_pythons(wheels, repo_root):
    supported = supported_pythons(repo_root)
    merged = {w.python for w in wheels}
    if merged != supported:
        fail("the wheels do not cover the Python versions in the classifiers "
             "of pyproject.toml (missing: {0}; not listed: {1})".format(
                 ", ".join(sorted(supported - merged)) or "none",
                 ", ".join(sorted(merged - supported)) or "none"))


def check_shared_files_identical(wheels):
    base_manifest = wheels[0].shared_manifest()
    problems = []
    for wheel in wheels[1:]:
        manifest = wheel.shared_manifest()
        for name in sorted(set(base_manifest) | set(manifest)):
            if name not in manifest:
                problems.append("{0}: missing in {1}".format(
                    name, os.path.basename(wheel.path)))
            elif name not in base_manifest:
                problems.append("{0}: only in {1}".format(
                    name, os.path.basename(wheel.path)))
            elif manifest[name] != base_manifest[name]:
                problems.append("{0}: differs in {1}".format(
                    name, os.path.basename(wheel.path)))
    if problems:
        fail("the wheels are not built from identical files, so they cannot "
             "share one copy:\n  " + "\n  ".join(problems[:20])
             + ("\n  ... and {0} more".format(len(problems) - 20)
                if len(problems) > 20 else ""))


def record_row(name, digest, size):
    encoded = base64.urlsafe_b64encode(digest.digest()).rstrip(b"=").decode()
    return "{0},sha256={1},{2}".format(name, encoded, size)


def copy_member(out, src_zf, info, rows):
    """Stream one member into the output wheel, deflated, keeping the
    timestamp and the mode bits (the executable bit of helpers matters)."""
    new = zipfile.ZipInfo(info.filename, info.date_time)
    new.compress_type = zipfile.ZIP_DEFLATED
    new.create_system = info.create_system
    new.external_attr = info.external_attr
    new.file_size = info.file_size  # lets zipfile decide on ZIP64 up front
    digest = hashlib.sha256()
    with src_zf.open(info) as src, out.open(new, "w") as dst:
        for chunk in iter(lambda: src.read(CHUNK_SIZE), b""):
            digest.update(chunk)
            dst.write(chunk)
    rows.append(record_row(info.filename, digest, info.file_size))


def add_bytes(out, name, data, rows):
    out.writestr(name, data)
    rows.append(record_row(name, hashlib.sha256(data), len(data)))


def wheel_file_contents(wheel, pythons):
    lines = [
        "Wheel-Version: 1.0",
        "Generator: cefpython-merge_wheels",
        "Root-Is-Purelib: False",
    ]
    # A compressed tag set stands for the product of its parts (PEP 425), and
    # the WHEEL file lists every member of it, like the "wheel" package does.
    for python in pythons:
        for abi in pythons:
            lines.append("Tag: {0}-{1}-{2}".format(python, abi, wheel.platform))
    return ("\n".join(lines) + "\n").encode()


def merge(wheels, out_dir):
    base = wheels[0]
    pythons = [w.python for w in wheels]
    tag_set = ".".join(pythons)
    filename = "{0}-{1}-{2}-{2}-{3}.whl".format(
        base.name, base.version, tag_set, base.platform)
    out_path = os.path.join(out_dir, filename)
    if any(os.path.abspath(w.path) == os.path.abspath(out_path) for w in wheels):
        fail("{0} would replace an input wheel, use another --out-dir".format(
            filename))
    os.makedirs(out_dir, exist_ok=True)
    tmp_path = out_path + ".tmp"

    members = [(base.zf, info) for info in base.shared_infos()]
    members += [(w.zf, w.zf.getinfo(w.module)) for w in wheels]
    members.sort(key=lambda m: m[1].filename)

    rows = []
    try:
        with zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as out:
            for src_zf, info in members:
                copy_member(out, src_zf, info, rows)
            for name, data in sorted(base.metadata_files().items()):
                add_bytes(out, name, data, rows)
            add_bytes(out, base.dist_info + "WHEEL",
                      wheel_file_contents(base, pythons), rows)
            record_name = base.dist_info + "RECORD"
            rows.append(record_name + ",,")
            out.writestr(record_name, "\n".join(rows) + "\n")
        with zipfile.ZipFile(tmp_path) as check:
            bad = check.testzip()
            if bad:
                fail("corrupt member in the merged wheel: " + bad)
        os.replace(tmp_path, out_path)
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
    return out_path


def expand(patterns):
    """Expand glob patterns ourselves, since Windows shells do not."""
    paths = []
    for pattern in patterns:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    return paths


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("wheels", nargs="+", metavar="WHEEL")
    parser.add_argument("--out-dir")
    parser.add_argument(
        "--require-all-pythons", action="store_true",
        help="fail unless there is a wheel for every Python version listed in"
             " the classifiers of pyproject.toml (CI passes this)")
    args = parser.parse_args()

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = args.out_dir or os.path.join(repo_root, "build", "dist")

    paths = expand(args.wheels)
    for path in paths:
        if not os.path.isfile(path):
            fail("not a file: " + path)
    wheels = sorted((Wheel(p) for p in paths), key=lambda w: int(w.python[2:]))
    try:
        check_compatible(wheels)
        if args.require_all_pythons:
            check_all_supported_pythons(wheels, repo_root)
        check_shared_files_identical(wheels)
        out_path = merge(wheels, out_dir)
    finally:
        for wheel in wheels:
            wheel.close()

    before = sum(os.path.getsize(p) for p in paths)
    after = os.path.getsize(out_path)
    print("[merge_wheels.py] Merged {0} wheels ({1:.0f} MB) into {2} "
          "({3:.0f} MB)".format(len(paths), before / 1e6, out_path, after / 1e6))


if __name__ == "__main__":
    main()
