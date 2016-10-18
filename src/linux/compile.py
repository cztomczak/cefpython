"""
Build the cefpython module, install package and run example.

Usage:
    compile.py VERSION [--debug] [--fast]

Options:
    VERSION     Version in format xx.xx
    --debug     Debug mode
    --fast      Fast mode, don't delete C++ .o .a files, nor the setup/build/
                directory, and disable optimization flags when building
                the so/pyd module.
    --kivy      Run Kivy example
"""

# TODO: Check Cython version using info from tools/requirements.txt

import sys
import os
import glob
import shutil
import subprocess
import platform
import re
import struct

# raw_input() was renamed to input() in Python 3

try:
    # noinspection PyUnresolvedReferences
    # noinspection PyShadowingBuiltins
    input = raw_input
except NameError:
    pass

# This will not show "Segmentation fault" error message:
# | subprocess.call(["python", "./wxpython.py"])
# You need to call it with shell=True for this kind of
# error message to be shown:
# | subprocess.call("python wxpython.py", shell=True)

# How to debug:
# 1. Install "python-dbg" package
# 2. Install "python-wxgtk2.8-dbg" package
# 3. Run "python compile.py debug"
# 4. In cygdb type "cy run"
# 5. To display debug backtrace type "cy bt"
# 6. More commands: http://docs.cython.org/src/userguide/debugging.html

# -- debug flag
if len(sys.argv) > 1 and "--debug" in sys.argv:
    DEBUG_FLAG = True
    print("DEBUG mode On")
else:
    DEBUG_FLAG = False

# --fast flag
if len(sys.argv) > 1 and "--fast" in sys.argv:
    # Fast mode doesn't delete C++ .o .a files.
    # Fast mode also disables optimization flags in setup/setup.py .
    FAST_FLAG = True
    print("FAST mode On")
else:
    FAST_FLAG = False

# --kivy flag
if len(sys.argv) > 1 and "--kivy" in sys.argv:
    KIVY_FLAG = True
    print("KIVY_FLAG flag enabled")
else:
    KIVY_FLAG = False


# version arg
if len(sys.argv) > 1 and re.search(r"^\d+\.\d+$", sys.argv[1]):
    VERSION = sys.argv[1]
else:
    print("[compile.py] ERROR: expected first argument to be version number")
    print("             Allowed version format: \\d+\.\\d+")
    sys.exit(1)

print("VERSION=%s" % VERSION)

# Architecture and OS postfixes
ARCH32 = (8 * struct.calcsize('P') == 32)
ARCH64 = (8 * struct.calcsize('P') == 64)
OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")
OS_POSTFIX2 = "unknown"
if OS_POSTFIX == "win":
    OS_POSTFIX2 = "win32" if ARCH32 else "win64"
elif OS_POSTFIX == "mac":
    OS_POSTFIX2 = "mac32" if ARCH32 else "mac64"
elif OS_POSTFIX == "linux":
    OS_POSTFIX2 = "linux32" if ARCH32 else "linux64"

PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])
print("PYVERSION = %s" % PYVERSION)
print("OS_POSTFIX2 = %s" % OS_POSTFIX2)

# Directories
LINUX_DIR = os.path.abspath(os.path.dirname(__file__))
SRC_DIR = os.path.abspath(os.path.join(LINUX_DIR, ".."))
CPP_UTILS_DIR = os.path.abspath(os.path.join(SRC_DIR, "cpp_utils"))
CLIENT_HANDLER_DIR = os.path.abspath(os.path.join(SRC_DIR, "client_handler"))
SUBPROCESS_DIR = os.path.abspath(os.path.join(SRC_DIR, "subprocess"))
SETUP_DIR = os.path.abspath(os.path.join(LINUX_DIR, "setup"))
CEFPYTHON_DIR = os.path.abspath(os.path.join(SRC_DIR, ".."))
BUILD_DIR = os.path.abspath(os.path.join(CEFPYTHON_DIR, "build"))
CEF_BINARY = os.path.abspath(os.path.join(BUILD_DIR, "cef_"+OS_POSTFIX2))
CEFPYTHON_BINARY = os.path.abspath(os.path.join(BUILD_DIR,
                                                "cefpython_"+OS_POSTFIX2))

# Create directories if necessary
if not os.path.exists(CEFPYTHON_BINARY):
    os.mkdir(CEFPYTHON_BINARY)

# Check directories
assert os.path.exists(CEF_BINARY)
assert os.path.exists(CEFPYTHON_BINARY)

print("Compiling C++ projects")

# Need to allow continuing even when make fails, as it may
# fail because the "public" function declaration is not yet
# in "cefpython.h", but for it to be generated we need to run
# cython compiling, so in this case you continue even when make
# fails and then run the compile.py script again and this time
# make should succeed.

# -------- CPP_UTILS_DIR

