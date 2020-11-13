# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Common stuff for tools such as automate.py, build.py, etc.

import atexit
import glob
import os
import platform
import re
import shutil
import struct
import sys
import tempfile

# These sample apps will be deleted when creating setup/wheel packages
CEF_SAMPLE_APPS = ["cefclient", "cefsimple", "ceftests", "chrome-sandbox"]

# Python architecture and OS postfixes
ARCH32 = (8 * struct.calcsize('P') == 32)
ARCH64 = (8 * struct.calcsize('P') == 64)
# Make sure platform.architecture()[0] shows correctly 32bit when
# running Python 32bit on Windows 64bit.
if ARCH32:
    assert platform.architecture()[0] == "32bit"
if ARCH64:
    assert platform.architecture()[0] == "64bit"
ARCH_STR = platform.architecture()[0]

# Operating system architecture
SYSTEM64 = platform.machine().endswith('64')
SYSTEM32 = not SYSTEM64

# OS_POSTFIX is for directories/files names in cefpython sources
#            and doesn't include architecture type, just OS name.

# OS_POSTFIX2 is for platform name in cefpython binaries
#             and includes architecture type (32bit/64bit).

# CEF_POSTFIX2 is for platform name in upstream CEF binaries
#              and includes architecture type (32bit/64bit).

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
SYSTEM = platform.system().upper()
if SYSTEM == "DARWIN":
    SYSTEM = "MAC"
WINDOWS = SYSTEM if SYSTEM == "WINDOWS" else False
LINUX = SYSTEM if SYSTEM == "LINUX" else False
MAC = SYSTEM if SYSTEM == "MAC" else False

OS_POSTFIX2_ARCH = dict(
    WINDOWS={"32bit": "win32", "64bit": "win64"},
    LINUX={"32bit": "linux32", "64bit": "linux64"},
    MAC={"32bit": "mac32", "64bit": "mac64"},
)
CEF_POSTFIX2_ARCH = dict(
    WINDOWS={"32bit": "windows32", "64bit": "windows64"},
    LINUX={"32bit": "linux32", "64bit": "linux64"},
    MAC={"64bit": "macosx64"},
)
PYPI_POSTFIX2_ARCH = dict(
    WINDOWS={"32bit": "win32", "64bit": "win_amd64"},
    LINUX={"32bit": "manylinux1_i686", "64bit": "manylinux1_x86_64"},
    MAC={"64bit": "x86_64"},
)

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

# App and Executable extensions
if WINDOWS:
    APP_EXT = ".exe"
    EXECUTABLE_EXT = ".exe"
elif MAC:
    APP_EXT = ".app"  # cefclient, cefsimple, ceftests
    EXECUTABLE_EXT = ""  # subprocess
else:
    APP_EXT = ""
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

# API reference and docs
API_DIR = os.path.join(ROOT_DIR, "api")
DOCS_DIR = os.path.join(ROOT_DIR, "docs")

# Build directories
BUILD_DIR = os.path.join(ROOT_DIR, "build")
BUILD_CEFPYTHON = os.path.join(BUILD_DIR, "build_cefpython")

# May be auto-overwritten through detect_cef_binaries_libraries_dir()
CEF_BINARIES_LIBRARIES = os.path.join(BUILD_DIR, "cef_"+OS_POSTFIX2)

# Will be overwritten through detect_cefpython_binary_dir()
CEFPYTHON_BINARY = "CEFPYTHON_BINARY_NOTSET"

# Distrib directory
DISTRIB_DIR = os.path.join(BUILD_DIR, "DISTRIB_NOTSET")

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
SNIPPETS_DIR = os.path.join(EXAMPLES_DIR, "snippets")
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


# Auto cleanup in the examples/ directory, so that build scripts
# do not include trash directories. See Issue #432.

shutil.rmtree(os.path.join(EXAMPLES_DIR, "blob_storage"),
              ignore_errors=True)
shutil.rmtree(os.path.join(EXAMPLES_DIR, "webrtc_event_logs"),
              ignore_errors=True)
shutil.rmtree(os.path.join(EXAMPLES_DIR, "webcache"),
              ignore_errors=True)

shutil.rmtree(os.path.join(SNIPPETS_DIR, "blob_storage"),
              ignore_errors=True)
shutil.rmtree(os.path.join(SNIPPETS_DIR, "webrtc_event_logs"),
              ignore_errors=True)
shutil.rmtree(os.path.join(SNIPPETS_DIR, "webcache"),
              ignore_errors=True)


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

# These Visual Studio constants are used by automate.py tool
# to build upstream C++ projects. CEF Python C++ code is built
# with setuptools/distutils in the build_cpp_projects.py tool.
# -----------------------------------------------------------------------------

