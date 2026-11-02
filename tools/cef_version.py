# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Read CEF version fields from the per-platform src/version/cef_version_*.h,
and derive the cefpython3 package version from them (package_version()).

Deliberately side-effect-free (no import of common.py, no filesystem or argv
work at import time) so it can be shared by common.py and by the standalone
build scripts (build.py, build_distrib.py, cmake_prepare_pyx.py) without pulling
in common.py's import-time path detection.
"""

import os
import re
import subprocess
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def header_name(platform=None):
    """Per-platform version header filename for the given (or current) platform."""
    plat = sys.platform if platform is None else platform
    if plat.startswith("win"):
        return "cef_version_win.h"
    if plat == "darwin":
        return "cef_version_macarm64.h"
    return "cef_version_linux.h"


def header_path():
    """Absolute path to the current platform's version header."""
    return os.path.join(_ROOT, "src", "version", header_name())


def parse_header(header_file):
    """Parse `#define NAME value` / `#define NAME "value"` lines into a dict."""
    with open(header_file, "r") as f:
        contents = f.read()
    return {m.group(1): m.group(2) for m in re.finditer(
        r'^#define (\w+) "?([^\s"]+)"?', contents, re.MULTILINE)}


def read():
    """Version dict for the current platform's header."""
    return parse_header(header_path())


def package_version(release=None):
    """cefpython3 version: `release` in PEP 440 normalized form if given
    (e.g. 147.1-beta -> 147.1b0), else a dev version. Raises ValueError if
    `release` is not a valid PEP 440 version.

    The dev version is <major>.0.dev<commit-count>+g<short-hash> from git
    (e.g. 147.0.dev5231+g98cd08e), or <major>.0.dev0 if git is unavailable.
    """
    if release is not None:
        from packaging.version import InvalidVersion, Version
        try:
            return str(Version(release))
        except InvalidVersion:
            raise ValueError("not a PEP 440 version: {0!r}".format(release))
    base = read()["CHROME_VERSION_MAJOR"] + ".0"
    try:
        count = subprocess.check_output(
            ["git", "rev-list", "--count", "HEAD"], cwd=_ROOT).decode().strip()
        short = subprocess.check_output(
            ["git", "rev-parse", "--short", "HEAD"], cwd=_ROOT).decode().strip()
        return "{base}.dev{count}+g{short}".format(
            base=base, count=count, short=short)
    except Exception as exc:
        print("[cef_version.py] WARNING: git version derivation failed"
              " (%s); using %s.dev0" % (exc, base))
        return base + ".dev0"
