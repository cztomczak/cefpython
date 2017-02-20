# Copyright (c) 2017 The CEF Python authors. All rights reserved.
# Licensed under the BSD 3-clause license.

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
    build.py VERSION [--rebuild-cpp] [--fast] [--kivy]

Options:
    VERSION        Version in format xx.xx
    --rebuild-cpp  Force rebuild of C++ projects
    --fast         Fast mode
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
# | subprocess.call(["python", "./wxpython.py"])
# You need to call it with shell=True for this kind of
# error message to be shown:
# | subprocess.call("python wxpython.py", shell=True)

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
KIVY_FLAG = False
REBUILD_CPP = False
VERSION = ""

# Module extension
if WINDOWS:
    MODULE_EXT = "pyd"
else:
    MODULE_EXT = "so"

# First run
FIRST_RUN = False
CEFPYTHON_H = os.path.join(BUILD_CEFPYTHON, "cefpython.h")


def main():
    if len(sys.argv) <= 1:
        print(__doc__)
        sys.exit(1)
    print("[build.py] PYVERSION = %s" % PYVERSION)
    print("[build.py] OS_POSTFIX2 = %s" % OS_POSTFIX2)
    setup_environ()
    check_cython_version()
    command_line_args()
    check_directories()
    fix_cefpython_h()
    if WINDOWS:
        compile_cpp_projects_windows()
    elif MAC or LINUX:
        compile_cpp_projects_unix()
    clear_cache()
    copy_and_fix_pyx_files()
    create_version_pyx_file()
    build_cefpython_module()
    fix_cefpython_h()
    install_and_run()


def setup_environ():
    """Set environment variables. Set PATH so that it contains only
    minimum set of directories,to avoid any possible issues. Set Python
    include path. Set Mac compiler options. Etc."""
    print("[build.py] Setup environment variables")

    if not WINDOWS:
        return

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

    # Mac compiler options
    if MAC:
        os.environ["PATH"] = "/usr/local/bin:"+os.environ["PATH"]
        os.environ["CC"] = "gcc"
        os.environ["CXX"] = "g++"
        os.environ["CEF_CCFLAGS"] = "-arch x86_64"
        os.environ["ARCHFLAGS"] = "-arch x86_64"
        if ARCH32:
            raise Exception("Python 32-bit is not supported on Mac")


def get_python_path():
    """Get Python path."""
    return os.path.dirname(sys.executable)


def check_cython_version():
    print("[build.py] Check Cython version")
    with open(os.path.join(TOOLS_DIR, "requirements.txt"), "r") as fileobj:
        contents = fileobj.read()
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


def command_line_args():
    global DEBUG_FLAG, FAST_FLAG, KIVY_FLAG, REBUILD_CPP, VERSION

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

    # --kivy flag
    if len(sys.argv) > 1 and "--kivy" in sys.argv:
        KIVY_FLAG = True
        print("[build.py] KIVY mode enabled")

    # --rebuild-cpp flag
    # Rebuild c++ projects
    if len(sys.argv) > 1 and "--rebuild-cpp" in sys.argv:
        REBUILD_CPP = True
        print("[build.py] REBUILD_CPP mode enabled")

    # version arg
    if len(sys.argv) > 1 and re.search(r"^\d+\.\d+$", sys.argv[1]):
        VERSION = sys.argv[1]
    else:
        print("[build.py] ERROR: expected first arg to be a version number")
        print("             Allowed version format: \\d+\.\\d+")
        sys.exit(1)

    print("[build.py] VERSION=%s" % VERSION)


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


def fix_cefpython_h():
    os.chdir(BUILD_CEFPYTHON)
    print("[build.py] Fix cefpython.h to disable warnings")
    if not os.path.exists("cefpython.h"):
        print("[build.py] cefpython.h was not yet generated")
        return
    with open("cefpython.h", "r") as fo:
        content = fo.read()
    pragma = "#pragma warning(disable:4190)"
    if pragma in content:
        print("[build.py] cefpython.h is already fixed")
        return
    content = ("%s\n\n" % pragma) + content
    with open("cefpython.h", "w") as fo:
        fo.write(content)
    print("[build.py] Save build_cefpython/cefpython.h")


