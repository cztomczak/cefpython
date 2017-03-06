# Copyright (c) 2016 CEF Python, see the Authors file. All rights reserved.

"""
Prepares CEF binaries and libraries for work with the build.py tool.

Option 1 is to build CEF from sources with the CEF Python patches applied
using the --build-cef flag.

Option 2 is to use CEF binaries from Spotify Automated Builds using
the --prebuilt-cef flag. In such case check the cefpython/src/version/
directory to know which version of CEF to download from Spotify:
http://opensource.spotify.com/cefbuilds/index.html
Download and extract it so that for example you have such a directory:
cefpython/build/cef_binary_3.2883.1553.g80bd606_windows32/ .

This tool generates CEF binaries and libraries that are ready for work
with cefpython, with the build.py script. When automate.py tool completes
job you should see a new subdirectory in the build/ directory, for example:
cefpython/build/cef55_3.2883.1553.g80bd606_win32/ .

Usage:
    automate.py (--prebuilt-cef | --build-cef)
                [--fast-build FAST_BUILD]
                [--force-chromium-update FORCE_CHROMIUM_UPDATE]
                [--no-cef-update NO_CEF_UPDATE]
                [--cef-branch BRANCH] [--cef-commit COMMIT]
                [--build-dir BUILD_DIR] [--cef-build-dir CEF_BUIL_DDIR]
                [--ninja-jobs JOBS] [--gyp-generators GENERATORS]
                [--gyp-msvs-version MSVS]
    automate.py (-h | --help) [type -h to show full description for options]

Options:
    -h --help                Show this help message.
    --prebuilt-cef           Whether to use prebuilt CEF binaries. Prebuilt
                             binaries for Linux are built on Ubuntu.
    --build-cef              Whether to build CEF from sources with the
                             cefpython patches applied.
    --fast-build             Fast build with is_official_build=False
    --force-chromium-update  Force Chromium update (gclient sync etc).
    --no-cef-update          Do not update CEF sources (by default both cef/
                             directories are deleted on every run).
    --cef-branch=<b>         CEF branch. Defaults to CHROME_VERSION_BUILD from
                             "src/version/cef_version_{platform}.h".
    --cef-commit=<c>         CEF revision. Defaults to CEF_COMMIT_HASH from
                             "src/version/cef_version_{platform}.h".
    --build-dir=<dir1>       Build directory.
    --cef-build-dir=<dir2>   CEF build directory. By default same
                             as --build-dir.
    --ninja-jobs=<jobs>      How many CEF jobs to run in parallel. To speed up
                             building set it to number of cores in your CPU.
                             By default set to cpu_count / 2.
    --gyp-generators=<gen>   Set GYP_GENERATORS [default: ninja].
    --gyp-msvs-version=<v>   Set GYP_MSVS_VERSION.

"""

from common import *
import os
import sys
import shlex
import subprocess
import platform
import docopt
import stat
import glob
import shutil
import multiprocessing

CEF_GIT_URL = "https://bitbucket.org/chromiumembedded/cef.git"


class Options(object):
    """Options from command-line and internal options."""

    # From command-line
    prebuilt_cef = False
    build_cef = False
    fast_build = False
    force_chromium_update = False
    no_cef_update = False
    cef_branch = ""
    cef_commit = ""
    cef_version = ""
    build_dir = ""
    cef_build_dir = ""
    ninja_jobs = None
    gyp_generators = "ninja"  # Even though CEF uses now GN, still some GYP
    gyp_msvs_version = ""     # env variables are being used.

    # Internal options
    depot_tools_dir = ""
    tools_dir = ""
    cefpython_dir = ""
    binary_distrib = ""
    release_build = True
    build_type = ""  # Will be set according to "release_build" value
    cef_binary = ""
    build_cefclient_dir = ""
    build_wrapper_dir = ""
    build_wrapper_mt_dir = ""
    build_wrapper_md_dir = ""


def main():
    """Main entry point."""

    if not ((2, 7) <= sys.version_info < (2, 8)):
        print("ERROR: to run this tool you need Python 2.7, as upstream")
        print("       automate-git.py works only with that version.")
        sys.exit(1)

    if len(sys.argv) <= 1:
        print(__doc__)
        sys.exit(1)

    setup_options(docopt.docopt(__doc__))

    if Options.build_cef:
        build_cef()
        # Build cefclient, cefsimple, ceftests, libcef_dll_wrapper
        build_cef_projects()
        create_prebuilt_binaries()
    elif Options.prebuilt_cef:
        prebuilt_cef()


