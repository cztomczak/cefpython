# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Common stuff for tools such as automate.py, build.py, etc.

import struct
import platform
import sys
import os
import glob
import re

# Architecture and OS postfixes
ARCH32 = (8 * struct.calcsize('P') == 32)
ARCH64 = (8 * struct.calcsize('P') == 64)
# OS_POSTFIX is for directories/files names in cefpython sources
# OS_POSTFIX2 is for platform name in cefpython binaries
# CEF_POSTFIX2 is for platform name in upstream CEF binaries
OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")
OS_POSTFIX2 = "unknown"
CEF_POSTFIX2 = "unknown"  # Upstream CEF binaries postfix
if OS_POSTFIX == "win":
    OS_POSTFIX2 = "win32" if ARCH32 else "win64"
    CEF_POSTFIX2 = "windows32" if ARCH32 else "windows64"
elif OS_POSTFIX == "mac":
    OS_POSTFIX2 = "mac32" if ARCH32 else "mac64"
    CEF_POSTFIX2 = "macosx32" if ARCH32 else "macosx64"
elif OS_POSTFIX == "linux":
    OS_POSTFIX2 = "linux32" if ARCH32 else "linux64"
    CEF_POSTFIX2 = "linux32" if ARCH32 else "linux64"

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Python version eg. 27
PYVERSION = str(sys.version_info[0])+str(sys.version_info[1])

# Module extension
if WINDOWS:
    MODULE_EXT = "pyd"
else:
    MODULE_EXT = "so"

# CEF Python module name
MODULE_NAME_TEMPLATE = "cefpython_py{pyversion}.{ext}"
MODULE_NAME_TEMPLATE_NOEXT = "cefpython_py{pyversion}"
MODULE_NAME = MODULE_NAME_TEMPLATE.format(pyversion=PYVERSION, ext=MODULE_EXT)
MODULE_NAME_NOEXT = MODULE_NAME_TEMPLATE_NOEXT.format(pyversion=PYVERSION)

# Executable extension
if WINDOWS:
    EXECUTABLE_EXT = ".exe"
elif MAC:
    EXECUTABLE_EXT = ".app"
else:
    EXECUTABLE_EXT = ""

# Library extension
if WINDOWS:
    LIB_EXT = ".lib"
else:
    LIB_EXT = ".a"

# Compiled object extension
if WINDOWS:
    OBJ_EXT = ".obj"
else:
    OBJ_EXT = ".o"

# ----------------------------------------------------------------------------
# Directories
# ----------------------------------------------------------------------------
assert __file__
ROOT_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))

# Build directories
BUILD_DIR = os.path.join(ROOT_DIR, "build")
BUILD_CEFPYTHON = os.path.join(BUILD_DIR, "build_cefpython")

# May be auto-overwritten through detect_cef_binaries_libraries_dir()
CEF_BINARIES_LIBRARIES = os.path.join(BUILD_DIR, "cef_"+OS_POSTFIX2)

# Will be overwritten through detect_cefpython_binary_dir()
CEFPYTHON_BINARY = "CEFPYTHON_BINARY"

# Build C++ projects directories
BUILD_CEFPYTHON_APP = os.path.join(BUILD_CEFPYTHON,
                                   "cefpython_app_py{pyver}_{os}"
                                   .format(pyver=PYVERSION, os=OS_POSTFIX2))
BUILD_CLIENT_HANDLER = os.path.join(BUILD_CEFPYTHON,
                                    "client_handler_py{pyver}_{os}"
                                    .format(pyver=PYVERSION, os=OS_POSTFIX2))
BUILD_CPP_UTILS = os.path.join(BUILD_CEFPYTHON,
                               "cpp_utils_py{pyver}_{os}"
                               .format(pyver=PYVERSION, os=OS_POSTFIX2))
BUILD_SUBPROCESS = os.path.join(BUILD_CEFPYTHON,
                                "subprocess_py{pyver}_{os}"
                                .format(pyver=PYVERSION, os=OS_POSTFIX2))
# -- end build directories

EXAMPLES_DIR = os.path.join(ROOT_DIR, "examples")
SRC_DIR = os.path.join(ROOT_DIR, "src")

