# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Build the cefpython module, install package and run example.

Before running you must first put cefpython ready CEF binaries and
libraries in the cefpython/build/ directory (create if doesn't exist).
You have two options for obtaining these binaries and libraries.

Option 1: Download upstream CEF binaries and libraries from cefpython
GitHub Releases page. These binaries are tagged eg. "v55-upstream".
Extract the archive so that for example you have such a directory:
cefpython/build/cef55_3.2883.1553.g80bd606_win32/ .

Option 2: Use the automate.py tool. With this tool you can build CEF
from sources or use ready binaries from Spotify Automated Builds.

Usage:
    build.py VERSION [--rebuild-cpp] [--fast] [--clean] [--kivy]

Options:
    VERSION        Version number eg. 50.0
    --rebuild-cpp  Force rebuild of C++ projects
    --fast         Fast mode
    --clean        Clean C++ projects build files (.o .a etc)
    --kivy         Run only Kivy example
"""

# How to debug on Linux:
# 1. Install "python-dbg" package
# 2. Install "python-wxgtk2.8-dbg" package
# 3. Run "python compile.py debug"
# 4. In cygdb type "cy run"
# 5. To display debug backtrace type "cy bt"
# 6. More commands: http://docs.cython.org/src/userguide/debugging.html

# This will not show "Segmentation fault" error message:
# > subprocess.call(["python", "./wxpython.py"])
# You need to call it with command as string and shell=True
# for this kind of error message to be shown:
# > subprocess.call("python wxpython.py", shell=True)

from common import *
import sys
import os
import glob
import shutil
import subprocess
import re

# raw_input() was renamed to input() in Python 3
try:
    # noinspection PyUnresolvedReferences
    # noinspection PyShadowingBuiltins
    input = raw_input
except NameError:
    pass

# Command line args variables
DEBUG_FLAG = False
FAST_FLAG = False
CLEAN_FLAG = False
KIVY_FLAG = False
REBUILD_CPP = False
VERSION = ""

# First run
FIRST_RUN = False


def main():
    command_line_args()
    print("[build.py] Python version: {ver} {arch}"
          .format(ver=platform.python_version(), arch=ARCH_STR))
    print("[build.py] Python executable: %s" % sys.executable)
    print("[build.py] PYVERSION = %s" % PYVERSION)
    print("[build.py] OS_POSTFIX2 = %s" % OS_POSTFIX2)
    check_cython_version()
    check_directories()
    setup_environ()
    if os.path.exists(CEFPYTHON_API_HFILE):
        fix_cefpython_api_header_file()
        if WINDOWS:
            compile_cpp_projects_with_setuptools()
        elif MAC or LINUX:
            compile_cpp_projects_unix()
    else:
        print("[build.py] INFO: Looks like first run, as"
              " cefpython_py{pyver}.h is missing. Skip building"
              " C++ projects."
              .format(pyver=PYVERSION))
        global FIRST_RUN
        FIRST_RUN = True
    clear_cache()
    copy_and_fix_pyx_files()
    build_cefpython_module()
    fix_cefpython_api_header_file()
    install_and_run()


def command_line_args():
    global DEBUG_FLAG, FAST_FLAG, CLEAN_FLAG, KIVY_FLAG,\
           REBUILD_CPP, VERSION

    VERSION = get_version_from_command_line_args()
    if not VERSION:
        print(__doc__)
        sys.exit(1)

    print("[build.py] Parse command line arguments")

    # -- debug flag
    if len(sys.argv) > 1 and "--debug" in sys.argv:
        DEBUG_FLAG = True
        print("[build.py] DEBUG mode On")

    # --fast flag
    if len(sys.argv) > 1 and "--fast" in sys.argv:
        # Fast mode doesn't delete C++ .o .a files.
        # Fast mode also disables optimization flags in setup/setup.py .
        FAST_FLAG = True
        print("[build.py] FAST mode On")

    # --clean flag
    if len(sys.argv) > 1 and "--clean" in sys.argv:
        CLEAN_FLAG = True

    # --kivy flag
    if len(sys.argv) > 1 and "--kivy" in sys.argv:
        KIVY_FLAG = True
        print("[build.py] KIVY mode enabled")

    # --rebuild-cpp flag
    # Rebuild c++ projects
    if len(sys.argv) > 1 and "--rebuild-cpp" in sys.argv:
        REBUILD_CPP = True
        print("[build.py] REBUILD_CPP mode enabled")

    print("[build.py] VERSION=%s" % VERSION)


def check_cython_version():
    print("[build.py] Check Cython version")
    with open(os.path.join(TOOLS_DIR, "requirements.txt"), "rb") as fileobj:
        contents = fileobj.read().decode("utf-8")
        match = re.search(r"cython\s*==\s*([\d.]+)", contents,
                          flags=re.IGNORECASE)
        assert match, "cython package not found in requirements.txt"
        require_version = match.group(1)
    try:
        import Cython
        version = Cython.__version__
    except ImportError:
        # noinspection PyUnusedLocal
        Cython = None
        print("[build.py] ERROR: Cython is not installed ({0} required)"
              .format(require_version))
        sys.exit(1)
    if version != require_version:
        print("[build.py] ERROR: Wrong Cython version: {0}. Required: {1}"
              .format(version, require_version))
        sys.exit(1)
    print("[build.py] Cython version: {0}".format(version))


def check_directories():
    print("[build.py] Check directories")
    # Create directories if necessary
    if not os.path.exists(CEFPYTHON_BINARY):
        os.makedirs(CEFPYTHON_BINARY)
    if not os.path.exists(BUILD_CEFPYTHON):
        os.makedirs(BUILD_CEFPYTHON)

    # Check directories exist
    assert os.path.exists(BUILD_DIR)
    assert os.path.exists(BUILD_CEFPYTHON)
    assert os.path.exists(CEF_BINARIES_LIBRARIES)
    assert os.path.exists(CEFPYTHON_BINARY)


def setup_environ():
    """Set environment variables. Set PATH so that it contains only
    minimum set of directories,to avoid any possible issues. Set Python
    include path. Set Mac compiler options. Etc."""
    print("[build.py] Setup environment variables")

    # PATH
    if WINDOWS:
        path = [
            "C:\\Windows\\system32",
            "C:\\Windows",
            "C:\\Windows\\System32\\Wbem",
            get_python_path(),
        ]
        os.environ["PATH"] = os.pathsep.join(path)
        print("[build.py] environ PATH: {path}"
              .format(path=os.environ["PATH"]))

    # INCLUDE env for vcproj build
    if WINDOWS:
        if "INCLUDE" not in os.environ:
            os.environ["INCLUDE"] = ""
        os.environ["INCLUDE"] += os.pathsep + os.path.join(get_python_path(),
                                                           "include")
        print("[build.py] environ INCLUDE: {include}"
              .format(include=os.environ["INCLUDE"]))

    # LIB env for vcproj build
    if WINDOWS:
        os.environ["AdditionalLibraryDirectories"] = os.path.join(
                                                CEF_BINARIES_LIBRARIES, "lib")
        print("[build.py] environ AdditionalLibraryDirectories: {lib}"
              .format(lib=os.environ["AdditionalLibraryDirectories"]))

    if LINUX or MAC:
        # Used in makefiles
        os.environ["CEF_CCFLAGS"] = "-std=gnu++11 -DNDEBUG -Wall -Werror"
        if FAST_FLAG:
            os.environ["CEF_CCFLAGS"] += " -O0"
        else:
            os.environ["CEF_CCFLAGS"] += " -O3"
        os.environ["CEF_LINK_FLAGS"] = ""

    if LINUX:
        # TODO: Set CEF_CCFLAGS and CEF_LINK_FLAGS according to what is
        #       in upstream cefclient, see cef/cmake/cef_variables.cmake.
        pass

    # Mac env variables for makefiles
    if MAC:
        os.environ["CEF_BIN"] = os.path.join(CEF_BINARIES_LIBRARIES, "bin")
        os.environ["CEF_LIB"] = os.path.join(CEF_BINARIES_LIBRARIES, "lib")

    # Mac compiler options
    if MAC:
        os.environ["PATH"] = "/usr/local/bin:"+os.environ["PATH"]
        os.environ["CC"] = "c++"
        os.environ["CXX"] = "c++"

        if ARCH32:
            raise Exception("Python 32-bit is not supported on Mac")
        os.environ["ARCHFLAGS"] = "-arch x86_64"
        os.environ["CEF_CCFLAGS"] += " -arch x86_64"
        os.environ["CEF_LINK_FLAGS"] += " -mmacosx-version-min=10.9"

        # -Wno-return-type-c-linkage to ignore:
        # > warning: 'somefunc' has C-linkage specified, but returns
        # > user-defined type 'sometype' which is incompatible with C
        os.environ["CEF_CCFLAGS"] += " -Wno-return-type-c-linkage"

        # Compile against libc++ otherwise error "symbol not found"
        # with cef::logging::LogMessage symbol. Also include -lc++
        # and -lc++abi libraries.
        os.environ["CEF_CCFLAGS"] += " -stdlib=libc++"

        # See compile/link flags in upstream cefclient
        os.environ["CEF_CCFLAGS"] += (
                " -fno-strict-aliasing"
                " -fno-rtti"
                " -fno-threadsafe-statics"
                " -fobjc-call-cxx-cdtors"
                " -fvisibility=hidden"
                " -fvisibility-inlines-hidden"
        )
        os.environ["CEF_LINK_FLAGS"] += (
                " -lc++"
                " -lc++abi"
                " -Wl,-search_paths_first"
                " -Wl,-ObjC"
                " -Wl,-pie"
                " -Wl,-dead_strip"
        )


def get_python_path():
    """Get Python path."""
    return os.path.dirname(sys.executable)


def fix_cefpython_api_header_file():
    """This function does two things: 1) Disable warnings in cefpython
    API header file and 2) Make a copy named cefpython_pyXX_fixed.h,
    this copy will be used by C++ projects and its modification time
    won't change every time you run build.py script, thus C++ won't
    rebuild each time."""

    # Fix cefpython_pyXX.h to disable this warning:
    # > warning: 'somefunc' has C-linkage specified, but returns
    # > user-defined type 'sometype' which is incompatible with C
    # On Mac this warning must be disabled using -Wno-return-type-c-linkage
    # flag in makefiles.

    print("[build.py] Fix cefpython API header file in the build_cefpython/"
          " directory")
    if not os.path.exists(CEFPYTHON_API_HFILE):
        assert not os.path.exists(CEFPYTHON_API_HFILE_FIXED)
        print("[build.py] cefpython API header file was not yet generated")
        return

    with open(CEFPYTHON_API_HFILE, "rb") as fo:
        contents = fo.read().decode("utf-8")

    already_fixed = False
    pragma = "#pragma warning(disable:4190)"
    if pragma in contents:
        already_fixed = True
        print("[build.py] cefpython API header file is already fixed")
    else:
        if not MAC:
            contents = ("%s\n\n" % pragma) + contents

    if not already_fixed:
        with open(CEFPYTHON_API_HFILE, "wb") as fo:
            fo.write(contents.encode("utf-8"))
        print("[build.py] Save {filename}"
              .format(filename=CEFPYTHON_API_HFILE))

    if os.path.exists(CEFPYTHON_API_HFILE_FIXED):
        with open(CEFPYTHON_API_HFILE_FIXED, "rb") as fo:
            contents_fixed = fo.read().decode("utf-8")
    else:
        contents_fixed = ""
    if contents != contents_fixed:
        print("[build.py] Save cefpython_fixed.h")
        with open(CEFPYTHON_API_HFILE_FIXED, "wb") as fo:
            fo.write(contents.encode("utf-8"))


def compile_cpp_projects_with_setuptools():
    """Use setuptools to build static libraries / executable."""
    compile_cpp_projects = os.path.join(TOOLS_DIR, "build_cpp_projects.py")
    retcode = subprocess.call([sys.executable, compile_cpp_projects])
    if retcode != 0:
        print("[build.py] ERROR: Failed to compile C++ projects")
        sys.exit(1)
    # Copy subprocess executable
    print("[build.py] Copy subprocess executable")
    shutil.copy(SUBPROCESS_EXE, CEFPYTHON_BINARY)


def compile_cpp_projects_windows_DEPRECATED():
    """DEPRECATED. Not used currently.
    Build C++ projects using .vcproj files."""

    # TODO: Remove code after setuptools compilation was tested for some time

    print("[build.py] Compile C++ projects")

    print("[build.py] ~~ Build CLIENT_HANDLER vcproj")
    vcproj = ("client_handler_py{pyver}_{os}.vcproj"
              .format(pyver=PYVERSION, os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "client_handler", vcproj)
    build_vcproj_DEPRECATED(vcproj)

    print("[build.py] ~~ Build LIBCEFPYTHONAPP vcproj")
    vcproj = ("libcefpythonapp_py{pyver}_{os}.vcproj"
              .format(pyver=PYVERSION, os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "subprocess", vcproj)
    build_vcproj_DEPRECATED(vcproj)

    print("[build.py] ~~ Build SUBPROCESS vcproj")
    vcproj = ("subprocess_{os}.vcproj"
              .format(os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "subprocess", vcproj)
    ret = build_vcproj_DEPRECATED(vcproj)

    # Copy subprocess executable
    subprocess_from = os.path.join(
            SUBPROCESS_DIR,
            "Release_{os}".format(os=OS_POSTFIX2),
            "subprocess_{os}.exe".format(os=OS_POSTFIX2))
    subprocess_to = os.path.join(CEFPYTHON_BINARY, "subprocess.exe")
    if os.path.exists(subprocess_to):
        os.remove(subprocess_to)
    if ret == 0:
        print("[build.py] Copy subprocess executable")
        # shutil.copy() will also copy Permission bits
        shutil.copy(subprocess_from, subprocess_to)

    print("[build.py] ~~ Build CPP_UTILS vcproj")
    vcproj = ("cpp_utils_{os}.vcproj"
              .format(os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "cpp_utils", vcproj)
    build_vcproj_DEPRECATED(vcproj)


def build_vcproj_DEPRECATED(vcproj):
    """DEPRECATED. Not used currently."""

    # TODO: Remove code after setuptools compilation was tested for some time

    # In VS2010 vcbuild.exe was replaced by msbuild.exe.
    # Ufortunately WinSDK 7.1 does not come with msbuild.exe,
    # so it would be required to install Visual Studio 2010,
    # and to support both 32-bit ad 64-bit compilations it
    # a non-express version would have to be installed, which
    # is not free. So to make it free open-source it was
    # required migrate to a new compilation system that uses
    # distutils/setuptools packages.

    # msbuild.exe flags:
    # /clp:disableconsolecolor
    # msbuild /p:BuildProjectReferences=false project.proj
    # MSBuild.exe MyProject.proj /t:build

    if PYVERSION == "27":
        args = list()
        args.append(VS2008_VCVARS)
        args.append(VS_PLATFORM_ARG)
        args.append("&&")
        args.append(VS2008_BUILD)
        args.append("/nocolor")
        args.append("/nologo")
        args.append("/nohtmllog")
        if REBUILD_CPP:
            args.append("/rebuild")
        args.append(vcproj)
        ret = subprocess.call(args, shell=True)
        if ret != 0:
            compile_ask_to_continue()
        return ret
    else:
        raise Exception("Only Python 2.7 32-bit is currently supported")


def compile_ask_to_continue():
    # noinspection PyUnboundLocalVariable
    what = input("[build.py] make failed, 'y' to continue, Enter to stop: ")
    if what != "y":
        sys.exit(1)


def clean_cpp_projects_unix():
    delete_files_by_pattern("{0}/*.o".format(CLIENT_HANDLER_DIR))
    delete_files_by_pattern("{0}/*.a".format(CLIENT_HANDLER_DIR))

    delete_files_by_pattern("{0}/*.o".format(SUBPROCESS_DIR))
    delete_files_by_pattern("{0}/*.a".format(SUBPROCESS_DIR))
    delete_files_by_pattern("{0}/subprocess".format(SUBPROCESS_DIR))

    delete_files_by_pattern("{0}/*.o".format(CPP_UTILS_DIR))
    delete_files_by_pattern("{0}/*.a".format(CPP_UTILS_DIR))


def compile_cpp_projects_unix():
    print("[build.py] Compile C++ projects")
    if CLEAN_FLAG:
        print("[build.py] Clean C++ projects (--clean flag passed)")
        clean_cpp_projects_unix()

    # Need to allow continuing even when make fails, as it may
    # fail because the "public" function declaration is not yet
    # in cefpython API header file, but for it to be generated we need
    # to run cython compiling, so in this case you continue even when
    # make fails and then run the compile.py script again and this time
    # make should succeed.

    # -- CLIENT_HANDLER
    print("[build.py] ~~ Build CLIENT_HANDLER project")

    os.chdir(CLIENT_HANDLER_DIR)
    if not FAST_FLAG:
        subprocess.call("rm -f *.o *.a", shell=True)

    ret = subprocess.call("make -f Makefile", shell=True)
    if ret != 0:
        compile_ask_to_continue()

    # -- LIBCEFPYTHONAPP
    print("[build.py] ~~ Build LIBCEFPYTHONAPP project")

    os.chdir(SUBPROCESS_DIR)
    if not FAST_FLAG:
        subprocess.call("rm -f *.o *.a", shell=True)
        subprocess.call("rm -f subprocess", shell=True)

    ret = subprocess.call("make -f Makefile-libcefpythonapp", shell=True)
    if ret != 0:
        compile_ask_to_continue()

    # -- SUBPROCESS
    print("[build.py] ~~ Build SUBPROCESS project")
    ret = subprocess.call("make -f Makefile", shell=True)
    if ret != 0:
        compile_ask_to_continue()

    # Copy subprocess executable
    subprocess_from = os.path.join(SUBPROCESS_DIR, "subprocess")
    subprocess_to = os.path.join(CEFPYTHON_BINARY, "subprocess")
    if os.path.exists(subprocess_from):
        # shutil.copy() will also copy Permission bits
        shutil.copy(subprocess_from, subprocess_to)

    # -- CPP_UTILS
    print("[build.py] ~~ Build CPP_UTILS project")

    os.chdir(CPP_UTILS_DIR)
    if not FAST_FLAG:
        subprocess.call("rm -f *.o *.a", shell=True)

    ret = subprocess.call("make -f Makefile", shell=True)
    if ret != 0:
        compile_ask_to_continue()


def clear_cache():
    print("[build.py] Clean build cache")
    # Cache in CEFPYTHON_BINARY directory (eg. cefpython_linux64/)
    os.chdir(CEFPYTHON_BINARY)
    delete_files_by_pattern("./"+MODULE_NAME_TEMPLATE
                            .format(pyversion=PYVERSION, ext=MODULE_EXT))

    # Cache in build_cefpython/ directory
    os.chdir(BUILD_CEFPYTHON)

    delete_files_by_pattern("./"+MODULE_NAME_TEMPLATE
                            .format(pyversion=PYVERSION, ext=MODULE_EXT))
    delete_files_by_pattern("./*.pyx")

    try:
        if not FAST_FLAG:
            # Cython's internal build/ directory
            shutil.rmtree(os.path.join(BUILD_CEFPYTHON, "build"))
    except OSError:
        pass


def copy_and_fix_pyx_files():
    print("[build.py] Copy and fix pyx files")
    # First, it copies all .pyx files from upper directory to setup/.
    # Then, fixes repeating of "include" statements in pyx files.

    # Only the mainfile needs to have "include" statements,
    # but we're using PyCharm and to get rid of "unresolved references"
    # and other errors displayed in pycharm we are adding "include"
    # statements in all of the pyx files.

    # I'm not 100% sure how includes work in Cython, but I suspect that
    # a few includes of the same file will include the same content more
    # than once, it should work, but function and variable definitions are
    # duplicated, it is some kind of overhead and it could lead to some
    # problems in the future, better to fix it now.

    # It also checks cdef & cpdef functions whether they are not missing
    # "except *", it is required to add it when returning non-python type.

    os.chdir(BUILD_CEFPYTHON)
    print("\n")
    mainfile_original = "cefpython.pyx"
    mainfile_newname = "cefpython_py{pyver}.pyx".format(pyver=PYVERSION)

    pyxfiles = glob.glob("../../src/*.pyx")
    if not len(pyxfiles):
        print("[build.py] ERROR: no .pyx files found in root")
        sys.exit(1)
    pyxfiles = [f for f in pyxfiles if f.find(mainfile_original) == -1]
    # Now, pyxfiles contains all pyx files except mainfile_original
    # (cefpython.pyx), we do not fix includes in mainfile.

    pyxfiles2 = glob.glob("../../src/handlers/*.pyx")
    if not len(pyxfiles2):
        print("[build.py] ERROR: no .pyx files found in handlers/")
        sys.exit(1)

    pyxfiles = pyxfiles + pyxfiles2

    # Remove old pyx files
    oldpyxfiles = glob.glob("./*.pyx")
    print("[build.py] Clean pyx files in build_cefpython/")
    for pyxfile in oldpyxfiles:
        if os.path.exists(pyxfile):
            os.remove(pyxfile)

    # Copying pyxfiles and reading its contents.
    print("[build.py] Copy pyx files to build_cefpython/")

    # Copy cefpython.pyx and fix includes in cefpython.pyx, eg.:
    # include "handlers/focus_handler.pyx" becomes include "focus_handler.pyx"
    shutil.copy("../../src/%s" % mainfile_original, "./%s" % mainfile_newname)
    with open("./%s" % mainfile_newname, "rb") as fo:
        content = fo.read().decode("utf-8")
        (content, subs) = re.subn(r"^include \"handlers/",
                                  "include \"",
                                  content,
                                  flags=re.MULTILINE)
        # Add __version__ variable in cefpython.pyx
        print("[build.py] Add __version__ variable to %s" % mainfile_newname)
        content = generate_cefpython_module_variables() + content
    with open("./%s" % mainfile_newname, "wb") as fo:
        fo.write(content.encode("utf-8"))
        print("[build.py] Fix %s includes in %s" % (subs, mainfile_newname))

    # Copy the rest of the files
    print("[build.py] Fix includes in other .pyx files")
    for pyxfile in pyxfiles:
        newfile = "./%s" % os.path.basename(pyxfile)
        shutil.copy(pyxfile, newfile)
        pyxfile = newfile
        with open(pyxfile, "rb") as pyxfileopened:
            content = pyxfileopened.read().decode("utf-8")
            lineNumber = except_all_missing(content)
            if lineNumber:
                print("[build.py] WARNING: 'except *' missing"
                      " in a cdef/cpdef function,"
                      " in file %s on line %d"
                      % (os.path.basename(pyxfile), lineNumber))
                sys.exit(1)
            # Do not remove the newline - so that line numbers
            # are exact with originals.
            (content, subs) = re.subn(
                    r"^include[\t ]+[\"'][^\"'\n\r]+[\"'][\t ]*",
                    "",
                    content,
                    flags=re.MULTILINE)
            if subs:
                # print("[build.py] %s includes removed in: %s"
                #       % (subs, os.path.basename(pyxfile)))
                pass
        with open(pyxfile, "wb") as pyxfileopened:
            pyxfileopened.write(content.encode("utf-8"))

    print("\n")


def generate_cefpython_module_variables():
    """Global variables that will be appended to cefpython.pyx sources."""
    ret = ('__version__ = "{0}"\n'.format(VERSION))
    version = get_cefpython_version()
    chrome_version = "{0}.{1}.{2}.{3}".format(
            version["CHROME_VERSION_MAJOR"], version["CHROME_VERSION_MINOR"],
            version["CHROME_VERSION_BUILD"], version["CHROME_VERSION_PATCH"])
    ret += ('__chrome_version__ = "{0}"\n'.format(chrome_version))
    ret += ('__cef_version__ = "{0}"\n'.format(version["CEF_VERSION"]))
    ret += ('__cef_api_hash_platform__ = "{0}"\n'
            .format(version["CEF_API_HASH_PLATFORM"]))
    ret += ('__cef_api_hash_universal__ = "{0}"\n'
            .format(version["CEF_API_HASH_UNIVERSAL"]))
    ret += ('__cef_commit_hash__ = "{0}"\n'
            .format(version["CEF_COMMIT_HASH"]))
    ret += ('__cef_commit_number__ = "{0}"\n'
            .format(version["CEF_COMMIT_NUMBER"]))
    return ret


def except_all_missing(content):
    # This is not perfect, won't detect C++ custom types, but will find
    # the built-in types, templates and pointers.
    patterns = list()
    patterns.append(
        r"\bcp?def\s+"
        "((int|short|long|double|char|unsigned|float|double|cpp_bool"
        "|cpp_string|cpp_wstring|uintptr_t|void"
        "|int32|uint32|int64|uint64"
        "|int32_t|uint32_t|int64_t|uint64_t"
        "|CefString)\s+)+"
        "\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:")
    patterns.append(
        r"\bcp?def\s+"
        # A template ends with bracket: CefRefPtr[CefBrowser]
        # or a pointer ends with asterisk: CefBrowser*
        "[^\s]+[\]*]\s+"
        "\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:")
    patterns.append(
        r"\bcp?def\s+"
        # A reference, eg. CefString&
        "[^\s]+&\s+"
        "\w+\([^)]*\)\s*(with\s+(gil|nogil))?\s*:")

    match = None
    for pattern in patterns:
        match = re.search(pattern, content)
        if match:
            break

    if match:
        lineNumber = (content.count("\n", 0, match.start()) + 1)
        return lineNumber


def build_cefpython_module():
    # if DEBUG_FLAG:
    #     ret = subprocess.call("python-dbg setup.py build_ext --inplace"
    #                           " --cython-gdb", shell=True)

    print("[build.py] Execute cython_setup.py script")
    print("")

    os.chdir(BUILD_CEFPYTHON)

    if FAST_FLAG:
        ret = subprocess.call("\"{python}\" {tools_dir}/cython_setup.py"
                              " build_ext --fast"
                              .format(python=sys.executable,
                                      tools_dir=TOOLS_DIR),
                              shell=True)
    else:
        ret = subprocess.call("\"{python}\" {tools_dir}/cython_setup.py"
                              " build_ext"
                              .format(python=sys.executable,
                                      tools_dir=TOOLS_DIR),
                              shell=True)

    # if DEBUG_FLAG:
    #     shutil.rmtree("./../binaries_%s/cython_debug/" % BITS,
    #                   ignore_errors=True)
    #     shutil.copytree("./cython_debug/",
    #                     "./../binaries_%s/cython_debug/" % BITS)

    # Remove .pyx files
    oldpyxfiles = glob.glob("./*.pyx")
    print("")
    print("[build.py] Cleanup: remove pyx files in build_cefpython/")
    for pyxfile in oldpyxfiles:
        if os.path.exists(pyxfile):
            os.remove(pyxfile)

    # Check if built succeeded after pyx files were removed
    if ret != 0:
        if FIRST_RUN and os.path.exists(CEFPYTHON_API_HFILE):
            print("[build.py] INFO: looks like this was first run and"
                  " building the cefpython module is expected to fail"
                  " in such case due to cefpython API header file not"
                  " being generated yet. Will re-run the build.py script"
                  " programmatically now.")
            args = list()
            args.append("\"{python}\"".format(python=sys.executable))
            args.append(os.path.join(TOOLS_DIR, os.path.basename(__file__)))
            assert __file__ in sys.argv[0]
            args.extend(sys.argv[1:])
            ret = subprocess.call(" ".join(args), shell=True)
            sys.exit(ret)
        else:
            print("[build.py] ERROR: failed to build the cefpython module")
        sys.exit(1)

    # Move the cefpython module
    module_pattern = MODULE_NAME_TEMPLATE.format(pyversion=PYVERSION+"*",
                                                 ext=MODULE_EXT)
    module_pattern = "./build/lib*/" + module_pattern
    move_file_by_pattern(module_pattern, os.path.join(CEFPYTHON_BINARY,
                                                      MODULE_NAME))

    print("[build.py] DONE building the cefpython module")


def move_file_by_pattern(pattern, move_to):
    assert len(pattern) > 2
    print("[build.py] Move file: {pattern} to {move_to}"
          .format(pattern=pattern, move_to=move_to))
    files = glob.glob(pattern)
    assert(len(files) == 1)
    os.rename(files[0], move_to)


def delete_files_by_pattern(pattern):
    assert len(pattern) > 2
    print("[build.py] Delete files by pattern: {pattern}"
          .format(pattern=pattern))
    files = glob.glob(pattern)
    for f in files:
        os.remove(f)
    print("[build.py] Removed {0} files".format(len(files)))


def delete_directories_by_pattern(pattern):
    assert len(pattern) > 2
    print("[build.py] Delete directories by pattern: {pattern}"
          .format(pattern=pattern))
    paths = glob.glob(pattern)
    for path in paths:
        if os.path.isdir(path):
            shutil.rmtree(path)


def install_and_run():
    # if DEBUG_FLAG:
    #     os.chdir("./binaries_%s" % BITS)
    #     subprocess.call("cygdb . --args python-dbg wxpython.py", shell=True)

    print("[build.py] Install and run...")
    os.chdir(BUILD_DIR)

    # Setup installer directory
    setup_installer_dir = ("./cefpython3-{version}-{os}-setup/"
                           .format(version=VERSION, os=OS_POSTFIX2))
    setup_installer_dir = os.path.join(BUILD_DIR, setup_installer_dir)

    # Delete setup installer directory if exists
    if os.path.exists(setup_installer_dir):
        delete_directory_reliably(setup_installer_dir)

    # Make setup installer
    print("[build.py] Make setup installer")
    make_tool = os.path.join(TOOLS_DIR, "make_installer.py")
    ret = os.system("\"{python}\" {make_tool} --version {version}"
                    .format(python=sys.executable,
                            make_tool=make_tool,
                            version=VERSION))
    if ret != 0:
        print("[build.py] ERROR while making installer package")
        sys.exit(ret)

    # Install
    print("[build.py] Install the cefpython package")
    os.chdir(setup_installer_dir)
    ret = os.system("{sudo} \"{python}\" setup.py install"
                    .format(sudo=get_sudo(), python=sys.executable))
    if ret != 0:
        print("[build.py] ERROR while installing package")
        sys.exit(ret)
    os.chdir(BUILD_DIR)

    # Delete setup installer directory after the package was installed
    delete_directory_reliably(setup_installer_dir)

    # Run unittests
    print("[build.py] Run unittests")
    test_runner = os.path.join(UNITTESTS_DIR, "_test_runner.py")
    ret = os.system("\"{python}\" {test_runner}"
                    .format(python=sys.executable, test_runner=test_runner))
    if ret != 0:
        print("[build.py] ERROR while running unit tests")
        sys.exit(ret)

    # Run examples
    print("[build.py] Run examples")
    os.chdir(EXAMPLES_DIR)
    kivy_flag = "--kivy" if KIVY_FLAG else ""
    run_examples = os.path.join(TOOLS_DIR, "run_examples.py")
    ret = os.system("\"{python}\" {run_examples} {kivy_flag}"
                    .format(python=sys.executable,
                            run_examples=run_examples,
                            kivy_flag=kivy_flag))
    if ret != 0:
        print("[build.py] ERROR while running examples")
        sys.exit(1)

    print("[build.py] Everything OK")


def get_sudo():
    # System Python requires sudo when installing package
    if sys.executable.startswith("/usr/"):
        sudo = "sudo"
    else:
        sudo = ""
    return sudo


def delete_directory_reliably(adir):
    assert len(adir) > 2
    assert os.path.isdir(adir)
    print("[build.py] Delete directory: {dir}"
          .format(dir=adir.replace(ROOT_DIR, "")))
    if WINDOWS:
        shutil.rmtree(adir)
    else:
        # On Linux sudo might be required to delete directory, as this
        # might be a setup installer directory with package installed
        # using sudo and in such case files were created with sudo.
        os.system("{sudo} rm -rf {dir}"
                  .format(sudo=get_sudo(), dir=adir))


if __name__ == "__main__":
    main()