def setup_options(docopt_args):
    """Setup options from cmd-line and internal options."""

    # Populate Options using command line arguments
    for key in docopt_args:
        value = docopt_args[key]
        key2 = key.replace("--", "").replace("-", "_")
        if hasattr(Options, key2) and value is not None:
            setattr(Options, key2, value)

    Options.tools_dir = os.path.dirname(os.path.realpath(__file__))
    Options.cefpython_dir = os.path.dirname(Options.tools_dir)

    # If --cef-branch is specified will use latest CEF commit from that
    # branch. Otherwise get cef branch/commit from src/version/.
    if not Options.cef_branch:
        # Use branch/commit from the src/version/cef_version_*.h file
        Options.cef_branch = get_cefpython_version()["CHROME_VERSION_BUILD"]
        Options.cef_commit = get_cefpython_version()["CEF_COMMIT_HASH"]
        Options.cef_version = get_cefpython_version()["CEF_VERSION"]

    # --gyp-msvs-version
    if not Options.gyp_msvs_version:
        if int(Options.cef_branch) >= 2704:
            Options.gyp_msvs_version = "2015"
        else:
            Options.gyp_msvs_version = "2013"

    # --build-dir
    if Options.build_dir:
        Options.build_dir = os.path.realpath(Options.build_dir)
    else:
        Options.build_dir = os.path.join(Options.cefpython_dir, "build")
    if " " in Options.build_dir:
        print("[automate.py] ERROR: Build dir cannot contain spaces")
        print(">> " + Options.build_dir)
        sys.exit(1)
    if not os.path.exists(Options.build_dir):
        os.makedirs(Options.build_dir)

    # --cef-build-dir
    if Options.cef_build_dir:
        Options.cef_build_dir = os.path.realpath(Options.cef_build_dir)
    else:
        Options.cef_build_dir = Options.build_dir
    if " " in Options.cef_build_dir:
        print("[automate.py] ERROR: CEF build dir cannot contain spaces")
        print(">> " + Options.cef_build_dir)
        sys.exit(1)
    if not os.path.exists(Options.cef_build_dir):
        os.makedirs(Options.cef_build_dir)

    # --depot-tools-dir
    Options.depot_tools_dir = os.path.join(Options.cef_build_dir,
                                           "depot_tools")
    # binary_distrib
    Options.binary_distrib = os.path.join(Options.cef_build_dir, "chromium",
                                          "src", "cef", "binary_distrib")

    # build_type
    Options.build_type = "Release" if Options.release_build else "Debug"

    # ninja_jobs
    # cpu_count() returns number of CPU threads, not CPU cores.
    # On i5 with 2 cores and 4 cpu threads the default of 4 ninja
    # jobs slows down computer significantly.
    if not Options.ninja_jobs:
        Options.ninja_jobs = int(multiprocessing.cpu_count() / 2)
        if Options.ninja_jobs < 1:
            Options.ninja_jobs = 1


def build_cef():
    """Build CEF from sources."""

    # cef/ repo
    create_cef_directories()

    # Delete binary_distrib
    if os.path.exists(Options.binary_distrib):
        rmdir(Options.binary_distrib)

    # Run automate-git.py
    run_automate_git()
    print("[automate.py] Binary distrib created in %s"
          % Options.binary_distrib)


def prebuilt_cef():
    """Use prebuilt binaries."""

    # TODO: Option to download CEF prebuilt binaries from GitHub Releases,
    #       eg. tag 'upstream-cef47'.

    # Find cef_binary directory in the build directory
    if Options.cef_version:
        cef_binary = os.path.join(Options.build_dir,
                                  "cef_binary_{cef_version}_{os}{sep}"
                                  .format(cef_version=Options.cef_version,
                                          os=CEF_POSTFIX2,
                                          sep=os.sep))
    else:
        cef_binary = os.path.join(Options.build_dir,
                                  "cef_binary_3.{cef_branch}.*_{os}{sep}"
                                  .format(cef_branch=Options.cef_branch,
                                          os=CEF_POSTFIX2,
                                          sep=os.sep))
    dirs = glob.glob(cef_binary)
    if len(dirs) == 1:
        Options.cef_binary = dirs[0]
    else:
        print("ERROR: Could not find prebuilt binaries in the build dir:")
        print("       {cef_binary}".format(cef_binary=cef_binary))
        sys.exit(1)

    build_cef_projects()
    create_prebuilt_binaries()


