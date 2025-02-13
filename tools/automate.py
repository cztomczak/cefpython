# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Prepares CEF binaries and libraries for work with the build.py tool.

Option 1 is to build CEF from sources with the CEF Python patches applied
using the --build-cef flag. Building CEF from sources is supported only
on 64-bit systems. 32-bit is also built on 64-bit using cross-compiling.
Note that building CEF from sources was last tested with v56 on Linux
and with v50 on Windows, so if there are issues report them on the Forum.

Option 2 is to use CEF binaries from Spotify Automated Builds using
the --prebuilt-cef flag. In such case check the cefpython/src/version/
directory to know which version of CEF to download from Spotify:
https://cef-builds.spotifycdn.com/index.html
Download and extract it so that for example you have such a directory:
cefpython/build/cef_binary_3.2883.1553.g80bd606_windows32/ .

This tool generates CEF binaries and libraries that are ready for work
with cefpython, with the build.py script. When automate.py tool completes
job you should see a new subdirectory in the build/ directory, for example:
cefpython/build/cef55_3.2883.1553.g80bd606_win32/ .

Usage:
    automate.py (--prebuilt-cef | --build-cef | --make-distrib)
                [--x86 X86]
                [--fast-build FAST_BUILD]
                [--force-chromium-update FORCE_CHROMIUM_UPDATE]
                [--no-cef-update NO_CEF_UPDATE]
                [--cef-git-url URL] [--cef-branch BRANCH] [--cef-commit COMMIT]
                [--build-dir BUILD_DIR] [--cef-build-dir CEF_BUILD_DIR]
                [--ninja-jobs JOBS] [--gyp-generators GENERATORS]
                [--gyp-msvs-version MSVS]
                [--use-system-freetype USE_SYSTEM_FREETYPE]
                [--use-gtk3 USE_GTK3]
                [--use-ccache USE_CCACHE]
                [--proprietary-codecs PROPRIETARY_CODECS]
                [--no-depot-tools-update NO_DEPOT_TOOLS_UPDATE]
    automate.py (-h | --help) [type -h to show full description for options]

