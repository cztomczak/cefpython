# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Build distribution packages for all architectures and all supported
python versions.

TODO: Linux/Mac support. Currently runs only on Windows.

Usage:
    build_distrib.py VERSION [--no-run-examples]

Options:
    VERSION            Version number eg. 50.0
    --no-run-examples  Do not run examples while building cefpython modules.
                       Only unit tests will be run in such case.

This script does the following:
1. Expects that all supported python versions are installed
   a) On Windows search for Pythons in the multiple default install
      locations
   b) On Mac use system Python 2.7 and Python 3 from ~/.pyenv/versions/
      directory
   c) On Linux use only Pythons from ~/.pyenv/versions/ directory
2. Expects that all python compilers for supported python versions
   are installed. See docs/Build-instructions.md > Requirements.
3. Expects cef_binary*/ directories from Spotify Automated Builds
   to be in the build/ directory
4. Install and/or upgrade tools/requirements.txt and uninstall
   cefpython3 packages for all python versions
5. Run automate.py --prebuilt-cef using both Python 32-bit and Python 64-bit
6. Pack the prebuilt biaries using zip on Win/Mac and .tar.gz on Linux
   and move to build/distrib/
7. Build cefpython modules for all supported Python versions on both
   32-bit and 64-bit
8. Make setup installers and pack them to zip (Win/Mac) or .tar.gz (Linux)
9. Make wheel packages
10. Move setup and wheel packages to the build/distrib/ directory
"""

from common import *
import glob
import os
import pprint
import re
import shutil
import subprocess
import zipfile

# Command line args
VERSION = ""
NO_RUN_EXAMPLES = False

# Pythons
SUPPORTED_PYTHON_VERSIONS = [(2, 7), (3, 4), (3, 5), (3, 6)]
PYTHON_SEARCH_PATHS_WINDOWS = [
    "C:\\Python*\\",
    "%LocalAppData%\\Programs\\Python\\Python*\\",
    "C:\\Program Files\\Python*\\",
    "C:\\Program Files (x86)\\Python*\\",
]


def main():
    command_line_args()
    print("[build_distrib.py] Supported python versions:")
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(SUPPORTED_PYTHON_VERSIONS)
    clean_build_directories()
    pythons_32bit = list()
    pythons_64bit = list()
    if WINDOWS:
        pythons_32bit = search_for_pythons("32bit")
        pythons_64bit = search_for_pythons("64bit")
    check_pythons(pythons_32bit, pythons_64bit)
    install_upgrade_requirements(pythons_32bit + pythons_64bit)
    uninstall_cefpython3_packages(pythons_32bit + pythons_64bit)
    if not os.path.exists(DISTRIB_DIR):
        os.makedirs(DISTRIB_DIR)
    if pythons_32bit:
        run_automate_prebuilt_cef(pythons_32bit[0])
        pack_prebuilt_cef(pythons_32bit[0]["arch"])
    if pythons_64bit is not None:
        run_automate_prebuilt_cef(pythons_64bit[0])
        pack_prebuilt_cef(pythons_64bit[0]["arch"])
    build_cefpython_modules(pythons_32bit + pythons_64bit)
    if pythons_32bit:
        make_packages(pythons_32bit[0], "32bit")
    if pythons_64bit:
        make_packages(pythons_64bit[0], "64bit")
    show_summary(pythons_32bit, pythons_64bit)


def command_line_args():
    global VERSION, NO_RUN_EXAMPLES
    version = get_version_from_command_line_args(__file__)
    if not version:
        print(__doc__)
        sys.exit(1)
    VERSION = version
    if "--no-run-examples" in sys.argv:
        NO_RUN_EXAMPLES = True


def clean_build_directories():
    print("[build_distrib.py] Clean build directories")

    # Distrib dir
    if os.path.exists(DISTRIB_DIR):
        print("[build_distrib.py] Delete directory: {distrib_dir}/"
              .format(distrib_dir=os.path.basename(DISTRIB_DIR)))
        shutil.rmtree(DISTRIB_DIR)

    # build_cefpython/ dir
    if os.path.exists(BUILD_CEFPYTHON):
        print("[build_distirb.py] Delete directory: {dir}/"
              .format(dir=os.path.basename(BUILD_CEFPYTHON)))
        shutil.rmtree(BUILD_CEFPYTHON)

    # cefpython_binary_*/ dirs
    delete_cefpython_binary_dir("32bit")
    delete_cefpython_binary_dir("64bit")

    # cef binaries and libraries dirs
    delete_cef_binaries_libraries_dir("32bit")
    delete_cef_binaries_libraries_dir("64bit")


def delete_cefpython_binary_dir(arch):
    cefpython_binary = get_cefpython_binary_basename(
            postfix2=get_postfix2_for_arch(arch))
    assert cefpython_binary, cefpython_binary
    cefpython_binary = os.path.join(BUILD_DIR, cefpython_binary)
    if os.path.exists(cefpython_binary):
        print("[build_distrib.py] Delete directory: {dir}/"
              .format(dir=os.path.basename(cefpython_binary)))
        shutil.rmtree(cefpython_binary)


def delete_cef_binaries_libraries_dir(arch):
    cef_binlib = get_cef_binaries_libraries_basename(
            postfix2=get_postfix2_for_arch(arch))
    assert cef_binlib, cef_binlib
    cef_binlib = os.path.join(BUILD_DIR, cef_binlib)
    if os.path.exists(cef_binlib):
        print("[build_distrib.py] Delete directory: {dir}/"
              .format(dir=os.path.basename(cef_binlib)))
        shutil.rmtree(cef_binlib)


def check_pythons(pythons_32bit, pythons_64bit):
    pp = pprint.PrettyPrinter(indent=4)
    if pythons_32bit:
        print("[build_distrib.py] Pythons 32-bit found:")
        pp.pprint(pythons_32bit)
    if WINDOWS and len(pythons_32bit) != len(SUPPORTED_PYTHON_VERSIONS):
        print("[build_distrib.py] ERROR: Couldn't find all supported"
              " python 32-bit installations. Found: {found}."
              .format(found=len(pythons_32bit)))
        sys.exit(1)
    if pythons_64bit:
        print("[build_distrib.py] Pythons 64-bit found:")
        pp.pprint(pythons_64bit)
    if len(pythons_64bit) != len(SUPPORTED_PYTHON_VERSIONS):
        print("[build_distrib.py] ERROR: Couldn't find all supported"
              " python 64-bit installations. Found: {found}."
              .format(found=len(pythons_64bit)))
        sys.exit(1)


def search_for_pythons(search_arch):
    print("[build_distrib.py] Search for Pythons...")
    if WINDOWS:
        return search_for_pythons_windows(search_arch)
    raise Exception("Only Windows platform supported currently")


def search_for_pythons_windows(search_arch):
    """Returns pythons ordered by version from lowest to highest."""
    pythons_found = list()
    for pattern in PYTHON_SEARCH_PATHS_WINDOWS:
        pattern = pattern.replace("%LocalAppData%",
                                  os.environ["LOCALAPPDATA"])
        results = glob.glob(pattern)
        for path in results:
            if os.path.isdir(path):
                python = os.path.join(path, "python.exe")
                version_code = ("import sys;"
                                "print(str(sys.version_info[:3]));")
                version_str = subprocess.check_output([python, "-c",
                                                       version_code])
                version_str = version_str.strip()
                match = re.search("^\((\d+), (\d+), (\d+)\)$", version_str)
                assert match, version_str
                major = match.group(1)
                minor = match.group(2)
                micro = match.group(3)
                version_tuple2 = (int(major), int(minor))
                version_tuple3 = (int(major), int(minor), int(micro))
                arch_code = ("import platform;"
                             "print(str(platform.architecture()[0]));")
                arch = subprocess.check_output([python, "-c", arch_code])
                arch = arch.strip()
                if version_tuple2 in SUPPORTED_PYTHON_VERSIONS \
                        and arch == search_arch:
                    name = ("Python {major}.{minor}.{micro} {arch}"
                            .format(major=major, minor=minor, micro=micro,
                                    arch=arch))
                    pythons_found.append(dict(
                        version2=version_tuple2,
                        version3=version_tuple3,
                        arch=arch,
                        executable=python,
                        name=name))
    ret_pythons = list()
    for version_tuple in SUPPORTED_PYTHON_VERSIONS:
        supported_python = None
        for python in pythons_found:
            if python["version2"] == version_tuple:
                # Always go through the whole loop and save the last
                # python executable for the given version (eg. 2.7),
                # so that the latest version is used (eg. 2.7.12).
                # This is assuming that glob.glob sorted directories.
                supported_python = python
        if supported_python:
            ret_pythons.append(supported_python)
    return ret_pythons


def install_upgrade_requirements(pythons):
    for python in pythons:
        print("[build_distrib.py] pip install/upgrade requirements.txt"
              " for: {name}".format(name=python["name"]))

        # Upgrade pip
        command = "\"{python}\" -m pip install --upgrade pip"
        command = command.format(python=python["executable"])
        if python["executable"].startswith("/usr/"):
            command = "sudo {command}".format(command=command)
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR while upgrading pip")
            sys.exit(1)

        # Install/upgrade requirements.txt
        requirements = os.path.join(TOOLS_DIR, "requirements.txt")
        command = "\"{python}\" -m pip install --upgrade -r {requirements}"
        command = command.format(python=python["executable"],
                                 requirements=requirements)
        if python["executable"].startswith("/usr/"):
            command = "sudo {command}".format(command=command)
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR while running pip install/upgrade")
            sys.exit(1)


def uninstall_cefpython3_packages(pythons):
    for python in pythons:
        print("[build_distrib.py] pip uninstall cefpython3 package"
              " for: {name}".format(name=python["name"]))

        # Check if package is installed
        command = ("\"{python}\" -m pip show cefpython3"
                   .format(python=python["executable"]))
        try:
            output = subprocess.check_output(command)
        except subprocess.CalledProcessError, exc:
            # pip show returns error code when package is not installed
            output = exc.output
        if not len(output.strip()):
            # Package is not installed - info is an empty string
            print("[build_distrib.py] Not installed")
            continue

        # Uninstall package. Only uninstall if package is installed,
        # otherwise error code is returned.
        command = ("\"{python}\" -m pip uninstall -y cefpython3"
                   .format(python=python["executable"]))
        if python["executable"].startswith("/usr/"):
            command = "sudo {command}".format(command=command)
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR while uninstall cefpython3"
                  " package using pip")
            sys.exit(1)


def run_automate_prebuilt_cef(python):
    print("[build_distrib.py] Run automate.py --prebuilt-cef for {arch}"
          .format(arch=python["arch"]))
    automate = os.path.join(TOOLS_DIR, "automate.py")
    command = ("\"{python}\" {automate} --prebuilt-cef"
               .format(python=python["executable"], automate=automate))
    code = subprocess.call(command)
    if code != 0:
        print("[build_distrib.py] ERROR while running automate.py")
        sys.exit(1)


def pack_prebuilt_cef(arch):
    prebuilt_basename = get_cef_binaries_libraries_basename(
                get_postfix2_for_arch(arch))
    print("[build_distrib.py] Pack directory: {dir}/ ..."
          .format(dir=prebuilt_basename))
    prebuilt_dir = os.path.join(BUILD_DIR, prebuilt_basename)
    assert os.path.exists(prebuilt_dir), prebuilt_dir
    archive = pack_directory(prebuilt_dir, base_path=BUILD_DIR)
    shutil.move(archive, DISTRIB_DIR)
    print("[build_distrib.py] Created archive in distrib dir: {archive}"
          .format(archive=os.path.basename(archive)))


def pack_directory(path, base_path):
    if path.endswith(os.path.sep):
        path = path[:-1]
    ext = ".zip" if WINDOWS or MAC else ".tar.gz"
    archive = path + ext
    if os.path.exists(archive):
        os.remove(archive)
    if WINDOWS or MAC:
        zip_directory(path, base_path=base_path, archive=archive)
    else:
        # LINUX
        raise Exception("pack_directory(): Linux not yet supported")  # TODO
    assert os.path.isfile(archive), archive
    return archive


def zip_directory(path, base_path, archive):
    original_dir = os.getcwd()
    os.chdir(base_path)
    path = path.replace(base_path, "")
    if path[0] == os.path.sep:
        path = path[1:]
    zipf = zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk(path):
        for file_ in files:
            zipf.write(os.path.join(root, file_))
    zipf.close()
    os.chdir(original_dir)


def build_cefpython_modules(pythons):
    for python in pythons:
        print("[build_distrib.py] Build cefpython module for {python_name}"
              .format(python_name=python["name"]))
        flags = ""
        if NO_RUN_EXAMPLES:
            flags += " --no-run-examples"
        command = ("\"{python}\" {build_py} {version} {flags}"
                   .format(python=python["executable"],
                           build_py=os.path.join(TOOLS_DIR, "build.py"),
                           version=VERSION,
                           flags=flags))
        # build.py may require sudo if system python, so shell=True
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR: failed to build cefpython"
                  " module for {python_name}"
                  .format(python_name=python["name"]))
            sys.exit(1)
        print("[build_distrib.py] Built successfully cefpython module for"
              " {python_name}".format(python_name=python["name"]))
    print("[build_distrib.py] Successfully built cefpython modules for"
          " all Python versions")


def make_packages(python, arch):
    # Make setup package
    print("[build_distrib.py] Make setup package for {arch}..."
          .format(arch=arch))
    make_installer_py = os.path.join(TOOLS_DIR, "make_installer.py")
    installer_command = ("\"{python}\" {make_installer_py} {version}"
                         .format(python=python["executable"],
                                 make_installer_py=make_installer_py,
                                 version=VERSION))
    pcode = subprocess.call(installer_command, cwd=BUILD_DIR)
    if pcode != 0:
        print("[build_distrib.py] ERROR: failed to make setup package for"
              " {arch}".format(arch=arch))
        sys.exit(1)

    # Pack setup package and move to distrib dir
    print("[build_distrib.py] Pack setup package for {arch}..."
          .format(arch=arch))
    setup_basename = get_setup_installer_basename(
            VERSION, get_postfix2_for_arch(arch))
    setup_dir = os.path.join(BUILD_DIR, setup_basename)
    archive = pack_directory(setup_dir, BUILD_DIR)
    shutil.move(archive, DISTRIB_DIR)

    # Make wheel package
    print("[build_distrib.py] Make wheel package for {arch}..."
          .format(arch=arch))
    wheel_args = "bdist_wheel --universal"
    wheel_command = ("\"{python}\" setup.py {wheel_args}"
                     .format(python=python["executable"],
                             wheel_args=wheel_args))
    pcode = subprocess.call(wheel_command, cwd=setup_dir)
    if pcode != 0:
        print("[build_distrib.py] ERROR: failed to make wheel package for"
              " {arch}".format(arch=arch))
        sys.exit(1)

    # Move wheel package
    files = glob.glob(os.path.join(setup_dir, "dist", "*.whl"))
    assert len(files) == 1, ".whl file not found"
    shutil.move(files[0], DISTRIB_DIR)

    # Delete setup directory
    print("[build_distrib.py] Delete setup directory: {setup_dir}/"
          .format(setup_dir=os.path.basename(setup_dir)))
    shutil.rmtree(setup_dir)


def show_summary(pythons_32bit, pythons_64bit):
    print("[build_distrib.py] SUMMARY:")
    print("  Pythons 32bit ({count})".format(count=len(pythons_32bit)))
    for python in pythons_32bit:
        print("    {python_name}".format(python_name=python["name"]))
    print("  Pythons 64bit ({count})".format(count=len(pythons_64bit)))
    for python in pythons_64bit:
        print("    {python_name}".format(python_name=python["name"]))
    files = glob.glob(os.path.join(DISTRIB_DIR, "*"))
    print("  Files in the build/{distrib_basename}/ directory ({count})"
          .format(distrib_basename=os.path.basename(DISTRIB_DIR),
                  count=len(files)))
    for file_ in files:
        print("    {filename}".format(filename=os.path.basename(file_)))
    print("[build_distrib.py] Done. Distribution packages created.")


if __name__ == "__main__":
    main()
