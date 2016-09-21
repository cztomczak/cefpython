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
    --kivy      Run Kivy example (don't install package)
"""

# TODO: Check Cython version using info from tools/requirements.txt

import sys
import os
import glob
import shutil
import subprocess
import platform
import re

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

if len(sys.argv) > 1 and "--debug" in sys.argv:
    DEBUG = True
    print("DEBUG mode On")
else:
    DEBUG = False

if len(sys.argv) > 1 and "--fast" in sys.argv:
    # Fast mode doesn't delete C++ .o .a files.
    # Fast mode also disables optimization flags in setup/setup.py .
    FAST = True
    print("FAST mode On")
else:
    FAST = False

if len(sys.argv) > 1 and "--kivy" in sys.argv:
    KIVY = True
    print("KIVY mode On")
else:
    KIVY = False

if len(sys.argv) > 1 and re.search(r"^\d+\.\d+$", sys.argv[1]):
    VERSION = sys.argv[1]
else:
    print("[compile.py] ERROR: expected first argument to be version number")
    print("             Allowed version format: \\d+\.\\d+")
    sys.exit(1)

print("VERSION=%s" % VERSION)

BITS = platform.architecture()[0]
assert (BITS == "32bit" or BITS == "64bit")

PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])
print("PYVERSION = %s" % PYVERSION)
print("BITS = %s" % BITS)

print("Compiling C++ projects")

# Need to allow continuing even when make fails, as it may
# fail because the "public" function declaration is not yet
# in "cefpython.h", but for it to be generated we need to run
# cython compiling, so in this case you continue even when make
# fails and then run the compile.py script again and this time
# make should succeed.

os.chdir("./../cpp_utils/")
if not FAST:
    subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    # noinspection PyUnboundLocalVariable
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

os.chdir("./../client_handler/")
if not FAST:
    subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

os.chdir("./../subprocess/")
if not FAST:
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
subprocess_exe = "./../linux/binaries_%s/subprocess" % BITS
if os.path.exists("./subprocess"):
    # .copy() will also copy Permission bits
    shutil.copy("./subprocess", subprocess_exe)

os.chdir("./../linux/")

try:
    os.remove("./binaries_%s/cefpython_py%s.so" % (BITS, PYVERSION))
except OSError:
    pass

os.system("rm -f ./setup/cefpython_py*.so")

pyx_files = glob.glob("./setup/*.pyx")
for f in pyx_files:
    os.remove(f)

try:
    if not FAST:
        shutil.rmtree("./setup/build")
except OSError:
    pass

os.chdir("./setup")

ret = subprocess.call("{python} fix_pyx_files.py"
                      .format(python=sys.executable), shell=True)
if ret != 0:
    sys.exit("ERROR")

# Create __version__.pyx after fix_pyx_files.py was called,
# as that script deletes old pyx files before copying new ones.
print("Creating __version__.pyx file")
with open("__version__.pyx", "w") as fo:
    fo.write('__version__ = "{}"\n'.format(VERSION))

if DEBUG:
    ret = subprocess.call("python-dbg setup.py build_ext --inplace"
                          " --cython-gdb", shell=True)
else:
    if FAST:
        ret = subprocess.call("{python} setup.py build_ext --inplace --fast"
                              .format(python=sys.executable), shell=True)
    else:
        ret = subprocess.call("{python} setup.py build_ext --inplace"
                              .format(python=sys.executable), shell=True)

if DEBUG:
    shutil.rmtree("./../binaries_%s/cython_debug/" % BITS, ignore_errors=True)
    shutil.copytree("./cython_debug/", "./../binaries_%s/cython_debug/" % BITS)

os.chdir("../")

oldpyxfiles = glob.glob("./setup/*.pyx")
print("Removing old pyx files in /setup/: %s" % oldpyxfiles)
for pyxfile in oldpyxfiles:
    if os.path.exists(pyxfile):
        os.remove(pyxfile)

if ret != 0:
    sys.exit("ERROR")

exitcode = os.system("mv ./setup/cefpython_py{0}*.so"
                     " ./binaries_{1}/cefpython_py{0}.so"
                     .format(PYVERSION, BITS))
if exitcode:
    raise RuntimeError("Failed to move the cefpython module")

print("DONE")

if DEBUG:
    os.chdir("./binaries_%s" % BITS)
    subprocess.call("cygdb . --args python-dbg wxpython.py", shell=True)
else:
    if KIVY:
        os.system("{python} binaries_64bit/kivy_.py"
                  .format(python=sys.executable))
    else:
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

        # Make installer, install, run hello world and return to initial dir
        os.system("cd ./installer/ && {python} make-setup.py --version {ver}"
                  " && cd cefpython3-{ver}-*-setup/"
                  " && {sudo} {python} setup.py install"
                  " && cd ../ && {sudo} rm -rf ./cefpython3-{ver}-*-setup/"
                  " && cd ../../../examples/"
                  " && {python} hello_world.py && cd ../src/linux/"
                  .format(python=sys.executable, ver=VERSION, sudo=sudo))