os.chdir(CPP_UTILS_DIR)
if not FAST_FLAG:
    subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    # noinspection PyUnboundLocalVariable
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

# -------- CLIENT_HANDLER_DIR

os.chdir(CLIENT_HANDLER_DIR)
if not FAST_FLAG:
    subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

# -------- SUBPROCESS_DIR

os.chdir(SUBPROCESS_DIR)
if not FAST_FLAG:
    subprocess.call("rm -f *.o *.a", shell=True)
    subprocess.call("rm -f subprocess", shell=True)

ret = subprocess.call("make -f Makefile-libcefpythonapp", shell=True)
if ret != 0:
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)
subprocess_exe = os.path.join(CEFPYTHON_BINARY, "subprocess")
if os.path.exists("./subprocess"):
    # .copy() will also copy Permission bits
    shutil.copy("./subprocess", subprocess_exe)

# -------- LINUX_DIR

os.chdir(LINUX_DIR)
try:
    cefpython_module = os.path.join(CEFPYTHON_BINARY,
                                    "cefpython_py{0}.so".format(PYVERSION))
    os.remove(cefpython_module)
except OSError:
    pass


# -------- SETUP_DIR

os.chdir(SETUP_DIR)

os.system("rm -f ./cefpython_py*.so")

pyx_files = glob.glob("./*.pyx")
for f in pyx_files:
    os.remove(f)

try:
    if not FAST_FLAG:
        shutil.rmtree(os.path.join(SETUP_DIR, "build"))
except OSError:
    pass

ret = subprocess.call("{python} fix_pyx_files.py"
                      .format(python=sys.executable), shell=True)
if ret != 0:
    sys.exit("ERROR")

# Create __version__.pyx after fix_pyx_files.py was called,
# as that script deletes old pyx files before copying new ones.
print("Creating __version__.pyx file")
with open("__version__.pyx", "w") as fo:
    fo.write('__version__ = "{}"\n'.format(VERSION))

# if DEBUG_FLAG:
#     ret = subprocess.call("python-dbg setup.py build_ext --inplace"
#                           " --cython-gdb", shell=True)
if FAST_FLAG:
    ret = subprocess.call("{python} setup.py build_ext --inplace --fast"
                          .format(python=sys.executable), shell=True)
else:
    ret = subprocess.call("{python} setup.py build_ext --inplace"
                          .format(python=sys.executable), shell=True)

# if DEBUG_FLAG:
#     shutil.rmtree("./../binaries_%s/cython_debug/" % BITS,
#                   ignore_errors=True)
#     shutil.copytree("./cython_debug/",
#                     "./../binaries_%s/cython_debug/" % BITS)

oldpyxfiles = glob.glob("./*.pyx")
print("Removing old pyx files in /setup/: %s" % oldpyxfiles)
for pyxfile in oldpyxfiles:
    if os.path.exists(pyxfile):
        os.remove(pyxfile)

if ret != 0:
    sys.exit("ERROR")

exitcode = os.system("mv ./cefpython_py{pyver}*.so"
                     " {cefpython_binary}/cefpython_py{pyver}.so"
                     .format(pyver=PYVERSION,
                             cefpython_binary=CEFPYTHON_BINARY))
if exitcode:
    raise RuntimeError("Failed to move the cefpython module")

print("DONE")

# -------- LINUX_DIR

os.chdir(LINUX_DIR)

# if DEBUG_FLAG:
#     os.chdir("./binaries_%s" % BITS)
#     subprocess.call("cygdb . --args python-dbg wxpython.py", shell=True)

print("Make installer and run setup.py install...")

# Clean installer directory from previous run
exit_code = os.system("rm -rf ./installer/cefpython3-{ver}-*-setup/"
                      .format(ver=VERSION))
if exit_code:
    os.system("sudo rm -rf ./installer/cefpython3-{ver}-*-setup/"
              .format(ver=VERSION))

# System python requires sudo when installing package
if sys.executable in ["/usr/bin/python", "/usr/bin/python3"]:
    sudo = "sudo"
else:
    sudo = ""

# Make installer, install, run examples and unit tests,
# and return to src/linux/ dir.
if KIVY_FLAG:
    run_examples = " && {python} kivy_.py"
else:
    run_examples = (" && {python} hello_world.py"
                    " && {python} gtk.py"
                    " && {python} tkinter_.py")
commands = ("cd ./installer/"
            " && {python} make-setup.py --version {ver}"
            " && cd cefpython3-{ver}-*-setup/"
            " && {sudo} {python} setup.py install"
            " && cd ../"
            " && {sudo} rm -rf ./cefpython3-{ver}-*-setup/"
            " && cd ../../../examples/"
            + run_examples +
            " && cd ../unittests/"
            " && {python} _test_runner.py"
            " && cd ../src/linux/")
os.system(commands.format(python=sys.executable, ver=VERSION, sudo=sudo))
