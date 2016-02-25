# Copyright (c) 2016 The CEF Python authors. All rights reserved.

"""Build cefpython. Use prebuilt CEF binaries or build CEF from sources.

Usage:
    automate.py (--prebuilt-cef | --build-cef)
                [--cef-branch BRANCH] [--cef-commit COMMIT]
                [--build-dir BUILDDIR] [--cef-build-dir CEFBUILDDIR]
                [--gyp-generators <ninja,msvs-ninja>]
                [--gyp-msvs-version <2013>]
    automate.py (-h | --help) [type -h to show full description for options]


Options:
    -h --help           Show this help message.
    --prebuilt-cef      Whether to use prebuilt CEF binaries. Prebuilt
                        binaries for Linux are build on Debian/Ubuntu.
    --build-cef         Whether to build CEF from sources with the cefpython
                        patches applied.
    --cef-branch        CEF branch. Defaults to CHROME_VERSION_BUILD from
                        "cefpython/version/cef_version_{platform}.h".
    --cef-commit        CEF revision. Defaults to CEF_COMMIT_HASH from
                        "cefpython/version/cef_version_{platform}.h".
    --build-dir         Build directory.
    --cef-build-dir     CEF build directory. By default same as --build-dir.
    --gyp-generators    Set GYP_GENERATORS [default: ninja,msvs-ninja].
    --gyp-msvs-version  Set GYP_MSVS_VERSION [default: 2013].

"""

# @TODO: -j2
# cd chromium/src
# ninja -v -j2 -Cout\Release cefclient

import os
import sys
import shlex
import subprocess
import platform
import docopt
import struct
import re

# CONSTANTS
ARCH32 = (8 * struct.calcsize('P') == 32)
ARCH64 = (8 * struct.calcsize('P') == 64)
OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")


class Options(object):
    """Options populated from command-line plus internal options."""

    # From command-line
    prebuilt_cef = False
    build_cef = False
    cef_branch = ""
    cef_commit = ""
    build_dir = ""
    cef_build_dir = ""
    gyp_generators = ""
    gyp_msvs_version = ""

    # Other options
    depot_tools_dir = ""
    tools_dir = ""
    cefpython_dir = ""

    @staticmethod
    def setup(docopt_args):
        """Setup options."""
        Options.populate_attrs(docopt_args)

        Options.tools_dir = os.path.dirname(os.path.realpath(__file__))
        Options.cefpython_dir = os.path.dirname(Options.tools_dir)

        # --build-dir
        if Options.build_dir:
            Options.build_dir = os.path.realpath(Options.build_dir)
        else:
            Options.build_dir = os.path.join(Options.cefpython_dir, "build")

        # --cef-build-dir
        if Options.cef_build_dir:
            Options.cef_build_dir = os.path.realpath(Options.cef_build_dir)
        else:
            Options.cef_build_dir = Options.build_dir

        # --depot-tools-dir
        Options.depot_tools_dir = os.path.join(Options.cef_build_dir,
                                               "depot_tools")

    @staticmethod
    def populate_attrs(docopt_args):
        """Populate this object attributes using command line arguments."""
        usage = __doc__
        for key in docopt_args:
            value = docopt_args[key]
            if key.startswith("--"):
                match = re.search(r"\[%s\s+([^\]]+)\]" % (re.escape(key),),
                                  usage)
                if match:
                    arg_key = match.group(1)
                    value = docopt_args[arg_key]
            key2 = key.replace("--", "").replace("-", "_")
            setattr(Options, key2, value)


def main():
    """Main entry point."""
    Options.setup(docopt.docopt(__doc__))

    if Options.prebuilt_cef:
        PrebuiltCEF()
    elif Options.build_cef:
        BuildCEF()


