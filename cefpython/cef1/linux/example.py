import os
import platform
import subprocess
import sys

BITS = platform.architecture()[0]
assert (BITS == "32bit" or BITS == "64bit")

os.chdir("./binaries_%s" % BITS)

subprocess.call("python wxpython.py", shell=True)