def compile_cpp_projects_windows():
    print("[build.py] Compile C++ projects")

    print("[build.py] ~~ Build CLIENT_HANDLER vcproj")
    vcproj = ("client_handler_py{pyver}_{os}.vcproj"
              .format(pyver=PYVERSION, os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "client_handler", vcproj)
    build_vcproj(vcproj)

    print("[build.py] ~~ Build LIBCEFPYTHONAPP vcproj")
    vcproj = ("libcefpythonapp_py{pyver}_{os}.vcproj"
              .format(pyver=PYVERSION, os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "subprocess", vcproj)
    build_vcproj(vcproj)

    print("[build.py] ~~ Build SUBPROCESS vcproj")
    vcproj = ("subprocess_{os}.vcproj"
              .format(os=OS_POSTFIX2))
    vcproj = os.path.join(SRC_DIR, "subprocess", vcproj)
    ret = build_vcproj(vcproj)

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
    build_vcproj(vcproj)


def build_vcproj(vcproj):
    if not os.path.exists(CEFPYTHON_H):
        print("[build.py] INFO: Looks like first run, as cefpython.h"
              " is missing. Skip building C++ project.")
        global FIRST_RUN
        FIRST_RUN = True
        return

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

    # In VS2010 vcbuild was replaced by msbuild.exe.
    # /clp:disableconsolecolor
    # msbuild /p:BuildProjectReferences=false project.proj
    # MSBuild.exe MyProject.proj /t:build


def compile_ask_to_continue():
    # noinspection PyUnboundLocalVariable
    what = input("[build.py] make failed, 'y' to continue, Enter to stop: ")
    if what != "y":
        sys.exit(1)


def compile_cpp_projects_unix():
    print("[build.py] Compile C++ projects")

    # Need to allow continuing even when make fails, as it may
    # fail because the "public" function declaration is not yet
    # in "cefpython.h", but for it to be generated we need to run
    # cython compiling, so in this case you continue even when make
    # fails and then run the compile.py script again and this time
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
    delete_files_by_pattern("./cefpython_py*.{ext}".format(ext=MODULE_EXT))

    # Cache in build_cefpython/ directory
    os.chdir(BUILD_CEFPYTHON)

    delete_files_by_pattern("./cefpython_py*.{ext}".format(ext=MODULE_EXT))
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
    mainfile = "cefpython.pyx"

    pyxfiles = glob.glob("../../src/*.pyx")
    if not len(pyxfiles):
        print("[build.py] ERROR: no .pyx files found in root")
        sys.exit(1)
    pyxfiles = [f for f in pyxfiles if f.find(mainfile) == -1]
    # Now, pyxfiles contains all pyx files except the mainfile (cefpython.pyx),
    # we do not fix includes in mainfile.

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
    print("[build.py] Copying pyx files to build_cefpython/: %s" % pyxfiles)

    # Copy cefpython.pyx and fix includes in cefpython.pyx, eg.:
    # include "handlers/focus_handler.pyx" becomes include "focus_handler.pyx"
    shutil.copy("../../src/%s" % mainfile, "./%s" % mainfile)
    with open("./%s" % mainfile, "r") as fo:
        content = fo.read()
        (content, subs) = re.subn(r"^include \"handlers/",
                                  "include \"",
                                  content,
                                  flags=re.MULTILINE)
    with open("./%s" % mainfile, "w") as fo:
        fo.write(content)
        print("[build.py] %s includes fixed in %s" % (subs, mainfile))

    # Copy the rest of the files
    print("[build.py] Fixing includes in .pyx files:")
    for pyxfile in pyxfiles:
        newfile = "./%s" % os.path.basename(pyxfile)
        shutil.copy(pyxfile, newfile)
        pyxfile = newfile
        with open(pyxfile, "r") as pyxfileopened:
            content = pyxfileopened.read()
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
                print("[build.py] %s includes removed in: %s"
                      % (subs, os.path.basename(pyxfile)))
        with open(pyxfile, "w") as pyxfileopened:
            pyxfileopened.write(content)

    print("\n")


def except_all_missing(content):
    # This is not perfect, won't detect C++ custom types, but will find
    # the built-in types, templates and pointers.
    patterns = list()
    patterns.append(
        r"\bcp?def\s+"
        "((int|short|long|double|char|unsigned|float|double|cpp_bool"
        "|cpp_string|cpp_wstring|uint64_t|uintptr_t|void"
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


def create_version_pyx_file():
    os.chdir(BUILD_CEFPYTHON)
    print("[build.py] Create __version__.pyx file")
    with open("__version__.pyx", "w") as fo:
        fo.write('__version__ = "{}"\n'.format(VERSION))


def build_cefpython_module():
    os.chdir(BUILD_CEFPYTHON)
    # if DEBUG_FLAG:
    #     ret = subprocess.call("python-dbg setup.py build_ext --inplace"
    #                           " --cython-gdb", shell=True)

    print("[build.py] Execute build_module.py script")
    print("")
    if FAST_FLAG:
        ret = subprocess.call([sys.executable,
                               "{tools_dir}/build_module.py"
                               .format(tools_dir=TOOLS_DIR),
                               "build_ext", "--inplace", "--fast"],
                              shell=True)
    else:
        ret = subprocess.call([sys.executable,
                               "{tools_dir}/build_module.py"
                               .format(tools_dir=TOOLS_DIR),
                               "build_ext", "--inplace"],
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
        if FIRST_RUN and os.path.exists(CEFPYTHON_H):
            print("[build.py] INFO: looks like this was first run and"
                  " linking is expected to fail in such case. Will re-run"
                  " the build.py script programmatically now.")
            args = list()
            args.append(sys.executable)
            args.append(os.path.join(TOOLS_DIR, os.path.basename(__file__)))
            assert __file__ in sys.argv[0]
            args.extend(sys.argv[1:])
            ret = subprocess.call(args, shell=True)
            sys.exit(ret)
        else:
            print("[build.py] ERROR: failed to build the cefpython module")
        sys.exit(1)

    # Move the cefpython module
    move_file_by_pattern("./cefpython_py{pyver}*.{ext}"
                         .format(pyver=PYVERSION, ext=MODULE_EXT),
                         os.path.join(CEFPYTHON_BINARY,
                                      "cefpython_py{pyver}.{ext}"
                                      .format(pyver=PYVERSION,
                                              ext=MODULE_EXT)))

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
    os.system("{python} {make_tool} --version {version}"
              .format(python=sys.executable,
                      make_tool=make_tool,
                      version=VERSION))

    # Install
    print("[build.py] Install the cefpython package")
    os.chdir(setup_installer_dir)
    os.system("{sudo} {python} setup.py install"
              .format(sudo=get_sudo(), python=sys.executable))
    os.chdir(BUILD_DIR)

    # Run unittests
    print("[build.py] Run unittests")
    test_runner = os.path.join(UNITTESTS_DIR, "_test_runner.py")
    ret = os.system("{python} {test_runner}"
                    .format(python=sys.executable, test_runner=test_runner))
    if ret != 0:
        sys.exit(ret)

    # Run examples
    print("[build.py] Run examples")
    if KIVY_FLAG:
        run_examples = "{python} {linux_dir}/deprecated_64bit/kivy_.py"
    else:
        run_examples = ("cd {examples_dir}"
                        " && {python} hello_world.py"
                        " && {python} wxpython.py"
                        " && {python} gtk2.py"
                        " && {python} gtk2.py --message-loop-timer"
                        #  " && {python} gtk3.py"
                        " && {python} tkinter_.py"
                        " && {python} qt.py pyqt"
                        " && {python} qt.py pyside")
        if LINUX:
            run_examples += (" && {python}"
                             " {linux_dir}/deprecated_64bit/kivy_.py")
    run_examples.format(
        python=sys.executable,
        linux_dir=LINUX_DIR,
        examples_dir=EXAMPLES_DIR)
    os.system(run_examples)

    print("[build.py] DONE")


def get_sudo():
    # System Python requires sudo when installing package
    if sys.executable in ["/usr/bin/python", "/usr/bin/python3"]:
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
