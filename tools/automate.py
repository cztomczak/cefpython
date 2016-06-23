# Copyright (c) 2016 CEF Python, see the Authors file. All rights reserved.

# TODO: add GYP_DEFINES: disable_nacl=1 use_sysroot=1 (AutomatedBuildSetup)
# TODO: run automate-git.py using Python 2.7 from depot_tools

"""Build CEF Python and use prebuilt CEF binaries or build CEF from sources.

Usage:
    automate.py (--prebuilt-cef | --build-cef)
                [--cef-branch BRANCH] [--cef-commit COMMIT]
                [--build-dir BUILDDIR] [--cef-build-dir CEFBUILDDIR]
                [--ninja-jobs JOBS] [--gyp-generators GENERATORS]
                [--gyp-msvs-version MSVS]
    automate.py (-h | --help) [type -h to show full description for options]

Options:
    -h --help               Show this help message.
    --prebuilt-cef          Whether to use prebuilt CEF binaries. Prebuilt
                            binaries for Linux are built on Ubuntu.
    --build-cef             Whether to build CEF from sources with the cefpython
                            patches applied.
    --cef-branch=<b>        CEF branch. Defaults to CHROME_VERSION_BUILD from
                            "src/version/cef_version_{platform}.h" (TODO).
    --cef-commit=<c>        CEF revision. Defaults to CEF_COMMIT_HASH from
                            "src/version/cef_version_{platform}.h" (TODO).
    --build-dir=<dir1>      Build directory.
    --cef-build-dir=<dir2>  CEF build directory. By default same
                            as --build-dir.
    --ninja-jobs=<jobs>     How many CEF jobs to run in parallel. To speed up
                            building set it to number of cores in your CPU.
                            By default set to cpu_count / 2.
    --gyp-generators=<gen>  Set GYP_GENERATORS [default: ninja].
    --gyp-msvs-version=<v>  Set GYP_MSVS_VERSION.

"""

import os
import sys
import shlex
import subprocess
import platform
import docopt
import struct
import re
import stat
import glob
import shutil
import multiprocessing

# CONSTANTS
ARCH32 = (8 * struct.calcsize('P') == 32)
ARCH64 = (8 * struct.calcsize('P') == 64)
OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")
OS_POSTFIX2 = "unknown"
if OS_POSTFIX == "win":
    OS_POSTFIX2 = "win32" if ARCH32 else "win64"
elif OS_POSTFIX == "mac":
    OS_POSTFIX2 = "mac32" if ARCH32 else "mac64"
elif OS_POSTFIX == "linux":
    OS_POSTFIX2 = "linux32" if ARCH32 else "linux64"

CEF_GIT_URL = "https://bitbucket.org/chromiumembedded/cef.git"

VS2015_VCVARS = "\"C:\Program Files (x86)\\Microsoft Visual Studio 14.0" \
                "\\VC\\bin\\vcvars32.bat\"" \
                if ARCH32 else \
                "\"C:\Program Files (x86)\\Microsoft Visual Studio 14.0" \
                "\\VC\\bin\\amd64\\vcvars64.bat\""

VS2013_VCVARS = "\"C:\Program Files (x86)\\Microsoft Visual Studio 12.0" \
                "\\VC\\bin\\vcvars32.bat\"" \
                if ARCH32 else \
                "\"C:\Program Files (x86)\\Microsoft Visual Studio 12.0" \
                "\\VC\\bin\\amd64\\vcvars64.bat\""

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
    cef_branch = ""
    cef_commit = ""
    build_dir = ""
    cef_build_dir = ""
    ninja_jobs = None
    gyp_generators = "ninja"
    gyp_msvs_version = ""

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
    setup_options(docopt.docopt(__doc__))

    if Options.build_cef:
        build_cef()
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

    # --cef-branch
    if not Options.cef_branch:
        # Use branch from the src/version/cef_version_*.h file
        Options.cef_branch = get_cefpython_version()["CHROME_VERSION_BUILD"]

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

    # Build cefclient, cefsimple, libcef_dll_wrapper
    build_cef_projects()


