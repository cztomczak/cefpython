# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Read CEF version fields from the per-platform src/version/cef_version_*.h.

Deliberately side-effect-free (no import of common.py, no filesystem or argv
work at import time) so it can be shared by common.py and by the standalone
build scripts (build.py, build_distrib.py, cmake_prepare_pyx.py) without pulling
in common.py's import-time path detection.
"""

import os
import re
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