def create_cef_directories():
    """Create cef/ directories in cef_build_dir/ and in chromium/src/ ."""
    if Options.no_cef_update:
        return
    cef_dir = os.path.join(Options.cef_build_dir, "cef")
    src_dir = os.path.join(Options.cef_build_dir, "chromium", "src")
    cef_dir2 = os.path.join(src_dir, "cef")
    # Clone cef repo and checkout branch
    if os.path.exists(cef_dir):
        rmdir(cef_dir)
    run_git("clone -b %s %s cef" % (Options.cef_branch, CEF_GIT_URL),
            Options.cef_build_dir)
    if Options.cef_commit:
        run_git("checkout %s" % Options.cef_commit, cef_dir)
    # Update cef patches
    update_cef_patches()
    # Copy cef/ to chromium/src/ but only if chromium/src/ exists,
    # but don't copy it and delete if exists when --force-chromium-update
    # flag is passed, chromium throws error about unstaged changes.
    if os.path.exists(src_dir):
        if os.path.exists(cef_dir2):
            rmdir(cef_dir2)
        if not Options.force_chromium_update:
            shutil.copytree(cef_dir, cef_dir2)


def update_cef_patches():
    """Update cef/patch/ directory with CEF Python patches.
    Issue73 is applied in getenv() by setting appropriate env var.

    Note that this modifies only cef_build_dir/cef/ directory. If the
    build was run previously then there is a copy of the cef/ directory
    in the cef_build_dir/chromium/ directory which is not being updated.
    """
    print("[automate.py] Updating CEF patches with CEF Python patches")
    cef_dir = os.path.join(Options.cef_build_dir, "cef")
    cef_patch_dir = os.path.join(cef_dir, "patch")
    cef_patches_dir = os.path.join(cef_patch_dir, "patches")

    # Copy src/patches/*.patch to cef/patch/patches/
    cefpython_patches_dir = os.path.join(Options.cefpython_dir, "patches")
    cefpython_patches = glob.glob(os.path.join(cefpython_patches_dir,
                                  "*.patch"))
    for file_ in cefpython_patches:
        print("[automate.py] Copying %s to %s"
              % (os.path.basename(file_), cef_patches_dir))
        shutil.copy(file_, cef_patches_dir)

    # Append cefpython/patches/patch.py to cef/patch/patch.cfg
    cef_patch_cfg = os.path.join(cef_patch_dir, "patch.cfg")
    print("[automate.py] Overwriting %s" % cef_patch_cfg)
    with open(cef_patch_cfg, "rb") as fp:
        cef_patch_cfg_contents = fp.read()
        cef_patch_cfg_contents += "\n"
    cefpython_patch_cfg = os.path.join(cefpython_patches_dir, "patch.py")
    with open(cefpython_patch_cfg, "rb") as fp:
        cefpython_patch_cfg_contents = fp.read()
    with open(cef_patch_cfg, "wb") as fp:
        cef_patch_cfg_contents = cef_patch_cfg_contents.replace("\r\n", "\n")
        cefpython_patch_cfg_contents = cefpython_patch_cfg_contents.replace(
                                                                "\r\n", "\n")
        new_contents = cef_patch_cfg_contents + cefpython_patch_cfg_contents
        fp.write(new_contents)


