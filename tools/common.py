# Common stuff for tools: automate.py, build.py, build_module.py

import struct
import platform
import sys
import os
import glob
import re

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

# Platforms
LINUX = (platform.system() == "Linux")
WINDOWS = (platform.system() == "Windows")
MAC = (platform.system() == "Darwin")

# Python version eg. 27
PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])

# Directories
TOOLS_DIR = os.path.abspath(os.path.dirname(__file__))
SRC_DIR = os.path.abspath(os.path.join(TOOLS_DIR, "../src"))
WINDOWS_DIR = os.path.abspath(os.path.join(SRC_DIR, "windows"))
MAC_DIR = os.path.abspath(os.path.join(SRC_DIR, "mac"))
LINUX_DIR = os.path.abspath(os.path.join(SRC_DIR, "linux"))
CPP_UTILS_DIR = os.path.abspath(os.path.join(SRC_DIR, "cpp_utils"))
CLIENT_HANDLER_DIR = os.path.abspath(os.path.join(SRC_DIR, "client_handler"))
SUBPROCESS_DIR = os.path.abspath(os.path.join(SRC_DIR, "subprocess"))
CEFPYTHON_DIR = os.path.abspath(os.path.join(SRC_DIR, ".."))
EXAMPLES_DIR = os.path.abspath(os.path.join(CEFPYTHON_DIR, "examples"))
UNITTESTS_DIR = os.path.abspath(os.path.join(CEFPYTHON_DIR, "unittests"))
BUILD_DIR = os.path.abspath(os.path.join(CEFPYTHON_DIR, "build"))
BUILD_CEFPYTHON = os.path.abspath(os.path.join(BUILD_DIR, "build_cefpython"))
# CEF_BINARY may be auto-overwritten through detect_cef_binary_directory()
CEF_BINARY = os.path.abspath(os.path.join(BUILD_DIR, "cef_"+OS_POSTFIX2))
CEFPYTHON_BINARY = os.path.abspath(os.path.join(BUILD_DIR,
                                                "cefpython_"+OS_POSTFIX2))


def detect_cef_binary_directory():
    # Detect cef binary directory created by automate.py
    # eg. build/cef55_3.2883.1553.g80bd606_win32/
    # and set CEF_BINARY to it. Otherwise CEF_BINARY will
    # indicate to build/cef_{os_postfix2}/.
    if not os.path.exists(CEF_BINARY):
        version = get_cefpython_version()
        dirs = glob.glob(os.path.join(
                BUILD_DIR,
                "cef{major}_{cef_version}_{os}{sep}"
                .format(major=version["CHROME_VERSION_MAJOR"],
                        cef_version=version["CEF_VERSION"],
                        os=OS_POSTFIX2,
                        sep=os.sep)))
        if len(dirs) == 1:
            print("[common.py] Auto detected CEF_BINARY directory: {dir}"
                  .format(dir=dirs[0]))
            global CEF_BINARY
            CEF_BINARY = dirs[0]


def get_cefpython_version():
    """Get CEF version from the 'src/version/' directory."""
    header_file = os.path.join(SRC_DIR, "version",
                               "cef_version_"+OS_POSTFIX+".h")
    return get_version_from_file(header_file)


def get_version_from_file(header_file):
    with open(header_file, "rU") as fp:
        contents = fp.read()
    ret = dict()
    matches = re.findall(r'^#define (\w+) "?([^\s"]+)"?', contents,
                         re.MULTILINE)
    for match in matches:
        ret[match[0]] = match[1]
    return ret


detect_cef_binary_directory()