VS_PLATFORM_ARG = "x86" if ARCH32 else "amd64"

VS2015_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 14.0"
                 "\\VC\\vcvarsall.bat")

VS2013_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 12.0"
                 "\\VC\\vcvarsall.bat")

VS2010_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 10.0"
                 "\\VC\\vcvarsall.bat")

VS2008_VCVARS = ("C:\\Program Files (x86)\\Microsoft Visual Studio 9.0"
                 "\\VC\\vcvarsall.bat")

if WINDOWS and not os.path.exists(VS2008_VCVARS):
    VS2008_VCVARS = (os.environ["LOCALAPPDATA"]+"\\Programs\\Common\\Microsoft"
                     "\\Visual C++ for Python\\9.0\\vcvarsall.bat")

# -----------------------------------------------------------------------------


def get_os_postfix2_for_arch(arch):
    return OS_POSTFIX2_ARCH[SYSTEM][arch]


def get_cef_postfix2_for_arch(arch):
    return CEF_POSTFIX2_ARCH[SYSTEM][arch]


def get_pypi_postfix2_for_arch(arch):
    return PYPI_POSTFIX2_ARCH[SYSTEM][arch]


def sudo_command(command, python):
    """Prepends command with sudo when installing python packages
    requires sudo."""
    if python.startswith("/usr/"):
        command = "sudo " + command
    return command


def get_python_path():
    """Get Python path."""
    return os.path.dirname(sys.executable)


def get_python_include_path():
    # 1) C:\Python27\include
    # 2) ~/.pyenv/versions/2.7.13/bin/python
    #    ~/.pyenv/versions/2.7.13/include/python2.7
    # 3) ~/.pyenv/versions/3.4.6/include/python2.7m
    # 4) /usr/include/python2.7
    base_dir = os.path.dirname(sys.executable)
    try_dirs = ["{base_dir}/include",
                "{base_dir}/../include/python{ver}",
                "{base_dir}/../include/python{ver}*",
                ("{base_dir}/../Frameworks/Python.framework/Versions/{ver}"
                 "/include/python{ver}*"),
                "/usr/include/python{ver}"]
    ver_tuple = sys.version_info[:2]
    ver = "{major}.{minor}".format(major=ver_tuple[0], minor=ver_tuple[1])
    for pattern in try_dirs:
        pattern = pattern.format(base_dir=base_dir, ver=ver)
        if WINDOWS:
            pattern = pattern.replace("/", "\\")
        results = glob.glob(pattern)
        if len(results) == 1:
            python_h = os.path.join(results[0], "Python.h")
            if os.path.isfile(python_h):
                return results[0]
    return ".\\" if WINDOWS else "./"


g_deleted_sample_apps = []


def delete_cef_sample_apps(caller_script, bin_dir):
    """Delete CEF sample apps to reduce package size."""
    atexit.register(restore_cef_sample_apps, caller_script)
    for sample_app_name in CEF_SAMPLE_APPS:
        sample_app = os.path.join(bin_dir, sample_app_name + APP_EXT)
        # Not on all platforms sample apps may be available
        if os.path.exists(sample_app):
            print("[{script}] Delete {sample_app}"
                  .format(script=os.path.basename(caller_script),
                          sample_app=os.path.basename(sample_app)))
            tmpdir = tempfile.mkdtemp()
            g_deleted_sample_apps.append((bin_dir,
                                          os.path.basename(sample_app),
                                          tmpdir))
            shutil.move(sample_app, tmpdir)
            # Also delete subdirs eg. cefclient_files/, ceftests_files/
            files_subdir = os.path.join(bin_dir, sample_app_name + "_files")
            if os.path.isdir(files_subdir):
                print("[{script}] Delete directory: {dir}/"
                      .format(script=os.path.basename(caller_script),
                              dir=os.path.basename(files_subdir)))
                tmpdir = tempfile.mkdtemp()
                g_deleted_sample_apps.append((bin_dir,
                                              os.path.basename(files_subdir),
                                              tmpdir))
                shutil.move(files_subdir, tmpdir)


def restore_cef_sample_apps(caller_script):
    for deleted in g_deleted_sample_apps:
        bin_dir = deleted[0]
        tmp = os.path.join(deleted[2], deleted[1])
        print("[{script}] Restore: {path}"
              .format(script=os.path.basename(caller_script),
                      path=os.path.join(bin_dir, deleted[1])))
        shutil.move(tmp, bin_dir)
        shutil.rmtree(deleted[2])
    del g_deleted_sample_apps[0:len(g_deleted_sample_apps)]