def build_cef_projects():
    """Build cefclient, cefsimple, ceftests, libcef_dll_wrapper."""
    print("[automate.py] Building cef projects...")

    fix_cef_include_files()

    # Find cef_binary directory.
    # Might already be set if --prebuilt-cef flag was passed.
    if not Options.cef_binary:
        if platform.system() == "Windows":
            files = glob.glob(os.path.join(Options.binary_distrib,
                                           "cef_binary_*_symbols"))
            assert len(files) == 1, ("More than one dir with release"
                                     " symbols found")
            symbols = files[0]
            if Options.release_build:
                cef_binary = symbols.replace("_release_symbols", "")
            else:
                cef_binary = symbols.replace("_debug_symbols", "")
            assert "symbols" not in os.path.basename(cef_binary)
        else:
            files = glob.glob(os.path.join(Options.binary_distrib,
                                           "cef_binary_*_"+OS_POSTFIX2))
            assert len(files) == 1, "Error finding binary distrib"
            cef_binary = files[0]
        assert os.path.exists(cef_binary)
        Options.cef_binary = cef_binary

    # Set build directory
    Options.build_cefclient_dir = os.path.join(Options.cef_binary,
                                               "build_cefclient")

    print("[automate.py] Creating build_cefclient dir in cef_binary dir")

    # Check whether already built
    already_built = False
    if build_cefclient_succeeded():
        already_built = True
    elif os.path.exists(Options.build_cefclient_dir):
        # Last build failed, clean directory
        assert Options.build_cefclient_dir
        shutil.rmtree(Options.build_cefclient_dir)
        os.makedirs(Options.build_cefclient_dir)
    else:
        os.makedirs(Options.build_cefclient_dir)

    # Build cefclient, cefsimple, ceftests
    if already_built:
        print("[automate.py] Already built: cefclient, cefsimple, ceftests")
    else:
        print("[automate.py] Build cefclient, cefsimple, ceftests")
        # Cmake
        command = prepare_build_command()
        command.extend(["cmake", "-G", "Ninja"])
        command.append("-DCMAKE_BUILD_TYPE="+Options.build_type)
        if MAC:
            command.append("-DPROJECT_ARCH=x86_64")
        command.append("..")
        run_command(command, Options.build_cefclient_dir)
        print("[automate.py] OK")
        # Ninja
        command = prepare_build_command()
        # On Mac cefclient fails with XCode 5:
        # > cefclient_mac.mm:22:29: error: property 'mainMenu' not found
        if MAC:
            # Build only cefsimple
            command.extend(["ninja", "cefsimple"])
        else:
            command.extend(["ninja", "cefclient", "cefsimple", "ceftests"])
        run_command(command, Options.build_cefclient_dir)
        print("[automate.py] OK")
        assert build_cefclient_succeeded()

    # Build libcef_dll_wrapper libs
    if WINDOWS:
        build_wrapper_windows()
    elif MAC:
        build_wrapper_mac()


def build_wrapper_mac():
    # On Mac it is required to link libcef_dll_wrapper against
    # libc++ library, so must build this library separately
    # from cefclient.
    cmake_wrapper = prepare_build_command(build_lib=True)
    cmake_wrapper.extend(["cmake", "-G", "Ninja",
                          "-DPROJECT_ARCH=x86_64"
                          "-DCMAKE_CXX_FLAGS=-stdlib=libc++",
                          "-DCMAKE_BUILD_TYPE=" + Options.build_type,
                          ".."])
    Options.build_wrapper_dir = os.path.join(Options.cef_binary,
                                             "build_wrapper")
    # Check whether already built
    already_built = False
    if build_wrapper_mac_succeeded():
        already_built = True
    elif os.path.exists(Options.build_wrapper_dir):
        # Last build failed, clean directory
        assert Options.build_wrapper_dir
        shutil.rmtree(Options.build_wrapper_dir)
        os.makedirs(Options.build_wrapper_dir)
    else:
        os.makedirs(Options.build_wrapper_dir)

    # Build libcef_dll_wrapper library
    if already_built:
        print("[automate.py] Already built: libcef_dll_wrapper")
    else:
        print("[automate.py] Build libcef_dll_wrapper")
        # Cmake
        run_command(cmake_wrapper, Options.build_wrapper_dir)
        print("[automate.py] cmake OK")
        # Ninja
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper.extend(["ninja", "libcef_dll_wrapper"])
        run_command(ninja_wrapper, Options.build_wrapper_dir)
        print("[automate.py] ninja OK")
        assert build_wrapper_mac_succeeded()