class Run(object):
    """Run commands: python, git, etc."""

    def getenv(self):
        """Env variables passed to shell when running commands."""
        # GYP_GENERATORS
        # GYP_MSVS_VERSION
        env = os.environ
        env["PATH"] = Options.depot_tools_dir + os.pathsep + env["PATH"]
        env["GYP_GENERATORS"] = Options.gyp_generators
        env["GYP_MSVS_VERSION"] = Options.gyp_msvs_version
        # Issue73 patch applied here.
        env["GYP_DEFINES"] = "use_allocator=none"
        return env

    def command(self, command_line, working_dir):
        """Run command in a given directory with env variables set."""
        print("[automate.py] Running '"+command_line+"' in '" +
              working_dir+"'...")
        args = shlex.split(command_line.replace("\\", "\\\\"))
        return subprocess.check_call(args, cwd=working_dir, env=self.getenv(),
                                     shell=(platform.system() == "Windows"))

    def python(self, command_line, working_dir):
        """Run python script using depot_tools."""
        if platform.system() == "Windows":
            python = os.path.join(Options.depot_tools_dir, "python.bat")
        else:
            python = "python"
        return self.command("%s %s" % (python, command_line), working_dir)

    def git(self, command_line, working_dir):
        """Run git command using depot_tools."""
        if platform.system() == "Windows":
            git = os.path.join(Options.depot_tools_dir, "git.bat")
        else:
            git = "git"
        return self.command("%s %s" % (git, command_line), working_dir)

    def automate_git(self, command_line):
        """Run CEF automate-git.py."""
        script = os.path.join(Options.cef_build_dir, "cef", "automate-git.py")
        args = [
            "--download-dir", Options.cef_build_dir,
        ]
        # args... @TODO
        """C:\chromium>call python automate-git.py --download-dir=./test/
         --branch=2526 --no-debug-build --verbose-build
         --no-cef-update --no-chromium-update --no-build"""
        if ARCH64:
            args.append("--x64-build")
        args = " ".join(args)
        return self.python(script+" "+args+" "+command_line,
                           Options.cef_build_dir)


class Version(object):
    """Which CEF version to use: branch and commit."""
    header_file = ""

    def get_branch(self):
        """Get CEF branch from cmd-line or from the 'cefpython/version/'
        dir. """
        if Options.cef_branch:
            return Options.cef_branch
        contents = self.get_header_file_contents()
        match = re.match(r"#define CHROME_VERSION_BUILD (\d+)", contents)
        if not match:
            print("[automate.py] CHROME_VERSION_BUILD not found in " +
                  self.header_file)
            sys.exit(1)
        return match.group(1)

    def get_commit(self):
        """Get CEF commit from cmd-line or from the 'cefpython/version'
        dir. """
        if Options.cef_commit:
            return Options.cef_commit
        contents = self.get_header_file_contents()
        match = re.match(r"#define CEF_COMMIT_HASH \"(\w+)\"", contents)
        if not match:
            print("[automate.py] CEF_COMMIT_HASH not found in " +
                  self.header_file)
            sys.exit(1)
        return match.group(1)

    def get_header_file_contents(self):
        """Get platform specific header file contents with version info."""
        self.header_file = os.path.join(Options.cefpython_dir, "cefpython",
                                        "version", "cef_version_" +
                                        OS_POSTFIX+".h")
        with open(self.header_file, "rU") as fp:
            contents = fp.read()
            return contents


class PrebuiltCEF(object):
    """Download CEF prebuilt binaries from GitHub Releases,
    eg tag 'upstream-cef47'."""
    pass


class BuildCEF(object):
    """Build CEF """
    pass


class Download(object):
    """Download operations: file downloads, git clones."""

    def depot_tools(self):
        """depot_tools comes with Python and Git on Windows."""
        pass

    def cef_sources(self):
        """Download CEF sources and checkout specific branch and commit."""
        pass

    def prebuilt_cef(self):
        """Download CEF prebuilt binaries."""
        pass


class Patches(object):
    """CEF python patches are in the 'cefpython/patches/ directory. """

    def apply_all(self):
        """Apply 'cefpython/patches/' to Chromium and/or CEF sources."""
        # Issue73 is applied in Run.getenv() by setting appropriate env var.
        pass


"""
def download_chromium_sources():
    pass
def create_cef_projects():
    pass
def ninja_build_cefclient():
    pass
def make_cef_distrib():
    pass
"""


if __name__ == "__main__":
    main()
