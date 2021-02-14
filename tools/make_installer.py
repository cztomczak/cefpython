# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Create setup.py package installer.

Usage:
    make_installer.py VERSION [--wheel] [--python-tag xx] [--universal]

Options:
    VERSION  Version number eg. 50.0
    --wheel  Generate wheel package.
             Additional args for the wheel package:
             --python-tag xx (eg. cp27 - cpython 2.7)
             --universal (any python 2 or 3)
"""

from common import *

import glob
import os
import re
import shutil
import subprocess
import sys
import sysconfig

# Command line args
VERSION = ""
WHEEL = False
WHEEL_ARGS = list()

# Globals
SETUP_DIR = ""
PKG_DIR = ""

# Config
IGNORE_EXT = [".log", ".pyc", ".pdb", ]
IGNORE_DIRS = ["__pycache__"]


def main():
    command_line_args()

    # Make sure pyinstaller build/dist directories do not exist,
    # otherwise they would be packed along with examples and thus
    # increase package size significantly.
    assert not os.path.exists(os.path.join(EXAMPLES_DIR,
                                           "pyinstaller", "build"))
    assert not os.path.exists(os.path.join(EXAMPLES_DIR,
                                           "pyinstaller", "dist"))

    # Setup and package directories
    global SETUP_DIR, PKG_DIR
    setup_dir_name = get_setup_installer_basename(VERSION, OS_POSTFIX2)
    SETUP_DIR = os.path.join(BUILD_DIR, setup_dir_name)
    PKG_DIR = os.path.join(SETUP_DIR, "cefpython3")

    # Print src and dest for file operations
    print("[make_installer.py] Src:    {src}".format(src=ROOT_DIR))
    print("[make_installer.py] Dst:    {dst}".format(dst=SETUP_DIR))

    # Make directories
    if os.path.exists(SETUP_DIR):
        print("[make_installer.py] Delete: {dir}"
              .format(dir=SETUP_DIR.replace(ROOT_DIR, "")))
        shutil.rmtree(SETUP_DIR)
    os.makedirs(SETUP_DIR)
    os.makedirs(os.path.join(SETUP_DIR, "examples/"))
    os.makedirs(PKG_DIR)
    os.makedirs(os.path.join(PKG_DIR, "examples/"))

    # Copy files from tools/installer/
    copy_tools_installer_files(SETUP_DIR, PKG_DIR)

    # Multiple copy operations using glob patterns
    copy_operations = [
        (ROOT_DIR, "License"), (PKG_DIR,),
        (CEF_BINARIES_LIBRARIES, "*.txt"), (PKG_DIR,),
        (CEF_BINARIES_LIBRARIES, "bin/*"), (PKG_DIR,),
        (CEFPYTHON_BINARY, "*"), (PKG_DIR,),
        (EXAMPLES_DIR, "*"), (PKG_DIR, "examples/"),
        (EXAMPLES_DIR, "*"), (SETUP_DIR, "examples/"),
    ]
    perform_copy_operations(copy_operations)
    delete_cef_sample_apps(caller_script=__file__, bin_dir=PKG_DIR)

    # Linux only operations
    if LINUX:
        os.makedirs(os.path.join(SETUP_DIR, "examples", "kivy-select-boxes"))
        copy_operations_linux = [
            (LINUX_DIR, "binaries_64bit/kivy_.py"),
            (SETUP_DIR, "examples/"),
            (LINUX_DIR, "binaries_64bit/kivy-select-boxes/*"),
            (SETUP_DIR, "examples/kivy-select-boxes/")
        ]
        perform_copy_operations(copy_operations_linux)

    # Create empty debug.log files so that package uninstalls cleanly
    # in case examples or CEF tests were launched. See Issue #149.
    create_empty_log_file(os.path.join(PKG_DIR, "debug.log"))
    create_empty_log_file(os.path.join(PKG_DIR, "examples/debug.log"))

    copy_cpp_extension_dependencies_issue359(PKG_DIR)

    print("[make_installer.py] Done. Installer package created: {setup_dir}"
          .format(setup_dir=SETUP_DIR))

    # Optional generation of wheel package
    if WHEEL:
        print("[make_installer.py] Create Wheel package")
        if not len(WHEEL_ARGS):
            print("[make_installer.py] ERROR: you must specify flags"
                  " eg. --python-tag cp27 or --universal")
            sys.exit(1)
        command = ("\"{python}\" setup.py bdist_wheel {wheel_args}"
                   .format(python=sys.executable,
                           wheel_args=" ".join(WHEEL_ARGS)))
        print("[make_installer.py] Run command: '{0}' in setup directory"
              .format(command))
        subprocess.check_call(command, cwd=SETUP_DIR, shell=True)
        dist_dir = os.path.join(SETUP_DIR, "dist")
        files = glob.glob(os.path.join(dist_dir, "*.whl"))
        assert len(files) == 1
        print("[make_installer.py] Done. Wheel package created: {0}"
              .format(files[0]))


def command_line_args():
    global VERSION, WHEEL, WHEEL_ARGS
    VERSION = get_version_from_command_line_args(__file__)
    if not VERSION:
        print(__doc__)
        sys.exit(1)
    for arg in sys.argv:
        if arg == VERSION:
            continue
        if arg == "--wheel":
            WHEEL = True
            continue
        if WHEEL:
            WHEEL_ARGS.append(arg)
    if WHEEL and not len(WHEEL_ARGS):
        print("ERROR: wheel requires additional args eg. --universal")
        sys.exit(1)


def copy_tools_installer_files(setup_dir, pkg_dir):
    variables = dict()
    variables["VERSION"] = VERSION
    variables["SYSCONFIG_PLATFORM"] = sysconfig.get_platform()

    shutil.copy(
        os.path.join(INSTALLER_DIR, "cefpython3.README.txt"),
        os.path.join(setup_dir, "README.txt"))

    copy_template_file(
        os.path.join(INSTALLER_DIR, "cefpython3.setup.py"),
        os.path.join(setup_dir, "setup.py"),
        variables)

    copy_template_file(
        os.path.join(INSTALLER_DIR, "cefpython3.__init__.py"),
        os.path.join(pkg_dir, "__init__.py"),
        variables)


def copy_template_file(src, dst, variables):
    """Copy file and replaces template variables in that file."""
    print("[make_installer.py] Copy_t: {src} ==> {dst}"
          .format(src=short_src_path(src), dst=short_dst_path(dst)))
    with open(src, "rb") as fo:
        contents = fo.read().decode("utf-8")
    contents = replace_template_vars(contents, variables)
    with open(dst, "wb") as fo:
        fo.write(contents.encode("utf-8"))
    return contents


def replace_template_vars(string, dictionary):
    """Replaces template variables like {{SOME}} in the string
    using the dictionary values."""
    orig_string = string
    for key, value in dictionary.items():
        string = string.replace("{{"+key+"}}", value)
    if string == orig_string:
        raise Exception("Nothing to format")
    if re.search(r"{{[a-zA-Z0-9_]+}}", string):
        raise Exception("Not all strings were formatted")
    return string


def perform_copy_operations(operations):
    assert len(operations) % 2 == 0
    count_ops = int(len(operations) / 2)
    for op_i in range(count_ops):
        # Refer to values by index
        pattern = operations[op_i*2]
        dst_dir = operations[op_i*2+1]
        # Convert tuples to lists
        pattern = list(pattern)
        dst_dir = list(dst_dir)
        # Join paths
        pattern = os.path.join(*pattern)
        dst_dir = os.path.join(*dst_dir)
        dst_dir = os.path.abspath(dst_dir)
        # Normalize unix slashes on Windows
        pattern = pattern.replace("/", os.path.sep)
        # dst_dir must be a directory
        if not os.path.isdir(dst_dir):
            raise Exception("Not a directory: {dst_dir}"
                            .format(dst_dir=dst_dir))
        # Is pattern a file or a directory
        if os.path.isfile(pattern):
            if is_ignored_path(pattern):
                raise Exception("Copy operation pattern is in ignore list:"
                                " {pattern}".format(pattern=pattern))
            print("[make_installer.py] Copy:   {file} ==> {dir}"
                  .format(file=short_src_path(pattern),
                          dir=short_dst_path(dst_dir)))
            # Destination file must not exist
            assert not os.path.exists(os.path.join(dst_dir,
                                                   os.path.basename(pattern)))
            shutil.copy(pattern, dst_dir)
        else:
            # pattern is a glob pattern
            base_dir = os.path.dirname(pattern)
            assert base_dir
            assert base_dir == os.path.abspath(base_dir)
            paths = glob.glob(pattern)
            if not len(paths):
                raise Exception("No paths found in: {pattern}"
                                .format(pattern=pattern))
            for path in paths:
                # "path" variable contains absolute path
                assert path == os.path.abspath(path)
                if os.path.isfile(path):
                    if is_ignored_path(path):
                        continue
                    print("[make_installer.py] Copy:   {file} ==> {dir}"
                          .format(file=short_src_path(path),
                                  dir=short_dst_path(dst_dir)))
                    # Destination file must not exist
                    assert not os.path.exists(
                            os.path.join(dst_dir, os.path.basename(path)))
                    shutil.copy(path, dst_dir)
                elif os.path.isdir(path):
                    if is_ignored_path(path):
                        continue
                    relative_dir = path.replace(base_dir, "")
                    assert relative_dir[0] == os.path.sep
                    relative_dir = relative_dir[1:]
                    perform_copy_recursively(base_dir, relative_dir, dst_dir)
                else:
                    raise Exception("Unknown path: {path}".format(path=path))


def perform_copy_recursively(base_dir, relative_dir, new_dir):
    real_dir = os.path.join(base_dir, relative_dir)
    assert os.path.exists(real_dir) and os.path.isdir(real_dir)
    assert os.path.exists(new_dir) and os.path.isdir(new_dir)

    # Create subdirectory
    new_subdir = os.path.join(new_dir, relative_dir)
    if not os.path.exists(new_subdir):
        print("[make_installer.py] Create: {dir}"
              .format(dir=short_dst_path(new_subdir)))
        os.makedirs(new_subdir)

    # List directory
    paths = os.listdir(real_dir)
    for path in paths:
        # "path" variable contains relative path
        real_path = os.path.join(real_dir, path)
        path = os.path.join(relative_dir, path)
        if os.path.isdir(real_path):
            if is_ignored_path(real_path):
                continue
            perform_copy_recursively(base_dir, path, new_dir)
        elif os.path.isfile(real_path):
            if is_ignored_path(real_path):
                continue
            new_file = os.path.join(new_dir, path)
            new_subdir = os.path.dirname(new_file)
            if os.path.exists(new_file):
                raise Exception("Path aready exists: {new_file}"
                                .format(new_file=short_dst_path(new_file)))
            print("[make_installer.py] Copy:   {file} ==> {dir}"
                  .format(file=short_src_path(real_path),
                          dir=short_dst_path(new_subdir)))
            shutil.copy(real_path, new_subdir)
        else:
            raise Exception("Unknown path: {path}".format(path=real_path))


def is_ignored_path(path):
    basename = os.path.basename(path)
    if basename in IGNORE_DIRS:
        print("[make_installer.py] Ignore: {dir}"
              .format(dir=short_src_path(path)))
        return True
    for ext in IGNORE_EXT:
        if path.endswith(ext):
            print("[make_installer.py] Ignore: {file}"
                  .format(file=short_src_path(path)))
            return True
    return False


def delete_files_by_pattern(pattern):
    assert len(pattern) > 2
    # Normalize unix slashes on Windows
    pattern = pattern.replace("/", os.path.sep)
    print("[make_installer.py] Delete: {pattern}"
          .format(pattern=short_dst_path(pattern)))
    files = glob.glob(pattern)
    for f in files:
        os.remove(f)


def create_empty_log_file(log_file):
    # Normalize unix slashes on Windows
    log_file = log_file.replace("/", os.path.sep)
    print("[make_installer.py] Create: {file}"
          .format(file=short_dst_path(log_file)))
    with open(log_file, "wb") as fo:
        fo.write("".encode("utf-8"))
    # On Linux and Mac chmod so that for cases when package is
    # installed using sudo. When wheel package is created it
    # will remember file permissions set.
    if LINUX or MAC:
        command = "chmod 666 {file}".format(file=log_file)
        print("[make_installer.py] {command}"
              .format(command=command.replace(SETUP_DIR, "")))
        subprocess.check_call(command, shell=True)


def copy_cpp_extension_dependencies_issue359(pkg_dir):
    """CEF Python module is written in Cython and is a Python C++
    extension and depends on msvcpXX.dll. For Python 3.5 / 3.6 / 3.7 / 3.8 / 3.9
    msvcp140.dll is required. See Issue #359. For Python 2.7
    msvcp90.dll is required. Etc. These dependencies are not included
    with Python binaries from Python.org."""
    if not WINDOWS:
        return

    windows_dir = os.environ["SYSTEMROOT"]
    if SYSTEM64:
        system32 = os.path.join(windows_dir, "SysWOW64")
        system64 = os.path.join(windows_dir, "System32")
    else:
        system32 = os.path.join(windows_dir, "")
        system64 = None
    if ARCH64:
        system = system64
    else:
        system = system32

    root_search_paths = []

    # Need to check for .pyd files for all Python version, because
    # the builder/installer work in a way that previous cefpython
    # module builds for other Python versions are also included
    # in the package. Thus if included, msvcpxx.dll dependency is
    # required as well.

    # Python 3.5 / 3.6 / 3.7 / 3.8 / 3.9
    if os.path.exists(os.path.join(pkg_dir, "cefpython_py35.pyd")) \
            or os.path.exists(os.path.join(pkg_dir, "cefpython_py36.pyd")) \
            or os.path.exists(os.path.join(pkg_dir, "cefpython_py37.pyd")) \
            or os.path.exists(os.path.join(pkg_dir, "cefpython_py38.pyd")) \
            or os.path.exists(os.path.join(pkg_dir, "cefpython_py39.pyd")):
        search_paths = [
            # This is where Microsoft Visual C++ 2015 Update 3 installs
            # (14.00.24212).
            os.path.join(system, "msvcp140.dll"),
        ]
        root_search_paths.append(search_paths)

    # Python 3.4
    if os.path.exists(os.path.join(pkg_dir, "cefpython_py34.pyd")):
        search_paths = [
            # 10.00.40219.325 installs here on my system.
            os.path.join(system, "msvcp100.dll"),
        ]
        root_search_paths.append(search_paths)

    # Python 2.7
    if os.path.exists(os.path.join(pkg_dir, "cefpython_py27.pyd")):
        if ARCH32:
            search_paths = [
                # This runtime version is shipped with Python 2.7.14
                r"c:\Windows\winsxs\x86_microsoft.vc90.crt_1fc8b3b9a1e18e3b"
                r"_9.0.30729.1_none_e163563597edeada\msvcp90.dll",
            ]
        else:
            search_paths = [
                # This runtime version is shipped with Python 2.7.14
                r"c:\Windows\winsxs\amd64_microsoft.vc90.crt_1fc8b3b9a1e18e3b"
                r"_9.0.30729.1_none_99b61f5e8371c1d4\msvcp90.dll",
            ]
        root_search_paths.append(search_paths)

    assert len(root_search_paths)

    for search_paths in root_search_paths:
        found = False
        for path in search_paths:
            if os.path.exists(path):
                shutil.copy(path, pkg_dir)
                found = True
        if not found:
            raise Exception("C++ extension dll dependency not found."
                            " Search paths: {0}"
                            .format(", ".join(search_paths)))


def short_src_path(path):
    # Very long: \build\cef55_3.2883.1553.g80bd606_win32\
    find = os.path.basename(CEF_BINARIES_LIBRARIES)
    if len(find) > 12:
        path = path.replace(find, find[:12] + "*")
    path = path.replace(ROOT_DIR, "")
    return path


def short_dst_path(path):
    path = path.replace(SETUP_DIR, "")
    return path


if __name__ == "__main__":
    main()
