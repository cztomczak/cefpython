# Copyright (c) 2016 CEF Python, see the Authors file. All rights reserved.

"""Automates building CEF from sources with CEF Python patches applied.

Usage:
    automate.py (--prebuilt-cef | --build-cef)
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

VS2015_VCVARS = "\"C:\Program Files (x86)\\Microsoft Visual Studio 14.0" \
                "\\VC\\vcvarsall.bat\" x86" \
                if ARCH32 else \
                "\"C:\Program Files (x86)\\Microsoft Visual Studio 14.0" \
                "\\VC\\vcvarsall.bat\" amd64"

VS2013_VCVARS = "\"C:\Program Files (x86)\\Microsoft Visual Studio 12.0" \
                "\\VC\\vcvarsall.bat\" x86" \
                if ARCH32 else \
                "\"C:\Program Files (x86)\\Microsoft Visual Studio 12.0" \
                "\\VC\\cvarsall.bat\" amd64"

VS2008_VCVARS = "\"%LocalAppData%\\Programs\\Common\\Microsoft" \
                "\\Visual C++ for Python\\9.0\\vcvarsall.bat\" x86" \
                if ARCH32 else \
                "\"%LocalAppData%\\Programs\\Common\\Microsoft" \
                "\\Visual C++ for Python\\9.0\\vcvarsall.bat\" amd64"


class Options(object):
    """Options from command-line and internal options."""

    # From command-line
    prebuilt_cef = False
    build_cef = False
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


def main():
    """Main entry point."""

    if not ((2, 7) <= sys.version_info < (2, 8)):
        print("ERROR: to run this tool you need Python 2.7, as upstream")
        print("       automate-git.py works only with that version.")
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
                                  "cef_binary_{cef_version}_*{sep}"
                                  .format(cef_version=Options.cef_version,
                                          sep=os.sep))
    else:
        cef_binary = os.path.join(Options.build_dir,
                                  "cef_binary_3.{cef_branch}.*{sep}"
                                  .format(cef_branch=Options.cef_branch,
                                          sep=os.sep))
    dirs = glob.glob(cef_binary)
    if len(dirs) == 1:
        Options.cef_binary = dirs[0]
    else:
        print("ERROR: Could not find prebuilt binaries in the build dir.")
        print("       Eg. cef_binary_3.2883.1553.g80bd606_windows32/")
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

    # Find cef_binary directories and create the cef_binary/build/ dir
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

    print("[automate.py] Creating build_cefclient dir in cef_binary dir")
    build_cefclient = os.path.join(Options.cef_binary, "build_cefclient")
    already_built = False
    if os.path.exists(build_cefclient):
        already_built = True
    else:
        os.makedirs(build_cefclient)

    # Build cefclient, cefsimple, ceftests
    if already_built:
        print("[automate.py] Already built: cefclient, cefsimple, ceftests")
    else:
        print("[automate.py] Building cefclient, cefsimple, ceftests ...")
        command = prepare_build_command()
        command += "cmake -G \"Ninja\" -DCMAKE_BUILD_TYPE=%s .." \
                   % Options.build_type
        run_command(command, build_cefclient)
        print("[automate.py] OK")
        # On Linux cannot pass "&&" and run two commands using run_command()
        command = prepare_build_command()
        command += "ninja cefclient cefsimple ceftests"
        run_command(command, build_cefclient)
        print("[automate.py] OK")
        if platform.system() == "Windows":
            assert(os.path.exists(os.path.join(build_cefclient,
                                               "tests",
                                               "cefclient",
                                               Options.build_type,
                                               "cefclient.exe")))
        else:
            assert (os.path.exists(os.path.join(build_cefclient,
                                                "tests",
                                                "cefclient",
                                                Options.build_type,
                                                "cefclient")))

    # Build libcef_dll_wrapper libs
    if platform.system() == "Windows":
        build_wrapper_windows(Options.cef_binary)


def prepare_build_command(build_lib=False):
    """On Windows VS env variables must be set up by calling vcvarsall.bat"""
    command = ""
    if platform.system() == "Windows":
        if build_lib:
            msvs = get_msvs_for_python()
            command = globals()["VS"+msvs+"_VCVARS"] + " && "
        else:
            if int(Options.cef_branch) >= 2704:
                command = VS2015_VCVARS + " && "
            else:
                command = VS2013_VCVARS + " && "
    return command


def build_wrapper_windows(cef_binary):
    # Command to build libcef_dll_wrapper
    wrapper_cmake = prepare_build_command(build_lib=True)
    wrapper_cmake += "cmake -G \"Ninja\" -DCMAKE_BUILD_TYPE=%s .." \
                     % Options.build_type

    # Build libcef_dll_wrapper_mt.lib
    build_wrapper_mt = os.path.join(cef_binary, "build_wrapper_mt")
    mt_already_built = False
    if os.path.exists(build_wrapper_mt):
        mt_already_built = True
    else:
        os.makedirs(build_wrapper_mt)
    if mt_already_built:
        print("[automate.py] Already built: libcef_dll_wrapper /MT")
    else:
        print("[automate.py] Building libcef_dll_wrapper /MT")
        old_gyp_msvs_version = Options.gyp_msvs_version
        Options.gyp_msvs_version = get_msvs_for_python()
        run_command(wrapper_cmake, build_wrapper_mt)
        Options.gyp_msvs_version = old_gyp_msvs_version
        print("[automate.py] cmake OK")
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper += "ninja libcef_dll_wrapper"
        run_command(ninja_wrapper, build_wrapper_mt)
        print("[automate.py] ninja OK")
        assert(os.path.exists(os.path.join(build_wrapper_mt,
                                           "libcef_dll_wrapper",
                                           "libcef_dll_wrapper.lib")))

    # Build libcef_dll_wrapper_md.lib
    build_wrapper_md = os.path.join(cef_binary, "build_wrapper_md")
    md_already_built = False
    if os.path.exists(build_wrapper_md):
        md_already_built = True
    else:
        os.makedirs(build_wrapper_md)
    if md_already_built:
        print("[automate.py] Already built: libcef_dll_wrapper /MD")
    else:
        print("[automate.py] Building libcef_dll_wrapper /MD")
        old_gyp_msvs_version = Options.gyp_msvs_version
        Options.gyp_msvs_version = get_msvs_for_python()
        # Replace /MT with /MD /wd\"4275\" in CMakeLists.txt
        # Warnings are treated as errors so this needs to be ignored:
        # >> warning C4275: non dll-interface class 'stdext::exception'
        # >> used as base for dll-interface class 'std::bad_cast'
        # This warning occurs only in VS2008, in VS2013 not.
        cmakelists = os.path.join(cef_binary, "CMakeLists.txt")
        with open(cmakelists, "rb") as fp:
            contents = fp.read()
        contents = contents.replace(r"/MT ", r"/MD /wd\"4275\" ")
        contents = contents.replace(r"/MTd ", r"/MDd /wd\"4275\" ")
        with open(cmakelists, "wb") as fp:
            fp.write(contents)
        run_command(wrapper_cmake, build_wrapper_md)
        Options.gyp_msvs_version = old_gyp_msvs_version
        print("[automate.py] cmake OK")
        ninja_wrapper = prepare_build_command(build_lib=True)
        ninja_wrapper += "ninja libcef_dll_wrapper"
        run_command(ninja_wrapper, build_wrapper_md)
        print("[automate.py] ninja OK")
        assert(os.path.exists(os.path.join(build_wrapper_md,
                                           "libcef_dll_wrapper",
                                           "libcef_dll_wrapper.lib")))


def fix_cef_include_files():
    """Fixes to CEF include header files for eg. VS2008 on Windows."""
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


def create_prebuilt_binaries():
    """After building copy binaries/libs to build/cef_xxxx/. """
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
    cpdir(os.path.join(src, "Resources"), bindir)

    # Copy cefclient, cefsimple, ceftests

    # cefclient
    cefclient = os.path.join(
            src,
            "build_cefclient", "tests", "cefclient",
            Options.build_type,
            "cefclient")
    if platform.system() != "Windows":
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
            "cefsimple")

    # ceftests
    ceftests = os.path.join(
            src,
            "build_cefclient", "tests", "ceftests",
            Options.build_type,
            "ceftests")
    if platform.system() != "Windows":
        # On Windows resources/*.html files are embedded inside exe
        ceftests_files = os.path.join(
                src,
                "build_cefclient", "tests", "ceftests",
                Options.build_type,
                "ceftests_files")
        cpdir(ceftests_files, os.path.join(bindir, "ceftests_files"))

    if platform.system() == "Windows":
        cefclient += ".exe"
        cefsimple += ".exe"
        ceftests += ".exe"

    shutil.copy(cefclient, bindir)
    shutil.copy(cefsimple, bindir)
    shutil.copy(ceftests, bindir)

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
    elif platform.system() == "Linux":
        cpdir(os.path.join(src, "build_cefclient", "libcef_dll_wrapper"),
              libdir)

    # Remove .lib files from bin/ only after libraries were copied
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
    if Options.release_build:
        env["GN_DEFINES"] += " is_official_build=true"
    # Modifications to automate-git.py
    env["CEFPYTHON_NINJA_JOBS"] = str(Options.ninja_jobs)
    return env


def run_command(command_line, working_dir):
    """Run command in a given directory with env variables set.
    On Linux multiple commands on one line with the use of && are not allowed.
    """
    print("[automate.py] Running '"+command_line+"' in '" +
          working_dir+"'...")
    args = shlex.split(command_line.replace("\\", "\\\\"))
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
