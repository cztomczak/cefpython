import sys
import os
import glob
import shutil
import subprocess
import platform
import stat
import re

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

if len(sys.argv) > 1 and re.search(r"^\d+\.\d+$", sys.argv[1]):
    VERSION = sys.argv[1]
else:
    print("[compile.py] ERROR: expected first argument to be version number")
    print("             Allowed version format: \\d+\.\\d+")
    sys.exit(1)

print("VERSION=%s"%VERSION)

BITS = platform.architecture()[0]
assert (BITS == "32bit" or BITS == "64bit")
PYTHON_CMD = "python"
if sys.maxint == 2147483647:
    BITS = "32bit"
    PYTHON_CMD = "arch -i386 python"

if BITS == "32bit":
    if "i386" not in os.getenv("ARCHFLAGS", ""):
        raise Exception("Detected Python 32bit, but ARCHFLAGS is not i386")
    if "i386" not in os.getenv("CEF_CCFLAGS", ""):
        raise Exception("Detected Python 32bit, but CEF_CCFLAGS is not i386")
elif BITS == "64bit":
    if "x86_64" not in os.getenv("ARCHFLAGS", ""):
        raise Exception("Detected Python 64bit, but ARCHFLAGS is not x86_64")
    if "x86_64" not in os.getenv("CEF_CCFLAGS", ""):
        raise Exception("Detected Python 64bit, but CEF_CCFLAGS is not x86_64")

PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])
print("PYVERSION = %s" % PYVERSION)
print("BITS = %s" % BITS)

os.environ["CC"] = "gcc"
os.environ["CXX"] = "g++"

print("Compiling C++ projects")

# Need to allow continuing even when make fails, as it may
# fail because the "public" function declaration is not yet
# in "cefpython.h", but for it to be generated we need to run
# cython compiling, so in this case you continue even when make
# fails and then run the compile.py script again and this time
# make should succeed.

os.chdir("./../../cpp_utils/")
subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

os.chdir("./../cef3/client_handler/")
subprocess.call("rm -f *.o *.a", shell=True)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

os.chdir("./../subprocess/")
subprocess.call("rm -f *.o *.a", shell=True)
subprocess.call("rm -f subprocess", shell=True)

ret = subprocess.call("make -f Makefile-libcefpythonapp", shell=True)
if ret != 0:
    what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)

ret = subprocess.call("make -f Makefile", shell=True)
if ret != 0:
    what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
    if what != "y":
        sys.exit(1)
subprocess_exe = "./../mac/binaries_%s/subprocess" % (BITS)
if os.path.exists("./subprocess"):
    # .copy() will also copy Permission bits
    shutil.copy("./subprocess", subprocess_exe)

# os.chdir("./../v8function_handler/")
# ret = subprocess.call("make -f Makefile", shell=True)
# if ret != 0:
#     what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
#     if what != "y":
#         sys.exit(1)

os.chdir("./../mac/")

try:
    os.remove("./binaries_%s/cefpython_py%s.so" % (BITS, PYVERSION))
except OSError:
    pass

os.system("rm ./setup/cefpython_py*.so")

pyx_files = glob.glob("./setup/*.pyx")
for f in pyx_files:
    os.remove(f)

try:
    shutil.rmtree("./setup/build")
except OSError:
    pass

os.chdir("./setup")

ret = subprocess.call(PYTHON_CMD+" fix_pyx_files.py", shell=True)
if ret != 0:
    sys.exit("ERROR")

# Create __version__.pyx after fix_pyx_files.py was called,
# as that script deletes old pyx files before copying new ones.
print("Creating __version__.pyx file")
with open("__version__.pyx", "w") as fo:
    fo.write('__version__ = "{}"\n'.format(VERSION))

if DEBUG:
    ret = subprocess.call(PYTHON_CMD+"-dbg setup.py build_ext --inplace"
            " --cython-gdb", shell=True)
else:
    ret = subprocess.call(PYTHON_CMD+" setup.py build_ext --inplace", shell=True)

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

os.chdir("./binaries_%s" % BITS)
if DEBUG:
    subprocess.call("cygdb . --args python-dbg wxpython.py", shell=True)
else:
    subprocess.call(PYTHON_CMD+" wxpython.py", shell=True)