# Subdirectories in src/
CLIENT_HANDLER_DIR = os.path.join(SRC_DIR, "client_handler")
CPP_UTILS_DIR = os.path.join(SRC_DIR, "cpp_utils")
LINUX_DIR = os.path.join(SRC_DIR, "linux")
MAC_DIR = os.path.join(SRC_DIR, "mac")
SUBPROCESS_DIR = os.path.join(SRC_DIR, "subprocess")
WINDOWS_DIR = os.path.abspath(os.path.join(SRC_DIR, "windows"))
# -- end subdirectories in src/

TOOLS_DIR = os.path.join(ROOT_DIR, "tools")
INSTALLER_DIR = os.path.join(TOOLS_DIR, "installer")
UNITTESTS_DIR = os.path.abspath(os.path.join(ROOT_DIR, "unittests"))
# ----------------------------------------------------------------------------

# cefpython API header file and a fixed copy of it
CEFPYTHON_API_HFILE = os.path.join(BUILD_CEFPYTHON,
                                   "cefpython_py{pyver}.h"
                                   .format(pyver=PYVERSION))
CEFPYTHON_API_HFILE_FIXED = os.path.join(BUILD_CEFPYTHON,
                                         "cefpython_py{pyver}_fixed.h"
                                         .format(pyver=PYVERSION))

# Result libraries paths
CEFPYTHON_APP_LIB = os.path.join(BUILD_CEFPYTHON_APP,
                                 "cefpython_app" + LIB_EXT)
CLIENT_HANDLER_LIB = os.path.join(BUILD_CLIENT_HANDLER,
                                  "client_handler" + LIB_EXT)
CPP_UTILS_LIB = os.path.join(BUILD_CPP_UTILS,
                             "cpp_utils" + LIB_EXT)
SUBPROCESS_EXE = os.path.join(BUILD_SUBPROCESS,
                              "subprocess" + EXECUTABLE_EXT)

# Visual Studio constants
VS_PLATFORM_ARG = "x86" if ARCH32 else "amd64"

VS2015_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 14.0"
                 "\\VC\\vcvarsall.bat")

# For CEF build
VS2013_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0"
                 "\\VC\\vcvarsall.bat")

# VS2010 vcvarsall not used, using detection with setuptools instead
VS2010_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 10.0"
                 "\\VC\\vcvarsall.bat")

VS2008_VCVARS = ("%LocalAppData%\\Programs\\Common\\Microsoft"
                 "\\Visual C++ for Python\\9.0\\vcvarsall.bat")
VS2008_BUILD = ("%LocalAppData%\\Programs\\Common\\"
                "Microsoft\\Visual C++ for Python\\9.0\\"
                "VC\\bin\\amd64\\vcbuild.exe")
if "LOCALAPPDATA" in os.environ:
    VS2008_VCVARS = VS2008_VCVARS.replace("%LocalAppData%",
                                          os.environ["LOCALAPPDATA"])
    VS2008_BUILD = VS2008_BUILD.replace("%LocalAppData%",
                                        os.environ["LOCALAPPDATA"])


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
        contents = fp.read()  # no need to decode() as "rU" specified
    ret = dict()
    matches = re.findall(r'^#define (\w+) "?([^\s"]+)"?', contents,
                         re.MULTILINE)
    for match in matches:
        ret[match[0]] = match[1]
    return ret


def get_msvs_for_python(vs_prefix=False):
    """Get MSVS version (eg 2008) for current python running."""
    if sys.version_info[:2] == (2, 7):
        return "VS2008" if vs_prefix else "2008"
    elif sys.version_info[:2] == (3, 4):
        return "VS2010" if vs_prefix else "2010"
    elif sys.version_info[:2] == (3, 5):
        return "VS2015" if vs_prefix else "2015"
    elif sys.version_info[:2] == (3, 6):
        return "VS2015" if vs_prefix else "2015"
    else:
        print("ERROR: This version of Python is not supported")
        sys.exit(1)


detect_cef_binaries_libraries_dir()
detect_cefpython_binary_dir()