def build_wrapper_windows():
    # When building library cmake variables file is being modified
    # for the /MD build. If the build fails and variables aren't
    # restored then the next /MT build would be broken. Make sure
    # that original contents of cmake variables files is always
    # restored.
    fix_cmake_variables_for_md_library(try_undo=True)

    # Command to build libcef_dll_wrapper
    cmake_wrapper = prepare_build_command(build_lib=True)
    cmake_wrapper.extend(["cmake", "-G", "Ninja",
                         "-DCMAKE_BUILD_TYPE="+Options.build_type, ".."])

    # Set build directory for /MT lib.
    Options.build_wrapper_mt_dir = os.path.join(Options.cef_binary,
                                                "build_wrapper_mt")

    # Check whether already built
    mt_already_built = False
    if build_wrapper_mt_succeeded():
        mt_already_built = True
    elif os.path.exists(Options.build_wrapper_mt_dir):
        # Last build failed, clean directory
        assert Options.build_wrapper_mt_dir
        shutil.rmtree(Options.build_wrapper_mt_dir)
        os.makedirs(Options.build_wrapper_mt_dir)
    else:
        os.makedirs(Options.build_wrapper_mt_dir)

    # Build /MT lib.
    if mt_already_built:
        print("[automate.py] Already built: libcef_dll_wrapper /MT")
    else:
        print("[automate.py] Build libcef_dll_wrapper /MT")
        old_gyp_msvs_version = Options.gyp_msvs_version
        Options.gyp_msvs_version = get_msvs_for_python()
        # Cmake
        run_command(cmake_wrapper, Options.build_wrapper_mt_dir)
        Options.gyp_msvs_version = old_gyp_msvs_version
        print("[automate.py] cmake OK")
        # Ninja
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper.extend(["ninja", "libcef_dll_wrapper"])
        run_command(ninja_wrapper, Options.build_wrapper_mt_dir)
        print("[automate.py] ninja OK")
        assert build_wrapper_mt_succeeded()

    # Set build directory for /MD lib.
    Options.build_wrapper_md_dir = os.path.join(Options.cef_binary,
                                                "build_wrapper_md")

    # Check whether already built
    md_already_built = False
    if build_wrapper_md_succeeded():
        md_already_built = True
    elif os.path.exists(Options.build_wrapper_md_dir):
        # Last build failed, clean directory
        assert Options.build_wrapper_md_dir
        shutil.rmtree(Options.build_wrapper_md_dir)
        os.makedirs(Options.build_wrapper_md_dir)
    else:
        os.makedirs(Options.build_wrapper_md_dir)

    # Build /MD lib.
    if md_already_built:
        print("[automate.py] Already built: libcef_dll_wrapper /MD")
    else:
        print("[automate.py] Build libcef_dll_wrapper /MD")
        old_gyp_msvs_version = Options.gyp_msvs_version
        Options.gyp_msvs_version = get_msvs_for_python()
        # Fix cmake variables
        # Cmake
        fix_cmake_variables_for_md_library()
        run_command(cmake_wrapper, Options.build_wrapper_md_dir)
        Options.gyp_msvs_version = old_gyp_msvs_version
        fix_cmake_variables_for_md_library(undo=True)
        print("[automate.py] cmake OK")
        # Ninja
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper.extend(["ninja", "libcef_dll_wrapper"])
        run_command(ninja_wrapper, Options.build_wrapper_md_dir)
        print("[automate.py] ninja OK")
        assert build_wrapper_md_succeeded()


def fix_cmake_variables_for_md_library(undo=False, try_undo=False):
    """Fix cmake variables or undo it. The try_undo param is
    for a case when want to be sure that the file wasn't modified,
    for example in case the last build failed."""

    # Replace /MT with /MD /wd4275 in cef/cmake/cef_variables.cmake
    # Warnings are treated as errors so this needs to be ignored:
    # >> warning C4275: non dll-interface class 'stdext::exception'
    # >> used as base for dll-interface class 'std::bad_cast'
    # This warning occurs only in VS2008, in VS2013 not.
    # This replacements must be unique for the undo operation
    # to be reliable.

    mt_find = r"/MT "
    mt_replace = r"/MD /wd4275 "

    mtd_find = r"/MTd "
    mtd_replace = r"/MDd /wd4275 "

    cmake_variables = os.path.join(Options.cef_binary, "cmake",
                                   "cef_variables.cmake")
    with open(cmake_variables, "rb") as fp:
        contents = fp.read()

    if try_undo:
        matches1 = re.findall(re.escape(mt_replace), contents)
        matches2 = re.findall(re.escape(mtd_replace), contents)
        if len(matches1) or len(matches2):
            undo = True
        else:
            return

    if undo:
        (contents, count) = re.subn(re.escape(mt_replace), mt_find,
                                    contents)
        assert count == 2
        (contents, count) = re.subn(re.escape(mtd_replace), mtd_find,
                                    contents)
        assert count == 1
    else:
        (contents, count) = re.subn(re.escape(mt_find), mt_replace,
                                    contents)
        assert count == 2
        (contents, count) = re.subn(re.escape(mtd_find), mtd_replace,
                                    contents)
        assert count == 1

    with open(cmake_variables, "wb") as fp:
        fp.write(contents)


