# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Build distribution packages for all architectures and all supported
python versions.

TODO: Mac support. Currently runs only on Windows/Linux.

Usage:
    build_distrib.py VERSION [--no-run-examples] [--no-rebuild]

Options:
    VERSION            Version number eg. 50.0
    --no-run-examples  Do not run examples while building cefpython modules.
                       Examples require interaction, closing window before
                       proceeding. Only unit tests will be run in such case.
    --no-rebuild       Do not rebuild cefpython modules. For internal use
                       so that changes to packaging can be quickly tested.


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
   to be in the build/ directory. It does not rebuild cefclient
   nor libcef_dll_wrapper libraries in these directories. If you
   would like to rebuild everything from scratch then delete subdirs
   manually (build_cefclient/, build_wrapper*/).
   When building CEF from sources copy build/chromium/src/cef/binary_distrib
   /cef_binary_*/ to the build/ directory.
4. Install and/or upgrade tools/requirements.txt and uninstall
   cefpython3 packages for all python versions
5. Run automate.py --prebuilt-cef using both Python 32-bit and Python 64-bit
6. Pack the prebuilt biaries using zip on Win/Mac and .tar.gz on Linux
   and move to build/distrib/
7. Reduce packages size (Issue #321). After packing prebuilt binaries,
   reduce its size so that packages will use the reduced prebuilt binaries.
8. Build cefpython modules for all supported Python versions on both
   32-bit and 64-bit
9. Make setup installers and pack them to zip (Win/Mac) or .tar.gz (Linux)
10. Make wheel packages
11. Move setup and wheel packages to the build/distrib/ directory
12. Test wheel packages installation and run unit tests using the
    installed wheel package.
13. Show summary
"""

from common import *
import glob
import os
import pprint
import re
import shutil
import subprocess
import tarfile
import zipfile

# Command line args
VERSION = ""
NO_RUN_EXAMPLES = False
NO_REBUILD = False

# Python versions
SUPPORTED_PYTHON_VERSIONS = [(2, 7), (3, 4), (3, 5), (3, 6)]

# Python search paths. It will use first Python found for specific version.
# Supports replacement of one environment variable in path eg.: %ENV_KEY%.
PYTHON_SEARCH_PATHS = dict(
    WINDOWS=[
        "C:\\Python*\\",
        "%LOCALAPPDATA%\\Programs\\Python\\Python*\\",
        "C:\\Program Files\\Python*\\",
        "C:\\Program Files (x86)\\Python*\\",
    ],
    LINUX=[
        "%PYENV_ROOT%/versions/*/bin",
    ],
)


def main():
    command_line_args()
    supported = list()
    for version in SUPPORTED_PYTHON_VERSIONS:
        supported.append("{major}.{minor}".format(major=version[0],
                                                  minor=version[1]))
    print("[build_distrib.py] Supported python versions: {supported}"
          .format(supported=" / ".join(supported)))
    clean_build_directories()
    if WINDOWS:
        pythons_32bit = search_for_pythons("32bit")
        pythons_64bit = search_for_pythons("64bit")
    elif LINUX:
        pythons_32bit = search_for_pythons("32bit") if ARCH32 else list()
        pythons_64bit = search_for_pythons("64bit") if ARCH64 else list()
    elif MAC:
        pythons_32bit = list()
        pythons_64bit = search_for_pythons("64bit")
    else:
        print("ERROR: Unsupported OS")
        sys.exit(1)
    check_pythons(pythons_32bit, pythons_64bit)
    install_upgrade_requirements(pythons_32bit + pythons_64bit)
    uninstall_cefpython3_packages(pythons_32bit + pythons_64bit)
    if not os.path.exists(DISTRIB_DIR):
        os.makedirs(DISTRIB_DIR)
    if pythons_32bit:
        run_automate_prebuilt_cef(pythons_32bit[0])
        pack_prebuilt_cef("32bit")
        if LINUX:
            reduce_package_size_issue_262("32bit")
        reduce_package_size_issue_321("32bit")
    if pythons_64bit is not None:
        run_automate_prebuilt_cef(pythons_64bit[0])
        pack_prebuilt_cef("64bit")
        if LINUX:
            reduce_package_size_issue_262("64bit")
        reduce_package_size_issue_321("64bit")
    if not NO_REBUILD:
        build_cefpython_modules(pythons_32bit + pythons_64bit)
    if pythons_32bit:
        make_packages(pythons_32bit[0], "32bit")
    if pythons_64bit:
        make_packages(pythons_64bit[0], "64bit")
    test_wheel_packages(pythons_32bit + pythons_64bit)
    show_summary(pythons_32bit, pythons_64bit)


def command_line_args():
    global VERSION, NO_RUN_EXAMPLES, NO_REBUILD
    version = get_version_from_command_line_args(__file__)
    if not version or "--help" in sys.argv:
        print(__doc__)
        sys.exit(1)
    VERSION = version
    if "--no-run-examples" in sys.argv:
        NO_RUN_EXAMPLES = True
        sys.argv.remove("--no-run-examples")
    if "--no-rebuild" in sys.argv:
        NO_REBUILD = True
        sys.argv.remove("--no-rebuild")
    args = sys.argv[1:]
    for arg in args:
        if arg == version:
            continue
        print("[build_distrib.py] Invalid argument: {arg}".format(arg=arg))
        sys.exit(1)


def clean_build_directories():
    print("[build_distrib.py] Clean build directories")

    # Delete distrib dir
    if os.path.exists(DISTRIB_DIR):
        print("[build_distrib.py] Delete directory: {distrib_dir}/"
              .format(distrib_dir=os.path.basename(DISTRIB_DIR)))
        shutil.rmtree(DISTRIB_DIR)

    if not NO_REBUILD:
        # Delete build_cefpython/ dir
        if os.path.exists(BUILD_CEFPYTHON):
            print("[build_distirb.py] Delete directory: {dir}/"
                  .format(dir=os.path.basename(BUILD_CEFPYTHON)))
            shutil.rmtree(BUILD_CEFPYTHON)
        # Delete cefpython_binary_*/ dirs
        delete_cefpython_binary_dir("32bit")
        delete_cefpython_binary_dir("64bit")

    # Delete cef binaries and libraries dirs
    delete_cef_binaries_libraries_dir("32bit")
    delete_cef_binaries_libraries_dir("64bit")


def delete_cefpython_binary_dir(arch):
    cefpython_binary = get_cefpython_binary_basename(
            postfix2=get_os_postfix2_for_arch(arch))
    assert cefpython_binary, cefpython_binary
    cefpython_binary = os.path.join(BUILD_DIR, cefpython_binary)
    if os.path.exists(cefpython_binary):
        print("[build_distrib.py] Delete directory: {dir}/"
              .format(dir=os.path.basename(cefpython_binary)))
        shutil.rmtree(cefpython_binary)


def delete_cef_binaries_libraries_dir(arch):
    cef_binlib = get_cef_binaries_libraries_basename(
            postfix2=get_os_postfix2_for_arch(arch))
    assert cef_binlib, cef_binlib
    cef_binlib = os.path.join(BUILD_DIR, cef_binlib)
    if os.path.exists(cef_binlib):
        print("[build_distrib.py] Delete directory: {dir}/"
              .format(dir=os.path.basename(cef_binlib)))
        shutil.rmtree(cef_binlib)


def search_for_pythons(search_arch):
    """Returns pythons ordered by version from lowest to highest."""
    pythons_found = list()
    for pattern in PYTHON_SEARCH_PATHS[SYSTEM]:
        # Replace env variable in path
        match = re.search(r"%(\w+)%", pattern)
        if match:
            env_key = match.group(1)
            if env_key in os.environ:
                pattern = pattern.replace(match.group(0), os.environ[env_key])
            else:
                print("ERROR: Env variable not found: {env_key}"
                      .format(env_key=env_key))
                sys.exit(1)
        results = glob.glob(pattern)
        for path in results:
            if os.path.isdir(path):
                python = os.path.join(path,
                                      "python{ext}".format(ext=EXECUTABLE_EXT))
                version_code = ("import sys;"
                                "print(str(sys.version_info[:3]));")
                if not os.path.isfile(python):
                    print("ERROR: Python executable not found: {executable}"
                          .format(executable=python))
                    sys.exit(1)
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
                supported_python = python
                break
        if supported_python:
            ret_pythons.append(supported_python)
    return ret_pythons


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


def install_upgrade_requirements(pythons):
    for python in pythons:
        print("[build_distrib.py] pip install/upgrade requirements.txt"
              " for: {name}".format(name=python["name"]))

        # Upgrade pip
        command = ("\"{python}\" -m pip install --upgrade pip"
                   .format(python=python["executable"]))
        command = sudo_command(command, python=python["executable"])
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR while upgrading pip")
            sys.exit(1)

        # Install/upgrade requirements.txt
        requirements = os.path.join(TOOLS_DIR, "requirements.txt")
        command = ("\"{python}\" -m pip install --upgrade -r {requirements}"
                   .format(python=python["executable"],
                           requirements=requirements))
        command = sudo_command(command, python=python["executable"])
        pcode = subprocess.call(command, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR while running pip install/upgrade")
            sys.exit(1)


def uninstall_cefpython3_packages(pythons):
    for python in pythons:
        print("[build_distrib.py] Uninstall cefpython3 package"
              " for: {name}".format(name=python["name"]))

        # Check if package is installed
        command = ("\"{python}\" -m pip show cefpython3"
                   .format(python=python["executable"]))
        try:
            output = subprocess.check_output(command, shell=True)
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
        command = sudo_command(command, python=python["executable"])
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
    code = subprocess.call(command, shell=True)
    if code != 0:
        print("[build_distrib.py] ERROR while running automate.py")
        sys.exit(1)


def pack_prebuilt_cef(arch):
    prebuilt_basename = get_cef_binaries_libraries_basename(
                get_os_postfix2_for_arch(arch))
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
        with tarfile.open(archive, "w:gz") as tar:
            tar.add(path, arcname=os.path.basename(path))
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


def reduce_package_size_issue_262(arch):
    """Linux only: libcef.so is huge (500 MB) in Chrome v54+. Issue #262."""
    print("[build_distrib.py] Reduce package size for {arch} (Issue #262)"
          .format(arch=arch))
    prebuilt_basename = get_cef_binaries_libraries_basename(
                get_os_postfix2_for_arch(arch))
    bin_dir = os.path.join(prebuilt_basename, "bin")

    # Run `strip` command on `libcef.so`
    libcef_so = os.path.join(bin_dir, "libcef.so")
    print("[build_distrib.py] Strip {libcef_so}"
          .format(libcef_so=os.path.basename(libcef_so)))
    command = "strip {libcef_so}".format(libcef_so=libcef_so)
    pcode = subprocess.call(command, shell=True)
    assert pcode, "strip command failed"


def reduce_package_size_issue_321(arch):
    """PyPI has file size limit and must reduce package size. Issue #321."""
    print("[build_distrib.py] Reduce package size for {arch} (Issue #321)"
          .format(arch=arch))
    prebuilt_basename = get_cef_binaries_libraries_basename(
                get_os_postfix2_for_arch(arch))
    bin_dir = os.path.join(prebuilt_basename, "bin")

    # Delete sample applications to reduce package size
    sample_apps = ["cefclient", "cefsimple", "ceftests"]
    for sample_app_name in sample_apps:
        sample_app = os.path.join(bin_dir, sample_app_name + APP_EXT)
        # Not on all platforms sample apps may be available
        if os.path.exists(sample_app):
            print("[build_distrib.py] Delete {sample_app}"
                  .format(sample_app=os.path.basename(sample_app)))
            if os.path.isdir(sample_app):
                shutil.rmtree(sample_app)
            else:
                os.remove(sample_app)
            # Also delete subdirs eg. cefclient_files/, ceftests_files/
            files_subdir = os.path.join(bin_dir, sample_app_name + "_files")
            if os.path.isdir(files_subdir):
                print("[build_distrib.py] Delete directory: {dir}/"
                      .format(dir=os.path.basename(files_subdir)))
                shutil.rmtree(files_subdir)

    # Strip symbols from cefpython .so modules to reduce size
    modules = glob.glob(os.path.join(CEFPYTHON_BINARY, "*.so"))
    for module in modules:
        print("[build_distrib.py] strip {module}"
              .format(module=os.path.basename(module)))
        command = "strip {module}".format(module=module)
        assert os.system(command) == 0, "strip command failed"


def build_cefpython_modules(pythons):
    for python in pythons:
        print("[build_distrib.py] Build cefpython module for {python_name}"
              .format(python_name=python["name"]))
        flags = ""
        if NO_RUN_EXAMPLES:
            flags += " --no-run-examples"
        # On Linux/Mac Makefiles are used and must pass --clean flag
        command = ("\"{python}\" {build_py} {version} --clean {flags}"
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
    pcode = subprocess.call(installer_command, cwd=BUILD_DIR, shell=True)
    if pcode != 0:
        print("[build_distrib.py] ERROR: failed to make setup package for"
              " {arch}".format(arch=arch))
        sys.exit(1)

    # Pack setup package and move to distrib dir
    print("[build_distrib.py] Pack setup package for {arch}..."
          .format(arch=arch))
    setup_basename = get_setup_installer_basename(
            VERSION, get_os_postfix2_for_arch(arch))
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
    pcode = subprocess.call(wheel_command, cwd=setup_dir, shell=True)
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


def test_wheel_packages(pythons):
    """Test wheel packages installation and run unit tests."""
    uninstall_cefpython3_packages(pythons)
    for python in pythons:
        print("[build_distrib.py] Test wheel package (install, unittests) for"
              " {python_name}".format(python_name=python["name"]))
        platform_tag = get_pypi_postfix2_for_arch(python["arch"])
        whl_pattern = (r"*-{platform_tag}.whl"
                       .format(platform_tag=platform_tag))
        wheels = glob.glob(os.path.join(DISTRIB_DIR, whl_pattern))
        assert len(wheels) == 1, ("No wheels found in distrib dir for %s"
                                  % python["arch"])

        # Install wheel
        command = ("\"{python}\" -m pip install {wheel}"
                   .format(python=python["executable"],
                           wheel=os.path.basename(wheels[0])))
        command = sudo_command(command, python=python["executable"])
        pcode = subprocess.call(command, cwd=DISTRIB_DIR, shell=True)
        if pcode != 0:
            print("[build_distrib.py] Wheel package installation failed for"
                  " {python_name}".format(python_name=python["name"]))
            sys.exit(1)

        # Run unittests using the installed wheel package
        command = ("\"{python}\" {unittests}"
                   .format(python=python["executable"],
                           unittests=os.path.join(UNITTESTS_DIR,
                                                  "main_test.py")))
        pcode = subprocess.call(command, cwd=DISTRIB_DIR, shell=True)
        if pcode != 0:
            print("[build_distrib.py] ERROR: Unit tests failed for"
                  " {python_name}".format(python_name=python["name"]))
            sys.exit(1)


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
    print("[build_distrib.py] Everything OK. Distribution packages created.")


if __name__ == "__main__":
    main()
