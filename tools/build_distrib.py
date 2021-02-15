# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Build distribution packages for all architectures and all supported
python versions.

Usage:
    build_distrib.py VERSION [--unittests] [--no-rebuild] [--no-automate]
                             [--allow-partial]

Options:
    VERSION            Version number eg. 50.0
    --unittests        Run only unit tests. Do not run examples while building
                       cefpython modules. Examples require interaction such as
                       closing window before proceeding.
    --no-rebuild       Do not rebuild cefpython modules. For internal use
                       so that changes to packaging can be quickly tested.
    --no-automate      Do not run automate.py --prebuilt-cef. This flag
                       allows to use CEF prebuilt binaries and libraries
                       downloaded from CEF Python's Github releases to
                       build distribution pacakges.
    --allow-partial    Do not require all supported Python versions to
                       be installed. If some are missing they just won't
                       be included in distribution.


This script does the following:
1. Expects that all supported python versions are installed
   a) On Windows search for Pythons in the multiple default install
      locations
   b) On Linux use only Pythons from ~/.pyenv/versions/
      directory
   c) On Mac use Pythons from ~/.pyenv/versions/ and /usr/local/bin/python
      For example will use Python 2.7.13 from /usr/local/bin/ only
      when 2.7 was not found in ~/.pyenv/versions/.
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
   32-bit and 64-bit. Backup and restore subprocess executable on Windows
   built with Python 2.7 (Issue #342).
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
# import tarfile  # Currently using zip on all platforms
import zipfile

# Command line args
VERSION = ""
UNITTESTS = False
NO_REBUILD = False
NO_AUTOMATE = False
ALLOW_PARTIAL = False

# Python versions
SUPPORTED_PYTHON_VERSIONS = [(2, 7), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9)]

