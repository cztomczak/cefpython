# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Run all examples that can be run on current configuration
and display a summary at the end.

Note on GTK 2 / GTK 3 on Windows:
    Installing both PyGTK and PyGI on Windows will cause errors.
    You can install only one of these packages.
"""

from common import *

import importlib
import os
import subprocess
import sys


def main():
    os.chdir(EXAMPLES_DIR)

    # When importing Kivy package there can't be any flags unknown to Kivy,
    # use sys.argv.remove to remove them.

    kivy_flag = False
    if "--kivy" in sys.argv:
        sys.argv.remove("--kivy")
        kivy_flag = True

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

    # gtk2
    if packages["gtk"]:
        examples.append("gtk2.py")
        if LINUX:
            examples.append("gtk2.py --message-loop-cef")
    else:
        print("[run_examples.py] PASS: gtk2.py (Gtk 2 not installed")
        passed.append("gtk2.py")

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

    # pyqt4
    if LINUX:
        print("[run_examples.py] PASS: qt.py pyqt4 (Issue #452)")
        passed.append("qt.py pyqt4 (Issue #452)")
    elif packages["PyQt4"]:
        examples.append("qt.py pyqt4")
    else:
        print("[run_examples.py] PASS: qt.py pyqt4 (PyQt4 not installed)")
        passed.append("qt.py pyqt4")

    # pyqt5
    if packages["PyQt5"]:
        examples.append("qt.py pyqt5")
    else:
        print("[run_examples.py] PASS: qt.py pyqt5 (PyQt5 not installed)")
        passed.append("qt.py pyqt5")

    # pyside
    if LINUX:
        print("[run_examples.py] PASS: qt.py pyside (Issue #452)")
        passed.append("qt.py pyside (Issue #452)")
    elif packages["PySide"]:
        examples.append("qt.py pyside")
    else:
        print("[run_examples.py] PASS: qt.py pyside (PySide not installed)")
        passed.append("qt.py pyside")

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

    if LINUX and packages["kivy"] and packages["gtk"]:
        # When --kivy flag passed run only Kivy example
        if kivy_flag:
            examples = list()
            passed = list()
        examples.append("{linux_dir}/binaries_64bit/kivy_.py"
                        .format(linux_dir=LINUX_DIR))

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
        "gtk": False,
        "kivy": False,
        "PyQt4": False,
        "PyQt5": False,
        "PySide": False,
        "tkinter": False,
        "Tkinter": False,
        "wx": False,
    }
    for package in packages:
        try:
            if package == "PyQt5":
                # Strange issue on Mac, PyQt5 is an empty built-in module
                from PyQt5 import QtGui
            else:
                importlib.import_module(package)
                packages[package] = True
        except ImportError:
            packages[package] = False
    packages["gi"] = check_gi_installed()
    return packages


def check_gi_installed():
    # Cannot import both gtk and gi in the same script, thus
    # need another way of checking if gi package is installed.
    code = subprocess.call([sys.executable, "-c", "import gi"])
    if code != 0:
        print("[run_examples.py] gi module not found (PyGI / GTK 3).")
        print("                  Import error above can be safely ignored.")
    return True if code == 0 else False


if __name__ == "__main__":
    main()