def _detect_cef_binaries_libraries_dir():
    """Detect cef binary directory created by automate.py
    eg. build/cef55_3.2883.1553.g80bd606_win32/
    and set CEF_BINARIES_LIBRARIES to it, otherwise it will
    point to eg. build/cef_win32/ ."""
    global CEF_BINARIES_LIBRARIES
    if not os.path.exists(CEF_BINARIES_LIBRARIES):
        dirs = glob.glob(os.path.join(
                BUILD_DIR,
                get_cef_binaries_libraries_basename(OS_POSTFIX2)))
        if len(dirs) == 1:
            CEF_BINARIES_LIBRARIES = os.path.normpath(dirs[0])


def get_cef_binaries_libraries_basename(postfix2):
    version = get_cefpython_version()
    return ("cef{major}_{cef_version}_{os}"
            .format(major=version["CHROME_VERSION_MAJOR"],
                    cef_version=version["CEF_VERSION"],
                    os=postfix2))


def get_cefpython_binary_basename(postfix2, ignore_error=False):
    cef_version = get_cefpython_version()
    cmdline_version = get_version_from_command_line_args(
            __file__, ignore_error=ignore_error)
    if not cmdline_version:
        if not ignore_error:
            raise Exception("Version arg not found in command line args")
        return
    # If cef_version is 56 then expect version from command line to
    # start with "56.".
    cef_major = cef_version["CHROME_VERSION_MAJOR"]
    if not cmdline_version.startswith("{major}.".format(major=cef_major)):
        if not ignore_error:
            raise Exception("cmd line arg major version != Chrome version")
        return
    dirname = "cefpython_binary_{version}_{os}".format(
            version=cmdline_version,
            os=postfix2)
    return dirname


def get_setup_installer_basename(version, postfix2):
    setup_basename = ("cefpython3_{version}_{os}"
                      .format(version=version, os=postfix2))
    return setup_basename


def _detect_cefpython_binary_dir():
    """Detect cefpython binary directory where cefpython modules
    will be put. Eg. build/cefpython_56.0_win32/."""
    # Check cef version from header file and check cefpython version
    # that was passed as command line argument to either build.py
    # or make-installer.py. The CEFPYTHON_BINARY constant should
    # only be used in those two scripts, so version number in sys.argv
    # is expected. If not found then keep the default
    # "CEFPYTHON_BINARY_NOTSET" value intact.
    dirname = get_cefpython_binary_basename(OS_POSTFIX2, ignore_error=True)
    if not dirname:
        return
    binary_dir = os.path.join(BUILD_DIR, dirname)
    global CEFPYTHON_BINARY
    CEFPYTHON_BINARY = binary_dir


def _detect_distrib_dir():
    global DISTRIB_DIR
    version = get_version_from_command_line_args(__file__, ignore_error=True)
    if version:
        # Will only be set when called from scripts that had version
        # number arg passed on command line: build.py, build_distrib.py,
        # make_installer.py, etc.
        if LINUX or MAC:
            # - On Linux buildig 32bit and 64bit separately, so don't
            # delete eg. 64bit distrib when building 32bit distrib.
            # Keep them in different directories.
            # - On Mac only 64bit is supported.
            dirname = ("distrib_{version}_{postfix2}"
                       .format(version=version, postfix2=OS_POSTFIX2))
        elif WINDOWS:
            # On Windows both 32bit and 64bit distribs are built at
            # the same time.
            dirname = ("distrib_{version}_{win32}_{win64}"
                       .format(version=version,
                               win32=OS_POSTFIX2_ARCH[WINDOWS]["32bit"],
                               win64=OS_POSTFIX2_ARCH[WINDOWS]["64bit"]))
        else:
            dirname = ("distrib_{version}_{postfix}"
                       .format(version=version, postfix=OS_POSTFIX))
        DISTRIB_DIR = os.path.join(BUILD_DIR, dirname)


def get_version_from_command_line_args(caller_script, ignore_error=False):
    args = " ".join(sys.argv)
    match = re.search(r"\b(\d+)\.\d+\b", args)
    if match:
        version = match.group(0)
        major = match.group(1)
        cef_version = get_cefpython_version()
        if major != cef_version["CHROME_VERSION_MAJOR"]:
            if ignore_error:
                return ""
            print("[{script}] ERROR: cmd arg major version != Chrome version"
                  .format(script=os.path.basename(caller_script)))
            sys.exit(1)
        return version
    return


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
    elif sys.version_info[:2] == (3, 7):
        return "VS2015" if vs_prefix else "2015"
    elif sys.version_info[:2] == (3, 8):
        return "VS2015" if vs_prefix else "2015"
    else:
        print("ERROR: This version of Python is not supported")
        sys.exit(1)


_detect_cef_binaries_libraries_dir()
_detect_cefpython_binary_dir()
_detect_distrib_dir()
