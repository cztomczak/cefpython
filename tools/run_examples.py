"""
Run all examples that can be run on current configuration.

Note on GTK 2 / GTK 3 on Windows:
    Installing both PyGTK and PyGI on Windows will cause errors.
    You can install only one of these packages.
"""

from common import *

import importlib
import os
import sys


def main():
    os.chdir(EXAMPLES_DIR)

    packages = check_installed_packages()
    examples = list()
    examples.append("hello_world.py")
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
    if packages["gi"]:
        if not LINUX:
            examples.append("gtk3.py")
        else:
            # Gtk 3 example is currently broken on Linux (Issue #261)
            print("[run_examples.py] PASS: gtk3.py (Issue #261)")
            passed.append("gtk3.py")
    else:
        print("[run_examples.py] PASS: gtk3.py (Gtk 3 not installed)")
        passed.append("gtk3.py")

    # pyqt
    if packages["PyQt4"]:
        examples.append("qt.py pyqt")
    else:
        print("[run_examples.py] PASS: qt.py pyqt (PyQt4 not installed)")
        passed.append("qt.py pyqt")

    # pyside
    if packages["PySide"]:
        examples.append("qt.py pyside")
    else:
        print("[run_examples.py] PASS: qt.py pyside (PySide not installed)")
        passed.append("qt.py pyside")

    # tkinter
    if packages["tkinter"] or packages["Tkinter"]:
        examples.append("tkinter_.py")
    else:
        print(["run_examples.py] PASS: tkinter_.py (tkinter not installed)"])
        passed.append("tkinter_.py")

    # kivy
    if LINUX and packages["kivy"] and packages["gtk"]:
        if "--kivy" in sys.argv:
            # When --kivy flag passed run only Kivy example
            examples = list()
            passed = list()
        examples.append("{linux_dir}/binaries_64bit/kivy_.py"
                        .format(linux_dir=LINUX_DIR))

    # Run all
    for example in examples:
        print("[run_examples.py] Running '{example}'..."
              .format(example=example))
        ret = os.system("{python} {example}"
                        .format(python=sys.executable, example=example))
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
        "gi": False,
        "kivy": False,
        "PyQt4": False,
        "PySide": False,
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