def create_cef_directories():
    """Create cef/ directories in cef_build_dir/ and in chromium/src/ ."""
    cef_dir = os.path.join(Options.cef_build_dir, "cef")
    src_dir = os.path.join(Options.cef_build_dir, "chromium", "src")
    cef_dir2 = os.path.join(src_dir, "cef")
    # Clone cef repo and checkout branch
    if os.path.exists(cef_dir):
        rmdir(cef_dir)
    run_git("clone %s cef" % CEF_GIT_URL, Options.cef_build_dir)
    run_git("checkout %s" % Options.cef_branch, cef_dir)
    if Options.cef_commit:
        run_git("checkout %s" % Options.cef_commit, cef_dir)
    # Update cef patches
    update_cef_patches()
    # Copy cef/ to chromium/src/ but only if chromium/src/ exists.
    if os.path.exists(src_dir):
        if os.path.exists(cef_dir2):
            rmdir(cef_dir2)
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
    """Build cefclient, cefsimple, libcef_dll_wrapper."""
    print("[automate.py] Binary distrib created in %s"
          % Options.binary_distrib)
    print("[automate.py] Building cef projects...")

    # Find cef_binary directories and create the cef_binary/build/ dir
    if platform.system() == "Windows":
        files = glob.glob(os.path.join(Options.binary_distrib,
                                       "cef_binary_*_symbols"))
        assert len(files) == 1, "More than one dir with release symbols found"
        symbols = files[0]
        if Options.release_build:
            cef_binary = symbols.replace("_release_symbols", "")
        else:
            cef_binary = symbols.replace("_debug_symbols", "")
        assert "symbols" not in os.path.basename(cef_binary)
    else:
        files = glob.glob(os.path.join(Options.binary_distrib,
                                       "cef_binary_*_"+OS_POSTFIX2))
        assert len(files) == 1, "More than one cef binary dir found"
        cef_binary = files[0]
    assert os.path.exists(cef_binary)
    Options.cef_binary = cef_binary
    build_cefclient = os.path.join(cef_binary, "build_cefclient")
    os.makedirs(build_cefclient)

    # Build cefclient and cefsimple
    print("[automate.py] Building cefclient and cefsimple...")
    command = ""
    if platform.system() == "Windows":
        if int(Options.cef_branch) >= 2704:
            command += VS2015_VCVARS + " && "
        else:
            command += VS2013_VCVARS + " && "
    command += "cmake -G \"Ninja\" -DCMAKE_BUILD_TYPE=%s .." \
               % Options.build_type
    run_command(command, build_cefclient)
    print("[automate.py] OK")
    # On Linux cannot pass "&&" and run two commands using run_command()
    command = "ninja cefclient cefsimple"
    run_command(command, build_cefclient)
    print("[automate.py] OK")
    if platform.system() == "Windows":
        assert(os.path.exists(os.path.join(build_cefclient,
                                           "cefclient", "cefclient.exe")))
    else:
        assert (os.path.exists(os.path.join(build_cefclient,
                                            "cefclient", "cefclient")))

    # Build libcef_dll_wrapper libs
    if platform.system() == "Windows":
        build_wrapper_windows(cef_binary)


