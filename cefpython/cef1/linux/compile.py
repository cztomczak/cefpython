import sys
import os
import glob
import shutil
import subprocess
import platform

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

ret = subprocess.call(["python", "./fix_includes.py"])
if ret != 0:
    sys.exit("ERROR")

if DEBUG:
    ret = subprocess.call(["python-dbg", "setup.py", "build_ext", "--inplace", "--cython-gdb"])
else:
    ret = subprocess.call(["python", "setup.py", "build_ext", "--inplace"])

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

shutil.copyfile("./../../cef1_api.py", "./binaries_%s/cefpython_py%s.py" % (BITS, PYVERSION))

print("DONE")

os.chdir("./binaries_%s" % BITS)
if DEBUG:
    subprocess.call(["cygdb", ".", "--args", "python-dbg", "wxpython.py"])
else:
    subprocess.call(["python", "./wxpython.py"])