# Python search paths. It will use first Python found for specific version.
# Supports replacement of one environment variable in path eg.: %ENV_KEY%.
PYTHON_SEARCH_PATHS = dict(
    WINDOWS=[
        "C:\\Python??*\\",
        "C:\\Pythons\\Python*\\",
        "%LOCALAPPDATA%\\Programs\\Python\\Python*\\",
        "C:\\Program Files\\Python*\\",
        "C:\\Program Files (x86)\\Python*\\",
    ],
    LINUX=[
        "%PYENV_ROOT%/versions/*/bin",
    ],
    MAC=[
        "%PYENV_ROOT%/versions/*/bin",
        "/usr/local/bin",
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
        if not NO_AUTOMATE:
            run_automate_prebuilt_cef(pythons_32bit[0])
        pack_prebuilt_cef("32bit")
        if LINUX:
            reduce_package_size_issue262("32bit")
        remove_unnecessary_package_files("32bit")
    if pythons_64bit:
        if not NO_AUTOMATE:
            run_automate_prebuilt_cef(pythons_64bit[0])
        pack_prebuilt_cef("64bit")
        if LINUX:
            reduce_package_size_issue262("64bit")
        remove_unnecessary_package_files("64bit")
    if not NO_REBUILD:
        build_cefpython_modules(pythons_32bit, "32bit")
        build_cefpython_modules(pythons_64bit, "64bit")
    if pythons_32bit:
        make_packages(pythons_32bit[0], "32bit", pythons_32bit)
    if pythons_64bit:
        make_packages(pythons_64bit[0], "64bit", pythons_64bit)
    test_wheel_packages(pythons_32bit + pythons_64bit)
    show_summary(pythons_32bit, pythons_64bit)


def command_line_args():
    global VERSION, UNITTESTS, NO_REBUILD, NO_AUTOMATE, ALLOW_PARTIAL
    version = get_version_from_command_line_args(__file__)
    if not version or "--help" in sys.argv:
        print(__doc__)
        sys.exit(1)
    VERSION = version
    if "--unittests" in sys.argv:
        UNITTESTS = True
        sys.argv.remove("--unittests")
    if "--no-rebuild" in sys.argv:
        NO_REBUILD = True
        sys.argv.remove("--no-rebuild")
    if "--no-automate" in sys.argv:
        NO_AUTOMATE = True
        sys.argv.remove("--no-automate")
    if "--allow-partial" in sys.argv:
        ALLOW_PARTIAL = True
        sys.argv.remove("--allow-partial")
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
    if not NO_AUTOMATE:
        # Delete cef binlib dir only if cef_binary dir exists,
        # otherwise you will end up with cef binlib directory
        # deleted and script failing further when calling
        # automate.py --prebuilt-cef.
        version = get_cefpython_version()
        # 32-bit
        if not MAC:
            postfix2 = get_cef_postfix2_for_arch("32bit")
            cef_binary_dir = "cef_binary_{cef_version}_{postfix2}"\
                             .format(cef_version=version["CEF_VERSION"],
                                     postfix2=postfix2)
            if len(glob.glob(cef_binary_dir)) != 1:
                raise Exception("Directory not found: "+cef_binary_dir)
        # 64-bit
        postfix2 = get_cef_postfix2_for_arch("64bit")
        cef_binary_dir = "cef_binary_{cef_version}_windows64"\
                         .format(cef_version=version["CEF_VERSION"],
                                 postfix2=postfix2)
        if len(glob.glob(cef_binary_dir)) != 1:
            raise Exception("Directory not found: "+cef_binary_dir)

        # Delete
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
                if sys.version_info >= (3, 0):
                    version_str = version_str.decode("utf-8")
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
                if sys.version_info >= (3, 0):
                    arch = arch.decode("utf-8")
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
    check_32bit = True
    check_64bit = True
    if MAC:
        check_32bit = False
    elif LINUX:
        if pythons_64bit:
            check_32bit = False
        elif pythons_32bit:
            check_64bit = False

    pp = pprint.PrettyPrinter(indent=4)
    if pythons_32bit:
        print("[build_distrib.py] Pythons 32-bit found:")
        pp.pprint(pythons_32bit)
    if check_32bit and len(pythons_32bit) != len(SUPPORTED_PYTHON_VERSIONS) \
            and not ALLOW_PARTIAL:
        print("[build_distrib.py] ERROR: Couldn't find all supported"
              " python 32-bit installations. Found: {found}."
              .format(found=len(pythons_32bit)))
        sys.exit(1)
    if pythons_64bit:
        print("[build_distrib.py] Pythons 64-bit found:")
        pp.pprint(pythons_64bit)
    if check_64bit and len(pythons_64bit) != len(SUPPORTED_PYTHON_VERSIONS) \
            and not ALLOW_PARTIAL:
        print("[build_distrib.py] ERROR: Couldn't find all supported"
              " python 64-bit installations. Found: {found}."
              .format(found=len(pythons_64bit)))
        sys.exit(1)


def install_upgrade_requirements(pythons):
    for python in pythons:
        print("[build_distrib.py] pip install/upgrade requirements.txt"
              " for: {name}".format(name=python["name"]))

        # Upgrade pip
        pip_version = "pip"
        # Old Python versions require specific versions of pip, latest versions are broken with these.
        if python["version2"] == (2, 7):
            pip_version = "pip==20.3.4"
        elif python["version2"] == (3, 4):
            pip_version = "pip==19.1.1"
        command = ("\"{python}\" -m pip install --upgrade {pip_version}"
                   .format(python=python["executable"], pip_version=pip_version))
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
        except subprocess.CalledProcessError as exc:
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
    # ext = ".zip" if WINDOWS or MAC else ".tar.gz"
    ext = ".zip"
    archive = path + ext
    if os.path.exists(archive):
        os.remove(archive)
    if WINDOWS or MAC:
        zip_directory(path, base_path=base_path, archive=archive)
    else:
        zip_directory(path, base_path=base_path, archive=archive)
        # with tarfile.open(archive, "w:gz") as tar:
        #     tar.add(path, arcname=os.path.basename(path))
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


def reduce_package_size_issue262(arch):
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
    assert pcode == 0, "strip command failed"


def remove_unnecessary_package_files(arch):
    """Do not ship sample applications (cefclient etc) with the package.
    They increase size and also are an additional unnecessary factor
    when dealing with false-positives in Anti-Virus software."""
    print("[build_distrib.py] Reduce package size for {arch} (Issue #321)"
          .format(arch=arch))
    prebuilt_basename = get_cef_binaries_libraries_basename(
                get_os_postfix2_for_arch(arch))
    bin_dir = os.path.join(prebuilt_basename, "bin")
    delete_cef_sample_apps(caller_script=__file__, bin_dir=bin_dir)


def build_cefpython_modules(pythons, arch):
    for python in pythons:
        print("[build_distrib.py] Build cefpython module for {python_name}"
              .format(python_name=python["name"]))
        flags = ""
        if UNITTESTS:
            flags += " --unittests"
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
        # Issue #342
        backup_subprocess_executable_issue342(python)

    # Issue #342
    restore_subprocess_executable_issue342(arch)

    print("[build_distrib.py] Successfully built cefpython modules for {arch}"
          .format(arch=arch))


def backup_subprocess_executable_issue342(python):
    """Use subprocess executable built by Python 3.4 to have the least amount of
    false-positives by AVs. Windows-only issue."""
    if not WINDOWS:
        return
    if python["version2"] == (2, 7):
        print("[build_distrib.py] Backup subprocess executable built"
              " with Python 3.4 (Issue #342)")
        cefpython_binary_basename = get_cefpython_binary_basename(
                get_os_postfix2_for_arch(python["arch"]))
        cefpython_binary = os.path.join(BUILD_DIR, cefpython_binary_basename)
        assert os.path.isdir(cefpython_binary)
        src = os.path.join(cefpython_binary, "subprocess.exe")
        dst = os.path.join(BUILD_CEFPYTHON,
                           "subprocess_py34_{arch}_issue342.exe"
                           .format(arch=python["arch"]))
        shutil.copy(src, dst)


def restore_subprocess_executable_issue342(arch):
    """Use subprocess executable built by Python 3.4 to have the least amount of
    false-positives by AVs. Windows-only issue."""
    if not WINDOWS:
        return
    print("[build_distrib.py] Restore subprocess executable built"
          " with Python 3.4 (Issue #342)")
    cefpython_binary_basename = get_cefpython_binary_basename(
            get_os_postfix2_for_arch(arch))
    cefpython_binary = os.path.join(BUILD_DIR, cefpython_binary_basename)
    assert os.path.isdir(cefpython_binary)
    src = os.path.join(BUILD_CEFPYTHON,
                       "subprocess_py34_{arch}_issue342.exe"
                       .format(arch=arch))
    assert os.path.isfile(src)
    dst = os.path.join(cefpython_binary, "subprocess.exe")
    shutil.copy(src, dst)


def make_packages(python, arch, all_pythons):
    """Make setup and wheel packages."""
    print("[build_distrib.py] Make setup package for {arch}..."
          .format(arch=arch))

    # Call make_installer.py
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
    check_cpp_extension_dependencies_issue359(setup_dir, all_pythons)
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


def check_cpp_extension_dependencies_issue359(setup_dir, all_pythons):
    """Windows only: check if msvcpXX.dll exist for all Python versions.
    Issue #359."""
    if not WINDOWS:
        return
    checked_any = False
    for python in all_pythons:
        if python["version2"] in ((3, 5), (3, 6), (3, 7), (3, 8), (3, 9)):
            checked_any = True
            if not os.path.exists(os.path.join(setup_dir, "cefpython3",
                                               "msvcp140.dll")):
                raise Exception("C++ ext dependency missing: msvcp140.dll")
        elif python["version2"] == (3, 4):
            checked_any = True
            if not os.path.exists(os.path.join(setup_dir, "cefpython3",
                                               "msvcp100.dll")):
                raise Exception("C++ ext dependency missing: msvcp100.dll")
        elif python["version2"] == (2, 7):
            if not os.path.exists(os.path.join(setup_dir, "cefpython3",
                                               "msvcp90.dll")):
                raise Exception("C++ ext dependency missing: msvcp90.dll")
            checked_any = True
    assert checked_any


def test_wheel_packages(pythons):
    """Test wheel packages installation and run unit tests."""
    uninstall_cefpython3_packages(pythons)
    for python in pythons:
        print("[build_distrib.py] Test wheel package (install, unittests) for"
              " {python_name}".format(python_name=python["name"]))
        platform_tag = get_pypi_postfix2_for_arch(python["arch"])
        whl_pattern = (r"*{platform_tag}.whl"
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
                                                  "_test_runner.py")))
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