def build_wrapper_windows(cef_binary):
    # Directories
    build_wrapper_mt = os.path.join(cef_binary, "build_wrapper_mt")
    build_wrapper_md = os.path.join(cef_binary, "build_wrapper_md")
    os.makedirs(build_wrapper_mt)
    os.makedirs(build_wrapper_md)

    # Command to build libcef_dll_wrapper
    wrapper_cmake = ""
    wrapper_cmake += VS2008_VCVARS + " && "
    wrapper_cmake += "cmake -G \"Ninja\" -DCMAKE_BUILD_TYPE=%s .." \
                     % Options.build_type

    # Build libcef_dll_wrapper_mt.lib
    print("[automate.py] Building libcef_dll_wrapper /MT")
    old_gyp_msvs_version = Options.gyp_msvs_version
    Options.gyp_msvs_version = get_msvs_for_python()
    run_command(wrapper_cmake, build_wrapper_mt)
    Options.gyp_msvs_version = old_gyp_msvs_version
    print("[automate.py] cmake OK")
    run_command("ninja libcef_dll_wrapper", build_wrapper_mt)
    print("[automate.py] ninja OK")
    assert(os.path.exists(os.path.join(build_wrapper_mt, "libcef_dll",
                                       "libcef_dll_wrapper.lib")))

    # Build libcef_dll_wrapper_md.lib
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
    run_command("ninja libcef_dll_wrapper", build_wrapper_md)
    print("[automate.py] ninja OK")
    assert(os.path.exists(os.path.join(build_wrapper_md, "libcef_dll",
                                       "libcef_dll_wrapper.lib")))


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

    # Copy cefclient, cefsimple
    cefclient = os.path.join(src, "build_cefclient", "cefclient", "cefclient")
    cefclient_files = os.path.join(src, "build_cefclient", "cefclient",
                                   "files")
    cpdir(cefclient_files, os.path.join(bindir, "files"))
    cefsimple = os.path.join(src, "build_cefclient", "cefsimple", "cefsimple")
    if platform.system() == "Windows":
        cefclient += ".exe"
        cefsimple += ".exe"
    shutil.copy(cefclient, bindir)
    shutil.copy(cefsimple, bindir)

    # Copy libraries
    if platform.system() == "Windows":
        # libcef.lib and cef_sandbox.lib
        mvfiles(bindir, libdir, ".lib")
        # MT lib
        libsrc = os.path.join(src, "build_wrapper_mt", "libcef_dll",
                              "libcef_dll_wrapper.lib")
        libdst = os.path.join(libdir, "licef_dll_wrapper_mt.lib")
        shutil.copy(libsrc, libdst)
        # MD lib
        libsrc = os.path.join(src, "build_wrapper_md", "libcef_dll",
                              "libcef_dll_wrapper.lib")
        libdst = os.path.join(libdir, "licef_dll_wrapper_md.lib")
        shutil.copy(libsrc, libdst)
    elif platform.system() == "Linux":
        cpdir(os.path.join(src, "build_cefclient", "libcef_dll"), libdir)

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


def prebuilt_cef():
    """Download CEF prebuilt binaries from GitHub Releases,
    eg tag 'upstream-cef47'."""
    pass


def getenv():
    """Env variables passed to shell when running commands."""
    env = os.environ
    env["PATH"] = Options.depot_tools_dir + os.pathsep + env["PATH"]
    env["GYP_GENERATORS"] = Options.gyp_generators
    if platform.system() == "Windows":
        env["GYP_MSVS_VERSION"] = Options.gyp_msvs_version
    # Issue73 patch applied
    env["GYP_DEFINES"] = "use_allocator=none"
    # To perform an official build set GYP_DEFINES=buildtype=Official.
    # This will disable debugging code and enable additional link-time
    # optimizations in Release builds.
    if Options.release_build:
        env["GYP_DEFINES"] += " buildtype=Official"
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
    if ARCH64 and platform.system() != "Linux":
        # The x64 build flag is only supported on Windows and Mac OS X.
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
    args.append("--no-distrib-archive")

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
        raise


def get_cefpython_version():
    """Get CEF version from the 'src/version/' directory."""
    header_file = os.path.join(Options.cefpython_dir, "src", "version",
                               "cef_version_"+OS_POSTFIX+".h")
    return get_version_from_file(header_file)


def get_version_from_file(header_file):
    with open(header_file, "rU") as fp:
        contents = fp.read()
    ret = dict()
    matches = re.findall(r'^#define (\w+) "?([^\s"]+)"?', contents,
                         re.MULTILINE)
    for match in matches:
        ret[match[0]] = match[1]
    return ret


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
