# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Run all examples that can be run on current configuration
and display a summary at the end.
"""

from common import *

import importlib
import os
import sys


def main():
    os.chdir(EXAMPLES_DIR)

    hello_world_flag = False
    if "--hello-world" in sys.argv:
        sys.argv.remove("--hello-world")
        hello_world_flag = True

    packages = check_installed_packages()
    examples = list()
    examples.append("hello_world.py")
    examples.append("tutorial.py")
    examples.append("screenshot.py")
    succeeded = list()
    failed = list()
    passed = list()

    # wxpython
    if packages["wx"]:
        examples.append("wxpython.py")
    else:
        print("[run_examples.py] PASS: wxpython.py (wxPython not installed)")
        passed.append("wxpython.py")

    # gtk3
    """
    if LINUX:
        # Broken on Linux (Issue #261)
        print("[run_examples.py] PASS: gtk3.py (Issue #261)")
        passed.append("gtk3.py (Issue #261)")
    """

    if MAC:
        # Crashes on Mac (Issue #310)
        print("[run_examples.py] PASS: gtk3.py (Issue #310)")
        passed.append("gtk3.py (Issue #310)")
    elif packages["gi"]:
        examples.append("gtk3.py")
    else:
        print("[run_examples.py] PASS: gtk3.py (Gtk 3 not installed)")
        passed.append("gtk3.py")

    # pyqt6
    if packages["PyQt6"]:
        examples.append("qt.py pyqt6")
    else:
        print("[run_examples.py] PASS: qt.py pyqt6 (PyQt6 not installed)")
        passed.append("qt.py pyqt6")

    # pyside6
    if packages["PySide6"]:
        examples.append("qt.py pyside6")
    else:
        print("[run_examples.py] PASS: qt.py pyside6 (PySide6 not installed)")
        passed.append("qt.py pyside6")

    # tkinter
    if MAC:
        # This example often crashes on Mac (Issue #309)
        print("[run_examples.py] PASS: tkinter_.py (Issue #309)")
        passed.append("tkinter_.py (Issue #309)")
    elif WINDOWS and sys.version_info.major == 2:
        print("[run_examples.py] PASS: tkinter_.py (Issue #441)")
        passed.append("tkinter_.py (Issue #441)")
    elif packages["tkinter"] or packages["Tkinter"]:
        examples.append("tkinter_.py")
    else:
        print(["run_examples.py] PASS: tkinter_.py (tkinter not installed)"])
        passed.append("tkinter_.py")

    # When --hello-world flag is passed run only hello_world.py example
    if hello_world_flag:
        examples = list()
        passed = list()
        examples.append("hello_world.py")

    # Run all
    for example in examples:
        print("[run_examples.py] Running '{example}'..."
              .format(example=example))
        command = "\"{python}\" {example}".format(python=sys.executable,
                                                  example=example)
        ret = os.system(command)
        if ret == 0:
            succeeded.append(example)
        else:
            print("[run_examples.py] ERROR while running example: {example}"
                  .format(example=example))
            failed.append(example)

    # Summary
    summary = ""
    for example in succeeded:
        summary += "  OK    {example}{nl}"\
                   .format(example=example, nl=os.linesep)
    for example in failed:
        summary += "  ERROR {example}{nl}"\
                   .format(example=example, nl=os.linesep)
    for example in passed:
        summary += "  PASS  {example}{nl}"\
                   .format(example=example, nl=os.linesep)
    summary = summary[:-(len(os.linesep))]
    print("[run_examples.py] SUMMARY:")
    print(summary.format())

    # OK or error message
    passed_msg = ""
    if passed:
        passed_msg = ". Passed: {passed}.".format(passed=len(passed))
    if len(failed):
        print("[run_examples.py] ERRORS({failed}) while running examples"
              "{passed_msg}"
              .format(failed=len(failed), passed_msg=passed_msg))
        sys.exit(1)
    else:
        print("[run_examples.py] OK({succeeded}){passed_msg}"
              .format(succeeded=len(succeeded), passed_msg=passed_msg))


def check_installed_packages():
    packages = {
        "gi": False,
        "PyQt6": False,
        "PySide6": False,
        "tkinter": False,
        "Tkinter": False,
        "wx": False,
    }
    for package in packages:
        try:
            importlib.import_module(package)
            packages[package] = True
        except ImportError:
            packages[package] = False
    return packages


if __name__ == "__main__":
    main()