Options:
    -h --help                Show this help message.
    --prebuilt-cef           Whether to use prebuilt CEF binaries. Prebuilt
                             binaries for Linux are built on Ubuntu.
    --build-cef              Whether to build CEF from sources with the
                             cefpython patches applied.
    --make-distrib           Re-make CEF distribution (cef/binary_distrib/)
                             after CEF was already built.
    --x86                    Build (or make distrib) for 32-bit CEF on
                             64-bit system.
    --fast-build             Fast build with is_official_build=False
    --force-chromium-update  Force Chromium update (gclient sync etc).
    --no-cef-update          Do not update CEF sources (by default both cef/
                             directories are deleted on every run).
    --cef-git-url=<url>      Git URL to clone CEF from, defaults to upstream
    --cef-branch=<b>         CEF branch. Defaults to CHROME_VERSION_BUILD from
                             "src/version/cef_version_{platform}.h".
    --cef-commit=<c>         CEF revision. Defaults to CEF_COMMIT_HASH from
                             "src/version/cef_version_{platform}.h".
    --build-dir=<dir1>       Build directory.
    --cef-build-dir=<dir2>   CEF build directory. By default same
                             as --build-dir.
    --ninja-jobs=<jobs>      How many CEF jobs to run in parallel. By default
                             sets to CPU threads * 2. If you need to perform
                             other tasks on computer and it is slowed down
                             by the build then decrease the number of ninja
                             jobs.
    --gyp-generators=<gen>   Set GYP_GENERATORS [default: ninja].
    --gyp-msvs-version=<v>   Set GYP_MSVS_VERSION.
    --use-system-freetype    Use system Freetype library on Linux (Issue #402)
    --use-gtk3               Link CEF with GTK 3 libraries (Issue #446)
    --use-ccache             Use ccache for faster (re)builds
    --proprietary-codecs     Enable proprietary codecs such as H264 and AAC,
                             licensing restrictions may apply.
    --no-depot-tools-update  Do not update depot_tools/ directory. When
                             building old unsupported versions of Chromium
                             you want to manually checkout an old version
                             of depot tools from the time of the release.

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
from collections import OrderedDict

# Constants
CEF_UPSTREAM_GIT_URL = "https://bitbucket.org/chromiumembedded/cef.git"
RUNTIME_MT = "MT"
RUNTIME_MD = "MD"


class Options(object):
    """Options from command-line and internal options."""

    # From command-line
    prebuilt_cef = False
    build_cef = False
    make_distrib = False
    x86 = False
    fast_build = False
    force_chromium_update = False
    no_cef_update = False
    cef_git_url = ""
    cef_branch = ""
    cef_commit = ""
    cef_version = ""
    build_dir = ""
    cef_build_dir = ""
    ninja_jobs = None
    gyp_generators = "ninja"  # Even though CEF uses now GN, still some GYP
    gyp_msvs_version = ""     # env variables are being used.
    use_system_freetype = False
    use_gtk3 = False
    use_ccache = False
    proprietary_codecs = False
    no_depot_tools_update = False

    # Internal options
    depot_tools_dir = ""
    tools_dir = ""
    cefpython_dir = ""
    binary_distrib = ""
    release_build = True
    build_type = ""  # Will be set according to "release_build" value
    cef_binary = ""


def main():
    """Main entry point."""

    if len(sys.argv) <= 1:
        print(__doc__)
        sys.exit(1)

    setup_options(docopt.docopt(__doc__))

    if Options.build_cef:
        build_cef()
    elif Options.prebuilt_cef:
        prebuilt_cef()
    elif Options.make_distrib:
        run_make_distrib()


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

    if not Options.cef_git_url:
        Options.cef_git_url = CEF_UPSTREAM_GIT_URL

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
    # On i5 with 2 cores there are 4 cpu threads and will enable
    # 8 ninja jobs by default.
    if not Options.ninja_jobs:
        Options.ninja_jobs = int(multiprocessing.cpu_count() * 2)
        assert Options.ninja_jobs > 0
    Options.ninja_jobs = str(Options.ninja_jobs)


def build_cef():
    """Build CEF from sources."""

    if ARCH32:
        print("[automate.py] INFO: building CEF 32-bit from sources is"
              " supported only with cross-compiling on 64-bit OS.")
        sys.exit(1)

    # cef/ repo
    create_cef_directories()

    # Delete binary_distrib
    if os.path.exists(Options.binary_distrib):
        rmdir(Options.binary_distrib)

    # Run automate-git.py
    run_automate_git()
    print("[automate.py] Binary distrib created in %s"
          % Options.binary_distrib)

    if Options.x86:
        print("[automate.py] INFO: Build CEF projects and create prebuilt"
              " binaries on Linux 32-bit using eg. VirtualBox. Copy the binary"
              " distrib's cef_binary_*/ directory (path displayed above) to"
              " cefpython's build/ directory. Then run automate.py"
              " --prebuilt-cef on Linux 32-bit.")
        sys.exit(0)
    else:
        # Build cefclient, cefsimple, ceftests, libcef_dll_wrapper
        build_cef_projects()
        create_prebuilt_binaries()


def prebuilt_cef():
    """Use prebuilt binaries."""

    # TODO: Option to download CEF prebuilt binaries from GitHub Releases,
    #       eg. tag 'upstream-cef47'.

    # Find cef_binary directory in the build directory
    postfix2 = CEF_POSTFIX2
    if Options.x86:
        postfix2 = get_cef_postfix2_for_arch("32bit")
    if Options.cef_version:
        cef_binary = os.path.join(Options.build_dir,
                                  "cef_binary_{cef_version}_{os}{sep}"
                                  .format(cef_version=Options.cef_version,
                                          os=postfix2,
                                          sep=os.sep))
    else:
        cef_binary = os.path.join(Options.build_dir,
                                  "cef_binary_3.{cef_branch}.*_{os}{sep}"
                                  .format(cef_branch=Options.cef_branch,
                                          os=postfix2,
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
    run_git("clone -b %s %s cef" % (Options.cef_branch, Options.cef_git_url),
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
        cef_patch_cfg_contents = fp.read().decode("utf-8")
        cef_patch_cfg_contents += "\n"
    cefpython_patch_cfg = os.path.join(cefpython_patches_dir, "patch.py")
    with open(cefpython_patch_cfg, "rb") as fp:
        cefpython_patch_cfg_contents = fp.read().decode("utf-8")
    with open(cef_patch_cfg, "wb") as fp:
        cef_patch_cfg_contents = cef_patch_cfg_contents.replace("\r\n", "\n")
        cefpython_patch_cfg_contents = cefpython_patch_cfg_contents.replace(
                                                                "\r\n", "\n")
        new_contents = cef_patch_cfg_contents + cefpython_patch_cfg_contents
        fp.write(new_contents.encode("utf-8"))


def build_cef_projects():
    """Build cefclient, cefsimple, ceftests, libcef_dll_wrapper."""
    print("[automate.py] Build cef projects...")

    if WINDOWS:
        fix_cmake_variables_permanently_windows()

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
            postfix2 = CEF_POSTFIX2
            if Options.x86:
                postfix2 = get_cef_postfix2_for_arch("32bit")
            files = glob.glob(os.path.join(Options.binary_distrib,
                                           "cef_binary_*_"+postfix2))
            assert len(files) == 1, "Error finding binary distrib"
            cef_binary = files[0]
        assert os.path.exists(cef_binary)
        Options.cef_binary = cef_binary

    # Set build directory
    build_cefclient_dir = os.path.join(Options.cef_binary,
                                       "build_cefclient")
    cefclient_exe = os.path.join(build_cefclient_dir, "tests", "cefclient",
                                 Options.build_type,
                                 "cefclient" + APP_EXT)

    # Check whether already built
    already_built = False
    if os.path.exists(cefclient_exe):
        already_built = True
    elif os.path.exists(build_cefclient_dir):
        # Last build failed, clean directory
        assert build_cefclient_dir
        shutil.rmtree(build_cefclient_dir)
        print("[automate.py] Create build_cefclient/ dir in cef_binary*/ dir")
        os.makedirs(build_cefclient_dir)
    else:
        print("[automate.py] Create build_cefclient/ dir in cef_binary*/ dir")
        os.makedirs(build_cefclient_dir)

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
        run_command(command, build_cefclient_dir)
        print("[automate.py] OK")
        # Ninja
        command = prepare_build_command()
        # On Mac cefclient fails with XCode 5:
        # > cefclient_mac.mm:22:29: error: property 'mainMenu' not found
        if MAC:
            # Build only cefsimple
            command.extend(["ninja", "-j", Options.ninja_jobs,
                            "cefsimple"])
        else:
            command.extend(["ninja", "-j", Options.ninja_jobs,
                            "cefclient", "cefsimple", "ceftests"])
        run_command(command, build_cefclient_dir)
        print("[automate.py] OK")
        assert os.path.exists(cefclient_exe)

    # Build libcef_dll_wrapper libs
    if WINDOWS:
        build_all_wrapper_libraries_windows()
    elif MAC:
        build_wrapper_library_mac()


def build_all_wrapper_libraries_windows():
    python_compilers = get_available_python_compilers()
    if not len(python_compilers):
        print("[automate.py] ERROR: Visual Studio compiler not found")
        sys.exit(1)
    for msvs in python_compilers:
        vcvars = python_compilers[msvs]
        print("[automate.py] Build libcef_dll_wrapper libraries for"
              " VS{msvs}".format(msvs=msvs))
        build_wrapper_library_windows(runtime_library=RUNTIME_MT,
                                      msvs=msvs, vcvars=vcvars)
        build_wrapper_library_windows(runtime_library=RUNTIME_MD,
                                      msvs=msvs, vcvars=vcvars)


def build_wrapper_library_windows(runtime_library, msvs, vcvars):
    # When building library cmake variables file is being modified
    # for the /MD build. If the build fails and variables aren't
    # restored then the next /MT build would be broken. Make sure
    # that original contents of cmake variables files is always
    # restored.
    fix_cmake_variables_for_MD_library(try_undo=True)

    # Command to build libcef_dll_wrapper
    cmake_wrapper = prepare_build_command(build_lib=True, vcvars=vcvars)
    cmake_wrapper.extend(["cmake", "-G", "Ninja",
                         "-DCMAKE_BUILD_TYPE="+Options.build_type, ".."])

    # Build directory and library path
    build_wrapper_dir = os.path.join(
            Options.cef_binary,
            "build_wrapper_{runtime_library}_VS{msvs}"
            .format(runtime_library=runtime_library, msvs=msvs))
    wrapper_lib = os.path.join(build_wrapper_dir, "libcef_dll_wrapper",
                               "libcef_dll_wrapper{ext}".format(ext=LIB_EXT))

    # Check whether library is already built
    mt_already_built = False
    if os.path.exists(wrapper_lib):
        mt_already_built = True
    elif os.path.exists(build_wrapper_dir):
        # Last build failed, clean directory
        assert build_wrapper_dir
        shutil.rmtree(build_wrapper_dir)
        os.makedirs(build_wrapper_dir)
    else:
        os.makedirs(build_wrapper_dir)

    # Build library
    if mt_already_built:
        print("[automate.py] Already built: libcef_dll_wrapper"
              " /{runtime_library} for VS{msvs}"
              .format(runtime_library=runtime_library, msvs=msvs))
    else:
        print("[automate.py] Build libcef_dll_wrapper"
              " /{runtime_library} for VS{msvs}"
              .format(runtime_library=runtime_library, msvs=msvs))

        # Run cmake
        old_gyp_msvs_version = Options.gyp_msvs_version
        Options.gyp_msvs_version = msvs
        if runtime_library == RUNTIME_MD:
            fix_cmake_variables_for_MD_library()
        env = getenv()
        if msvs == "2010":
            # When Using WinSDK 7.1 vcvarsall.bat doesn't work. Use
            # setuptools.msvc.msvc9_query_vcvarsall to query env vars.
            from setuptools.msvc import msvc9_query_vcvarsall
            env.update(msvc9_query_vcvarsall(10.0, arch=VS_PLATFORM_ARG))
            # On Python 2.7 env values returned by both distutils
            # and setuptools are unicode, but Python expects env
            # dict values as strings.
            for env_key in env:
                env_value = env[env_key]
                if type(env_value) != str:
                    env[env_key] = env_value.encode("utf-8")
        run_command(cmake_wrapper, working_dir=build_wrapper_dir, env=env)
        Options.gyp_msvs_version = old_gyp_msvs_version
        if runtime_library == RUNTIME_MD:
            fix_cmake_variables_for_MD_library(undo=True)
        print("[automate.py] cmake OK")

        # Run ninja
        ninja_wrapper = prepare_build_command(build_lib=True, vcvars=vcvars)
        ninja_wrapper.extend(["ninja", "-j", Options.ninja_jobs,
                              "libcef_dll_wrapper"])
        run_command(ninja_wrapper, working_dir=build_wrapper_dir)
        print("[automate.py] ninja OK")
        assert os.path.exists(wrapper_lib)


def fix_cmake_variables_permanently_windows():
    """Changes to cef_variables.cmake are made permanently, there is no undo.
    """
    # To get rid of these warnings:
    # > cl : Command line warning D9025 : overriding '/GR' with '/GR-'
    # > cl : Command line warning D9025 : overriding '/W3' with '/W4'
    # > cl : Command line warning D9025 : overriding '/MD' with '/MT'
    cmake_variables = os.path.join(Options.cef_binary, "cmake",
                                   "cef_variables.cmake")
    with open(cmake_variables, "rb") as fp:
        contents = fp.read().decode("utf-8")
    set1 = 'set(CMAKE_CXX_FLAGS_RELEASE "")'
    set2 = 'set(CMAKE_CXX_FLAGS "")'
    if "if(OS_WINDOWS)" not in contents:
        print("[automate.py] WARNING: failed to fix cmake variables"
              " permanently on Windows")
        return
    if set1 not in contents or set2 not in contents:
        contents = contents.replace("if(OS_WINDOWS)",
                                    "if(OS_WINDOWS)\n  {set1}\n  {set2}"
                                    .format(set1=set1, set2=set2))
    else:
        return
    with open(cmake_variables, "wb") as fp:
        print("[automate.py] Fix permanently: {filename}"
              .format(filename=os.path.basename(cmake_variables)))
        fp.write(contents.encode("utf-8"))


def fix_cmake_variables_for_MD_library(undo=False, try_undo=False):
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

    mt_find = u'CEF_RUNTIME_LIBRARY_FLAG "/MT"'
    mt_replace = u'CEF_RUNTIME_LIBRARY_FLAG "/MD"'

    wd4275_find = (u'/wd4244       '
                   u'# Ignore "conversion possible loss of data" warning')
    wd4275_replace = (u'/wd4244       '
                      u'# Ignore "conversion possible loss of data" warning'
                      u'\r\n'
                      u'    /wd4275 # Ignore "non dll-interface class"')

    cmake_variables = os.path.join(Options.cef_binary, "cmake",
                                   "cef_variables.cmake")
    with open(cmake_variables, "rb") as fp:
        contents = fp.read().decode("utf-8")

    if try_undo:
        matches1 = re.findall(re.escape(mt_replace), contents)
        matches2 = re.findall(re.escape(wd4275_replace), contents)
        if len(matches1) or len(matches2):
            undo = True
        else:
            return

    if undo:
        (contents, count) = re.subn(re.escape(mt_replace), mt_find,
                                    contents)
        assert count == 1
        (contents, count) = re.subn(re.escape(wd4275_replace), wd4275_find,
                                    contents)
        assert count == 1
    else:
        (contents, count) = re.subn(re.escape(mt_find), mt_replace,
                                    contents)
        print(re.escape(mt_find))
        assert count == 1
        (contents, count) = re.subn(re.escape(wd4275_find), wd4275_replace,
                                    contents)
        assert count == 1

    with open(cmake_variables, "wb") as fp:
        fp.write(contents.encode("utf-8"))


def build_wrapper_library_mac():
    # On Mac it is required to link libcef_dll_wrapper against
    # libc++ library, so must build this library separately
    # from cefclient.
    cmake_wrapper = prepare_build_command(build_lib=True)
    cmake_wrapper.extend(["cmake", "-G", "Ninja",
                          "-DPROJECT_ARCH=x86_64",
                          "-DCMAKE_CXX_FLAGS=-stdlib=libc++",
                          "-DCMAKE_BUILD_TYPE=" + Options.build_type,
                          ".."])
    build_wrapper_dir = os.path.join(Options.cef_binary,
                                     "build_wrapper")
    wrapper_lib = os.path.join(build_wrapper_dir, "libcef_dll_wrapper",
                               "libcef_dll_wrapper.a")

    # Check whether already built
    already_built = False
    if os.path.exists(wrapper_lib):
        already_built = True
    elif os.path.exists(build_wrapper_dir):
        # Last build failed, clean directory
        assert build_wrapper_dir
        shutil.rmtree(build_wrapper_dir)
        os.makedirs(build_wrapper_dir)
    else:
        os.makedirs(build_wrapper_dir)

    # Build libcef_dll_wrapper library
    if already_built:
        print("[automate.py] Already built: libcef_dll_wrapper")
    else:
        print("[automate.py] Build libcef_dll_wrapper")
        # Cmake
        run_command(cmake_wrapper, build_wrapper_dir)
        print("[automate.py] cmake OK")
        # Ninja
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper.extend(["ninja", "-j", Options.ninja_jobs,
                              "libcef_dll_wrapper"])
        run_command(ninja_wrapper, build_wrapper_dir)
        print("[automate.py] ninja OK")
        assert os.path.exists(wrapper_lib)


def prepare_build_command(build_lib=False, vcvars=None):
    """On Windows VS env variables must be set up by calling vcvarsall.bat"""
    command = list()
    if platform.system() == "Windows":
        if build_lib:
            if vcvars == VS2010_VCVARS:
                # When using WinSDK 7.1 vcvarsall.bat is broken. Instead
                # env variables are queried using setuptools.msvc.
                return command
            if vcvars:
                command.append(vcvars)
            else:
                command.append(get_vcvars_for_python())
            command.append(VS_PLATFORM_ARG)
        else:
            if int(Options.cef_branch) >= 2704:
                command.append(VS2015_VCVARS)
            else:
                command.append(VS2013_VCVARS)
            command.append(VS_PLATFORM_ARG)
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
            contents = fp.read().decode("utf-8")
        # error C2059: syntax error : '{'
        contents = contents.replace("s->range = {0, 0};",
                                    "s->range.from = 0; s->range.to = 0;")
        with open(cef_types_wrappers, "wb") as fp:
            fp.write(contents.encode("utf-8"))


def create_prebuilt_binaries():
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
            "cefclient" + APP_EXT)
    if not MAC:
        assert os.path.exists(cefclient)
    if LINUX:
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
            "cefsimple" + APP_EXT)
    if not MAC:
        assert os.path.exists(cefsimple)

    # ceftests
    ceftests = os.path.join(
            src,
            "build_cefclient", "tests", "ceftests",
            Options.build_type,
            "ceftests" + APP_EXT)
    if not MAC:
        assert os.path.exists(ceftests)
    if LINUX:
        # On Windows resources/*.html files are embedded inside exe
        ceftests_files = os.path.join(
                src,
                "build_cefclient", "tests", "ceftests",
                Options.build_type,
                "ceftests_files")
        cpdir(ceftests_files, os.path.join(bindir, "ceftests_files"))

    def copy_app(app):
            if MAC:
                # On Mac app is a directory
                shutil.copytree(app,
                                os.path.join(bindir,
                                             os.path.basename(app)))
            else:
                shutil.copy(app, bindir)

    if not MAC:
        # Currently do not copy apps on Mac, as they take lots of
        # additional space (cefsimple is 157 MB).
        copy_app(cefclient)
        copy_app(cefsimple)
        copy_app(ceftests)

    # END: Copy cefclient, cefsimple, ceftests

    # Copy libraries
    if platform.system() == "Windows":
        # libcef.lib and cef_sandbox.lib
        mvfiles(bindir, libdir, ".lib")
        python_compilers = get_available_python_compilers()
        for msvs in python_compilers:
            vs_subdir = os.path.join(libdir, "VS{msvs}".format(msvs=msvs))
            os.makedirs(vs_subdir)
            # MT library
            libsrc = os.path.join(
                    src, "build_wrapper_MT_VS{msvs}".format(msvs=msvs),
                    "libcef_dll_wrapper", "libcef_dll_wrapper.lib")
            libdst = os.path.join(vs_subdir, "libcef_dll_wrapper_MT.lib")
            shutil.copy(libsrc, libdst)
            # MD library
            libsrc = os.path.join(
                    src, "build_wrapper_MD_VS{msvs}".format(msvs=msvs),
                    "libcef_dll_wrapper", "libcef_dll_wrapper.lib")
            libdst = os.path.join(vs_subdir, "libcef_dll_wrapper_MD.lib")
            shutil.copy(libsrc, libdst)
    elif platform.system() == "Darwin":
        shutil.copy(os.path.join(src, "build_wrapper", "libcef_dll_wrapper",
                                 "libcef_dll_wrapper.a"),
                    libdir)
    else:
        # cefclient builds libcef_dll_wrapper by default and this version
        # is good for cefpython on Linux. On Windows and Mac
        # libcef_dll_wrapper is built seprately.
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

    # Copy cef_version.h
    cef_version_file = os.path.join(dst, "cef_version_{os_postfix}.h".format(
                                    os_postfix=OS_POSTFIX))
    shutil.copy(os.path.join(src, "include", "cef_version.h"),
                cef_version_file)

    print("[automate.py] OK prebuilt binaries created in '%s/'" % dst)


def get_available_python_compilers():
    all_python_compilers = OrderedDict([
        ("2008", VS2008_VCVARS),
        ("2010", VS2010_VCVARS),
        ("2015", VS2015_VCVARS),
    ])
    ret_compilers = OrderedDict()
    for msvs in all_python_compilers:
        vcvars = all_python_compilers[msvs]
        if os.path.exists(vcvars):
            ret_compilers[msvs] = vcvars
        else:
            print("[automate.py] INFO: Visual Studio compiler not found:"
                  " {vcvars}".format(vcvars=vcvars))
    return ret_compilers


def get_vcvars_for_python():
    msvs = get_msvs_for_python()
    return globals()["VS"+msvs+"_VCVARS"]


def getenv():
    """Env variables passed to shell when running commands.
    See cef/AutomatedBuildSetup.md for reference."""
    env = os.environ

    # PATH
    if Options.build_cef:
        if os.path.exists(Options.depot_tools_dir):
            env["PATH"] = Options.depot_tools_dir + os.pathsep + env["PATH"]

    # Generators: ninja, msvs
    env["GYP_GENERATORS"] = Options.gyp_generators

    # VS version
    if platform.system() == "Windows":
        env["GYP_MSVS_VERSION"] = Options.gyp_msvs_version

    # GN configuration
    env["CEF_USE_GN"] = "1"
    # Issue #73 patch applied here with "use_allocator=none"
    env["GN_DEFINES"] = "use_sysroot=true use_allocator=none symbol_level=1"

    # Link with GTK 3 (Issue #446)
    if Options.use_gtk3:
        env["GN_DEFINES"] += " use_gtk3=true"

    # Use ccache for faster (re)builds
    if Options.use_ccache:
        env["GN_DEFINES"] += " cc_wrapper=ccache"

    # Enable proprietary codecs
    if Options.proprietary_codecs:
        env["GN_DEFINES"] += " proprietary_codecs=true ffmpeg_branding=Chrome"

    # To perform an official build set GYP_DEFINES=buildtype=Official.
    # This will disable debugging code and enable additional link-time
    # optimizations in Release builds.
    if Options.release_build and not Options.fast_build:
        env["GN_DEFINES"] += " is_official_build=true"

    # Blurry font rendering on Linux (Isssue #402)
    if Options.use_system_freetype:
        env["GN_DEFINES"] += " use_system_freetype=true"

    # GYP configuration is DEPRECATED, however it is still set in
    # upstream Linux configuration on AutomatedBuildSetup wiki page,
    # so setting it here as well.
    env["GYP_DEFINES"] = "disable_nacl=1 use_sysroot=1 use_allocator=none"
    if Options.x86:
        env["GYP_DEFINES"] += " host_arch=x86_64 target_arch=ia32"
    if Options.release_build and not Options.fast_build:
        env["GYP_DEFINES"] += " buildtype=Official"

    # Modifications to upstream automate-git.py introduced
    # CEFPYTHON_NINJA_JOBS env key.
    env["CEFPYTHON_NINJA_JOBS"] = str(Options.ninja_jobs)

    return env


def run_command(command, working_dir, env=None):
    """Run command in a given directory with env variables set.
    On Linux multiple commands on one line with the use of && are not allowed.
    """
    if isinstance(command, list):
        command_str = " ".join(command)
    else:
        command_str = command
    print("[automate.py] Running '"+command_str+"' in '" +
          working_dir+"'...")
    if isinstance(command, str):
        args = shlex.split(command.replace("\\", "\\\\"))
    else:
        args = command
    if not env:
        env = getenv()
    # When passing list of args shell cannot be True on eg. Linux, read
    # notes in build.py
    shell = (platform.system() == "Windows")
    return subprocess.check_call(args, cwd=working_dir, env=env, shell=shell)


def run_git(command_line, working_dir):
    """Run git command using depot_tools."""
    return run_command("git %s" % command_line, working_dir)


def run_automate_git():
    """Run CEF automate-git.py using Python 2.7."""
    script = os.path.join(Options.cefpython_dir, "tools", "automate-git.py")
    """
    Example automate-git.py command:
        C:\chromium>call python automate-git.py --download-dir=./test/
        --branch=2526 --no-debug-build --verbose-build --with-pgo-profiles
    Run ninja build manually:
        cd chromium/src
        ninja -v -j2 -Cout\Release cefclient
    """
    args = []
    if ARCH64 and not Options.x86:
        args.append("--x64-build")
    args.append("--download-dir=" + Options.cef_build_dir)
    args.append("--branch=" + Options.cef_branch)
    if Options.no_depot_tools_update:
        args.append("--no-depot-tools-update")
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
    args.append("--with-pgo-profiles")
    if platform.system() == "Linux":
        # Building cefclient target isn't supported on Linux when
        # using sysroot (cef/#1916). However building cefclient
        # later in cef_binary/ with cmake/ninja do works fine.
        args.append("--build-target=cefsimple")

    args = " ".join(args)
    command = script + " " + args
    working_dir = Options.cef_build_dir
    return run_command("%s %s" % (sys.executable, command), working_dir)


def run_make_distrib():
    """Run CEF make_distrib script."""
    print("[automate.py] Make CEF binary distribution")
    script_ext = "bat" if WINDOWS else "sh"
    base_script = "make_distrib.{ext}".format(ext=script_ext)
    tools_dir = os.path.join(Options.cef_build_dir, "chromium", "src", "cef",
                             "tools")
    script = os.path.join(tools_dir, base_script)
    args = list()
    args.append("--allow-partial")
    args.append("--ninja-build")
    if ARCH64 and not Options.x86:
        args.append("--x64-build")
    args.append("--no-archive")
    args = " ".join(args)
    command = "{script} {args}".format(script=script, args=args)
    status = run_command(command, tools_dir)
    if status == 0:
        print("[automate.py] Done. CEF binary distribution created in: {dir}"
              .format(dir=Options.binary_distrib))
    else:
        print("[automate.py] Error while making CEF binary distribution")
        sys.exit(1)


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
    postfix2 = OS_POSTFIX2
    if Options.x86:
        postfix2 = get_os_postfix2_for_arch("32bit")
    name = "cef%s_%s_%s" % (
        version["CHROME_VERSION_MAJOR"],
        version["CEF_VERSION"],
        postfix2
    )
    return name


if __name__ == "__main__":
    main()