def build_cefclient_succeeded():
    """Whether building cefclient/cefsimple/ceftests succeeded."""
    assert Options.build_cefclient_dir
    cefclient_exe = "cefclient" + EXECUTABLE_EXT
    return os.path.exists(os.path.join(Options.build_cefclient_dir,
                                       "tests",
                                       "cefclient",
                                       Options.build_type,
                                       cefclient_exe))


def build_wrapper_mac_succeeded():
    """Whether building libcef_dll_wrapper succeeded."""
    return os.path.exists(os.path.join(
            Options.build_wrapper_dir,
            "libcef_dll_wrapper",
            "libcef_dll_wrapper.a"))


def build_wrapper_mt_succeeded():
    """Whether building /MT library succeeded (Windows-only)."""
    assert Options.build_wrapper_mt_dir
    return os.path.exists(os.path.join(Options.build_wrapper_mt_dir,
                                       "libcef_dll_wrapper",
                                       "libcef_dll_wrapper.lib"))


def build_wrapper_md_succeeded():
    """Whether building /MD library succeeded (Windows-only)."""
    assert Options.build_wrapper_md_dir
    return os.path.exists(os.path.join(Options.build_wrapper_md_dir,
                                       "libcef_dll_wrapper",
                                       "libcef_dll_wrapper.lib"))


def prepare_build_command(build_lib=False):
    """On Windows VS env variables must be set up by calling vcvarsall.bat"""
    command = list()
    if platform.system() == "Windows":
        if build_lib:
            msvs = get_msvs_for_python()
            command.append(globals()["VS"+msvs+"_VCVARS"])
        else:
            if int(Options.cef_branch) >= 2704:
                command.append(VS2015_VCVARS)
            else:
                command.append(VS2013_VCVARS)
        command.append("&&")
    return command


def fix_cef_include_files():
    """Fixes to CEF include header files for eg. VS2008 on Windows."""
    # TODO: This was fixed in upstream CEF, remove this code during
    #       next CEF update on Windows.
    if platform.system() == "Windows" and get_msvs_for_python() == "2008":
        print("[automate.py] Fixing CEF include/ files")
        # cef_types_wrappers.h
        cef_types_wrappers = os.path.join(Options.cef_binary, "include",
                                          "internal", "cef_types_wrappers.h")
        with open(cef_types_wrappers, "rb") as fp:
            contents = fp.read()
        # error C2059: syntax error : '{'
        contents = contents.replace("s->range = {0, 0};",
                                    "s->range.from = 0; s->range.to = 0;")
        with open(cef_types_wrappers, "wb") as fp:
            fp.write(contents)


