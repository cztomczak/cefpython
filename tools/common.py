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
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Python version eg. 27
PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])

# Root directory
assert __file__
ROOT_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))

# Other directories
BUILD_DIR = os.path.join(ROOT_DIR, "build")
if BUILD_DIR:
    BUILD_CEFPYTHON = os.path.join(BUILD_DIR, "build_cefpython")
    # -- Auto-detected directories.
    # May be auto-overwritten through detect_cef_binaries_libraries_dir()
    CEF_BINARIES_LIBRARIES = os.path.join(BUILD_DIR, "cef_"+OS_POSTFIX2)
    # Will be overwritten through detect_cefpython_binary_dir()
    CEFPYTHON_BINARY = "CEFPYTHON_BINARY"
EXAMPLES_DIR = os.path.join(ROOT_DIR, "examples")
SRC_DIR = os.path.join(ROOT_DIR, "src")
if SRC_DIR:
    CLIENT_HANDLER_DIR = os.path.join(SRC_DIR, "client_handler")
    CPP_UTILS_DIR = os.path.join(SRC_DIR, "cpp_utils")
    LINUX_DIR = os.path.join(SRC_DIR, "linux")
    MAC_DIR = os.path.join(SRC_DIR, "mac")
    SUBPROCESS_DIR = os.path.join(SRC_DIR, "subprocess")
    WINDOWS_DIR = os.path.abspath(os.path.join(SRC_DIR, "windows"))
TOOLS_DIR = os.path.join(ROOT_DIR, "tools")
if TOOLS_DIR:
    INSTALLER_DIR = os.path.join(TOOLS_DIR, "installer")
UNITTESTS_DIR = os.path.abspath(os.path.join(ROOT_DIR, "unittests"))

# Visual Studio constants
VS_PLATFORM_ARG = "x86" if ARCH32 else "amd64"
VS2015_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 14.0"
                 "\\VC\\vcvarsall.bat")
VS2015_BUILD = ""  # TODO
VS2013_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0"
                 "\\VC\\vcvarsall.bat")
VS2013_BUILD = ""  # TODO
VS2008_VCVARS = ("%LocalAppData%\\Programs\\Common\\Microsoft"
                 "\\Visual C++ for Python\\9.0\\vcvarsall.bat")
VS2008_BUILD = ("%LocalAppData%\\Programs\\Common\\"
                "Microsoft\\Visual C++ for Python\\9.0\\"
                "VC\\bin\\amd64\\vcbuild.exe")


def detect_cef_binaries_libraries_dir():
    """Detect cef binary directory created by automate.py
    eg. build/cef55_3.2883.1553.g80bd606_win32/
    and set CEF_BINARIES_LIBRARIES to it, otherwise it will
    point to eg. build/cef_win32/ ."""
    global CEF_BINARIES_LIBRARIES
    if not os.path.exists(CEF_BINARIES_LIBRARIES):
        version = get_cefpython_version()
        dirs = glob.glob(os.path.join(
                BUILD_DIR,
                "cef{major}_{cef_version}_{os}{sep}"
                .format(major=version["CHROME_VERSION_MAJOR"],
                        cef_version=version["CEF_VERSION"],
                        os=OS_POSTFIX2,
                        sep=os.sep)))
        if len(dirs) == 1:
            CEF_BINARIES_LIBRARIES = os.path.normpath(dirs[0])


def detect_cefpython_binary_dir():
    """Detect cefpython binary directory where cefpython modules
    will be put. Eg. buil/cefpython55_win32/."""
    version = get_cefpython_version()
    binary_dir = "cefpython{major}_{os}".format(
            major=version["CHROME_VERSION_MAJOR"],
            os=OS_POSTFIX2)
    binary_dir = os.path.join(BUILD_DIR, binary_dir)
    global CEFPYTHON_BINARY
    CEFPYTHON_BINARY = binary_dir


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


detect_cef_binaries_libraries_dir()
detect_cefpython_binary_dir()
