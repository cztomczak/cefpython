import sys
import os
import glob
import shutil
import subprocess
import platform
import stat

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

if len(sys.argv) > 1 and sys.argv[1] == "debug":
    DEBUG = True
    print("DEBUG mode On")
else:
    DEBUG = False

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
subprocess_exe = "./../linux/binaries_%s/subprocess" % (BITS)
shutil.copyfile("./subprocess", subprocess_exe)
st = os.stat(subprocess_exe)
os.chmod(subprocess_exe, st.st_mode | stat.S_IEXEC)



# os.chdir("./../v8function_handler/")
# ret = subprocess.call("make -f Makefile", shell=True)
# if ret != 0:
#     what = raw_input("make failed, press 'y' to continue, 'n' to stop: ")
#     if what != "y":
#         sys.exit(1)

os.chdir("./../linux/")

try:
    os.remove("./binaries_%s/cefpython_py%s.so" % (BITS, PYVERSION))
except OSError:
    pass

try:
    os.remove("./setup/cefpython_py%s.so" % PYVERSION)
    os.remove("./setup/cefpython_py%s_d.so" % PYVERSION)
except OSError:
    pass

pyx_files = glob.glob("./setup/*.pyx")
for f in pyx_files:
    os.remove(f)

try:
    shutil.rmtree("./setup/build")
except OSError:
    pass

os.chdir("./setup")

ret = subprocess.call("python fix_includes.py", shell=True)
if ret != 0:
    sys.exit("ERROR")

if DEBUG:
    ret = subprocess.call("python-dbg setup.py build_ext --inplace"
            " --cython-gdb", shell=True)
else:
    ret = subprocess.call("python setup.py build_ext --inplace", shell=True)

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

if DEBUG:
    os.rename("./setup/cefpython_py%s_d.so" % PYVERSION, "./binaries_%s/cefpython_py%s.so" % (BITS, PYVERSION))
else:
    os.rename("./setup/cefpython_py%s.so" % PYVERSION, "./binaries_%s/cefpython_py%s.so" % (BITS, PYVERSION))

print("DONE")

os.chdir("./binaries_%s" % BITS)
if DEBUG:
    subprocess.call("cygdb . --args python-dbg wxpython.py", shell=True)
else:
    subprocess.call("python wxpython.py", shell=True)