def create_prebuilt_binaries(copy_apps=True):
    """After building copy binaries/libs to build/cef_xxxx/.
    Not all projects may have been built on all platforms."""

    # Directories
    src = Options.cef_binary
    version_header = os.path.join(src, "include", "cef_version.h")
    dst = get_prebuilt_name(version_header)
    dst = os.path.join(Options.build_dir, dst)
    rmdir(dst)
    os.makedirs(dst)
    bindir = os.path.join(dst, "bin")
    libdir = os.path.join(dst, "lib")
    os.makedirs(bindir)
    os.makedirs(libdir)

    # Copy Release/Debug and Resources
    cpdir(os.path.join(src, Options.build_type), bindir)
    if not MAC:
        cpdir(os.path.join(src, "Resources"), bindir)

    # Fix id in CEF framework on Mac (currently it expects Frameworks/ dir)
    if MAC:
        new_id = ("@rpath/Chromium Embedded Framework.framework"
                  "/Chromium Embedded Framework")
        cef_framework_dir = os.path.join(
                bindir, "Chromium Embedded Framework.framework")
        cef_library = os.path.join(
                cef_framework_dir, "Chromium Embedded Framework")
        assert os.path.isdir(cef_framework_dir)
        run_command(["install_name_tool", "-id", new_id, cef_library],
                    working_dir=cef_framework_dir)

    # Copy cefclient, cefsimple, ceftests

    # cefclient
    cefclient = os.path.join(
            src,
            "build_cefclient", "tests", "cefclient",
            Options.build_type,
            "cefclient" + EXECUTABLE_EXT)
    if LINUX and os.path.exists(cefclient):
        # On Windows resources/*.html files are embedded inside exe
        cefclient_files = os.path.join(
                src,
                "build_cefclient", "tests", "cefclient",
                Options.build_type,
                "cefclient_files")
        cpdir(cefclient_files, os.path.join(bindir, "cefclient_files"))

    # cefsimple
    cefsimple = os.path.join(
            src,
            "build_cefclient", "tests", "cefsimple",
            Options.build_type,
            "cefsimple" + EXECUTABLE_EXT)

    # ceftests
    ceftests = os.path.join(
            src,
            "build_cefclient", "tests", "ceftests",
            Options.build_type,
            "ceftests" + EXECUTABLE_EXT)
    if LINUX and os.path.exists(ceftests):
        # On Windows resources/*.html files are embedded inside exe
        ceftests_files = os.path.join(
                src,
                "build_cefclient", "tests", "ceftests",
                Options.build_type,
                "ceftests_files")
        cpdir(ceftests_files, os.path.join(bindir, "ceftests_files"))

    def copy_app(app):
        if os.path.exists(app):
            if os.path.isdir(app):
                # On Mac app is a directory
                shutil.copytree(app,
                                os.path.join(bindir,
                                             os.path.basename(app)))
            else:
                shutil.copy(app, bindir)

    if not MAC:
        # Currently do not copy apps on Mac
        copy_app(cefclient)
        copy_app(cefsimple)
        copy_app(ceftests)

    # END: Copy cefclient, cefsimple, ceftests

    # Copy libraries
    if platform.system() == "Windows":
        # libcef.lib and cef_sandbox.lib
        mvfiles(bindir, libdir, ".lib")
        # MT lib
        libsrc = os.path.join(src, "build_wrapper_mt", "libcef_dll_wrapper",
                              "libcef_dll_wrapper.lib")
        libdst = os.path.join(libdir, "libcef_dll_wrapper_mt.lib")
        shutil.copy(libsrc, libdst)
        # MD lib
        libsrc = os.path.join(src, "build_wrapper_md", "libcef_dll_wrapper",
                              "libcef_dll_wrapper.lib")
        libdst = os.path.join(libdir, "libcef_dll_wrapper_md.lib")
        shutil.copy(libsrc, libdst)
    else:
        shutil.copy(os.path.join(src, "build_cefclient", "libcef_dll_wrapper",
                                 "libcef_dll_wrapper.a"),
                    libdir)

    # Remove .lib files from bin/ only after libraries were copied (Windows)
    libs = glob.glob(os.path.join(bindir, "*.lib"))
    for lib in libs:
        os.remove(lib)

    # Remove cef_sandbox.lib (huge file)
    cef_sandbox = os.path.join(libdir, "cef_sandbox.lib")
    if os.path.exists(cef_sandbox):
        os.remove(cef_sandbox)

    # Copy README.txt and LICENSE.txt
    shutil.copy(os.path.join(src, "README.txt"), dst)
    shutil.copy(os.path.join(src, "LICENSE.txt"), dst)

    print("[automate.py] OK prebuilt binaries created in '%s/'" % dst)


def get_msvs_for_python():
    """Get MSVS version (eg 2008) for current python running."""
    if sys.version_info[:2] == (2, 7):
        return "2008"
    elif sys.version_info[:2] == (3, 4):
        return "2010"
    elif sys.version_info[:2] == (3, 5):
        return "2015"
    else:
        print("ERROR: This python version is not yet supported")
        sys.exit(1)


def getenv():
    """Env variables passed to shell when running commands."""
    env = os.environ
    env["PATH"] = Options.depot_tools_dir + os.pathsep + env["PATH"]
    env["GYP_GENERATORS"] = Options.gyp_generators
    if platform.system() == "Windows":
        env["GYP_MSVS_VERSION"] = Options.gyp_msvs_version
    # See cef/AutomatedBuildSetup.md for reference.
    # Issue73 patch applied with "use_allocator=none"
    # TODO: 32-bit gyp defines: host_arch=x86_64 target_arch=ia32
    env["GN_DEFINES"] = "use_sysroot=true use_allocator=none symbol_level=1"
    # To perform an official build set GYP_DEFINES=buildtype=Official.
    # This will disable debugging code and enable additional link-time
    # optimizations in Release builds.
    if Options.release_build and not Options.fast_build:
        env["GN_DEFINES"] += " is_official_build=true"
    # Modifications to automate-git.py
    env["CEFPYTHON_NINJA_JOBS"] = str(Options.ninja_jobs)
    return env


