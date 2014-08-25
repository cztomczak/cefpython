# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Compile cefptython.rc to a .res object.
# In setup.py the .res object is added to Extension."extra_objects".

import os
import sys
import re
import subprocess
import shutil

PYVERSION = str(sys.version_info[0])+str(sys.version_info[1]) # eg. "27"
RC_EXE = r"C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\rc.exe"
RC_FILE = os.path.abspath(r"../cefpython.rc")
RES_FILE_OUT = os.path.abspath(r"../cefpython.res")
RES_FILE_MOVE = os.path.abspath(r"./cefpython.res")
RC_PYD_NAME = r"cefpython_py27.pyd"

def log(msg):
    print("[compile_rc.py] %s" % str(msg))

def main():
    # Arguments
    if len(sys.argv) == 3 \
            and sys.argv[1] == "-v"  \
            and re.search(r"^\d+\.\d+$", sys.argv[2]):
        version = sys.argv[2]
    else:
        log("Invalid version string or missing. Usage: compile_rc.py -v 31.0")
        exit(1)

    # Print paths
    log("version="+version)
    log("PYVERSION="+PYVERSION)
    log("RC_EXE="+RC_EXE)
    log("RC_FILE="+RC_FILE)
    log("RES_FILE_OUT="+RES_FILE_OUT)
    log("RES_FILE_MOVE="+RES_FILE_MOVE)
    log("RC_PYD_NAME="+RC_PYD_NAME)

    # Check paths
    assert os.path.exists(RC_EXE)
    assert os.path.exists(RC_FILE)
    
    # Change version numbers in .rc file
    with open(RC_FILE, "r") as f:
        contents = f.read()
    # FILEVERSION     31,1,0,0
    # "FileVersion", "31.1.0.0"
    (contents, subn) = re.subn(
            r"\d+\.\d+\.\d+\.\d+",
            r"%s.0.0" % version,
            contents)
    assert subn == 2, "Replacing dots versions failed (rc file)"
    version_commas = re.sub(r"\.", r",", version)
    (contents, subn) = re.subn(
            r"\d+,\d+,\d+,\d+",
            r"%s,0,0" % version_commas,
            contents)
    assert subn == 2, "Replacing commas verions failed (rc file)"

    # Change pyd module name in .rc
    assert contents.find(RC_PYD_NAME) != -1, "pyd file name not found in .rc"
    assert RC_PYD_NAME.find("py27") != -1, "invalid pyd file name defined"
    new_pyd_name = RC_PYD_NAME.replace("py27", "py"+PYVERSION)
    contents = contents.replace(RC_PYD_NAME, new_pyd_name)

    # Save modified .rc file
    log("Saving modified %s" % RC_FILE)
    with open(RC_FILE, "w") as f:
        f.write(contents)

    log("Calling rc.exe to compile .rc file")
    # rc.exe usage: rc.exe /x file.rc
    # /x - ignore INCLUDE environment variable
    exit_status = subprocess.call([
            RC_EXE,
            "/x",
            RC_FILE,
            ], shell=True)
    if exit_status != 0:
        raise Exception("Calling rc.exe failed")

    log("Moving .res object to setup/")
    shutil.move(RES_FILE_OUT, RES_FILE_MOVE)


if __name__ == '__main__':
    main()
