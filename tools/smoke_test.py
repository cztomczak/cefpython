#!/usr/bin/env python3
# Copyright (c) 2026 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Headless CI smoke-test harness for the standalone examples.

Runs each example in examples/ in its own subprocess (CEF cannot be
re-initialized within a single process) and checks the exit code. The example
files are run *unmodified*: a small bootstrap monkey-patches, before the example
runs, cef.Initialize() to merge in the platform-specific switches the unit tests
use (so it works headless under CI: Xvfb on Linux, single-process on macOS for
unsigned CI processes, etc.) and cef.MessageLoop() to auto-close after a few
seconds so the example exits on its own.

This is separate from tools/run_examples.py, which stays for interactive use.

Exit code:
    0  every example launched and exited 0
    1  one or more examples failed, timed out, or crashed

Usage (CI):
    Linux:         xvfb-run python tools/smoke_test.py
    macOS/Windows: python tools/smoke_test.py
"""
import json
import os
import subprocess
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXAMPLES_DIR = os.path.join(REPO_ROOT, "examples")

# Pure-cefpython examples (no third-party GUI toolkit) that drive cef.MessageLoop().
EXAMPLES = ["hello_world.py", "tutorial.py"]

# The example closes itself this long after its message loop starts.
AUTO_CLOSE_MS = 5000
# Backstop against a hung example; CI also caps the step via timeout-minutes.
PER_EXAMPLE_TIMEOUT_S = 90

LINUX = sys.platform.startswith("linux")
MAC = sys.platform == "darwin"


def _ci_switches():
    """Per-platform switches needed to run headless / unsigned under CI.
    Mirrors the switches applied by unittests/main_test.py."""
    if LINUX:
        return {
            "disable-setuid-sandbox": "",
            "disable-dev-shm-usage": "",
            "disable-gpu": "",
            "disable-gpu-compositing": "",
            "in-process-gpu": "",
            "no-zygote": "",
            "ozone-platform": "x11",
            "enable-features": "NetworkServiceInProcess2",
            "password-store": "basic",
        }
    if MAC:
        return {
            "no-sandbox": "",
            "disable-gpu": "",
            "disable-gpu-compositing": "",
            "in-process-gpu": "",
            "use-mock-keychain": "",
            # An unsigned CI process can't spawn the renderer subprocess (Mach
            # port rendezvous fails), so run it in the browser process instead.
            "single-process": "",
            "js-flags": "--jitless",
            "enable-features": "NetworkServiceInProcess2",
        }
    return {}  # Windows needs no special switches.


# Bootstrap run inside each example's subprocess. Patches the two entry points
# the examples use, then runs the example file as __main__. argv:
#   [1] = JSON of the CI switches, [2] = example .py path, [3] = auto-close ms
_BOOTSTRAP = r"""
import json, runpy, sys
from cefpython3 import cefpython as cef
_switches = json.loads(sys.argv[1])
_example = sys.argv[2]
_auto_close_ms = int(sys.argv[3])

_orig_initialize = cef.Initialize
def _initialize(*args, **kwargs):
    user = kwargs.pop("switches", None)
    if user is None:
        user = kwargs.pop("commandLineSwitches", None)
    merged = dict(user or {})
    merged.update(_switches)
    return _orig_initialize(*args, switches=merged, **kwargs)
cef.Initialize = _initialize

_orig_message_loop = cef.MessageLoop
def _message_loop():
    cef.PostDelayedTask(cef.TID_UI, _auto_close_ms, cef.QuitMessageLoop)
    _orig_message_loop()
cef.MessageLoop = _message_loop

sys.argv = [_example]
runpy.run_path(_example, run_name="__main__")
"""


def main():
    switches_json = json.dumps(_ci_switches())
    failures = []
    for name in EXAMPLES:
        path = os.path.join(EXAMPLES_DIR, name)
        print("[smoke_test] running examples/{0} ...".format(name), flush=True)
        cmd = [sys.executable, "-c", _BOOTSTRAP,
               switches_json, path, str(AUTO_CLOSE_MS)]
        try:
            # cwd = examples/ so `import cefpython3` resolves to the installed
            # wheel (site-packages) rather than the repo's build directory.
            ret = subprocess.run(cmd, cwd=EXAMPLES_DIR,
                                 timeout=PER_EXAMPLE_TIMEOUT_S)
        except subprocess.TimeoutExpired:
            print("[smoke_test] FAIL examples/{0} (timeout)".format(name))
            failures.append(name)
            continue
        if ret.returncode == 0:
            print("[smoke_test] OK   examples/{0}".format(name))
        else:
            print("[smoke_test] FAIL examples/{0} (exit {1})".format(
                name, ret.returncode))
            failures.append(name)

    if failures:
        print("[smoke_test] FAILED: " + ", ".join(failures))
        sys.exit(1)
    print("[smoke_test] OK: all examples passed")


if __name__ == "__main__":
    main()