def run_command(command, working_dir):
    """Run command in a given directory with env variables set.
    On Linux multiple commands on one line with the use of && are not allowed.
    """
    print("[automate.py] Running '"+" ".join(command)+"' in '" +
          working_dir+"'...")
    if isinstance(command, str):
        args = shlex.split(command.replace("\\", "\\\\"))
    else:
        args = command
    return subprocess.check_call(args, cwd=working_dir, env=getenv(),
                                 shell=(platform.system() == "Windows"))


def run_python(command_line, working_dir):
    """Run python script using depot_tools."""
    python = "python"
    return run_command("%s %s" % (python, command_line), working_dir)


def run_git(command_line, working_dir):
    """Run git command using depot_tools."""
    return run_command("git %s" % command_line, working_dir)


def run_automate_git():
    """Run CEF automate-git.py."""
    script = os.path.join(Options.cefpython_dir, "tools", "automate-git.py")
    """
    Example automate-git.py command:
        C:\chromium>call python automate-git.py --download-dir=./test/
        --branch=2526 --no-debug-build --verbose-build
    Run ninja build manually:
        cd chromium/src
        ninja -v -j2 -Cout\Release cefclient
    """
    args = []
    if ARCH64:
        args.append("--x64-build")
    args.append("--download-dir=" + Options.cef_build_dir)
    args.append("--branch=" + Options.cef_branch)
    if Options.release_build:
        args.append("--no-debug-build")
    args.append("--verbose-build")
    # --force-build sets --force-distrib by default
    # ninja will only recompile files that changed
    args.append("--force-build")
    # We clone cef repository ourselves and update cef patches with ours,
    # so don't fetch/update CEF repo.
    args.append("--no-cef-update")
    # Force Chromium update so that gclient sync is called. It may fail
    # sometimes with files missing and must re-run to fix.
    if Options.force_chromium_update:
        args.append("--force-update")
    args.append("--no-distrib-archive")
    if platform.system() == "Linux":
        # Building cefclient target isn't supported on Linux when
        # using sysroot (cef/#1916). However building cefclient
        # later in cef_binary/ with cmake/ninja do works fine.
        args.append("--build-target=cefsimple")

    args = " ".join(args)
    return run_python(script+" "+args, Options.cef_build_dir)


def rmdir(path):
    """Delete directory recursively."""
    if os.path.exists(path):
        print("[automate.py] Removing directory %s" % path)
        shutil.rmtree(path, onerror=onerror)


def cpdir(src, dst):
    """An equivalent of linux 'cp -r src/* dst/'. """
    names = os.listdir(src)
    if not os.path.exists(dst):
        os.makedirs(dst)
    for name in names:
        path = os.path.join(src, name)
        if os.path.isdir(path):
            dst_subdir = os.path.join(dst, name)
            shutil.copytree(path, dst_subdir)
        else:
            shutil.copy(path, dst)


def mvfiles(src, dst, ext):
    """An equivalent of linux 'mv src/*.ext dst/'. """
    names = os.listdir(src)
    if not os.path.exists(dst):
        os.makedirs(dst)
    for name in names:
        path = os.path.join(src, name)
        if os.path.isfile(path) and name.endswith(ext):
            shutil.copy(path, dst)


def onerror(func, path, _):
    """Fix file permission on error and retry operation."""
    if not os.access(path, os.W_OK):
        os.chmod(path, stat.S_IWUSR)
        func(path)
    else:
        raise Exception("Not a file permission error, dunno what to do")


def get_prebuilt_name(header_file=""):
    if header_file:
        version = get_version_from_file(header_file)
    else:
        version = get_cefpython_version()
    name = "cef%s_%s_%s" % (
        version["CHROME_VERSION_MAJOR"],
        version["CEF_VERSION"],
        OS_POSTFIX2,
    )
    return name


if __name__ == "__main__":
    main()
