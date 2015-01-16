# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

"""
Create a Debian Package.

Required dependencies:
  sudo apt-get install python-support
  sudo apt-get install python-pip
  sudo pip install stdeb==0.6.0
"""

import subprocess
import os, sys
import platform
import argparse
import re
import shutil

# -----------------------------------------------------------------------------
# Globals

BITS = platform.architecture()[0]
assert (BITS == "32bit" or BITS == "64bit")
ARCHITECTURE = "i386" if (BITS == "32bit") else "amd64"
if BITS == "32bit":
    LINUX_BITS = "linux32"
else:
    LINUX_BITS = "linux64"

PACKAGE_NAME = "cefpython3"
PYTHON_NAME ="python2.7" # Directory name in deb archive

HOMEPAGE = "https://code.google.com/p/cefpython/"
MAINTAINER = "Czarek Tomczak <czarek.tomczak@gmail.com>"
DESCRIPTION_EXTENDED = \
""" CEF Python 3 is a python library for embedding the Chromium
 browser. It uses the Chromium Embedded Framework (CEF) internally.
 Examples of embedding are available for many GUI toolkits,
 including wxPython, PyGTK, PyQt, PySide, Kivy and PyWin32.
"""

COPYRIGHT = \
"""Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Name: cefpython3
Maintainer: %s
Source: %s

Copyright: 2012-2014 The CEF Python authors
License: BSD 3-Clause

Files: *
Copyright: 2012-2014 The CEF Python authors
License: BSD 3-Clause
""" % (MAINTAINER, HOMEPAGE)

PYTHON_VERSION_WITH_DOT = (str(sys.version_info.major) + "."
        + str(sys.version_info.minor))

VERSION = None

# cefpython/cef3/linux/installer
INSTALLER = os.path.dirname(os.path.abspath(__file__))

# installer/cefpython3-31.0-linux-64bit-setup/
DISTUTILS_SETUP = None

# deb_dist/
DEB_DIST = None

# deb_dist/cefpython3-31.0/
DEB_DIST_PACKAGE = None

# deb_dist/cefpython3-31.0/debian/
DEBIAN = None

# deb_dist/cefpython3-31.0/debian/python-cefpython3/
DEBIAN_PACKAGE = None

# -----------------------------------------------------------------------------

def log(msg):
    print("[make-deb.py] %s" % msg)

def replace_in_file(f_path, s_what, s_with):
    contents = ""
    with open(f_path, "r") as f:
        contents = f.read()
    assert contents, ("Failed reading file: %s" % f_path)
    contents = contents.replace(s_what, s_with)
    with open(f_path, "w") as f:
        f.write(contents)

def remove_directories_from_previous_run():
    if os.path.exists(DISTUTILS_SETUP):
        log("The Distutils setup directory already exists, removing..")
        shutil.rmtree(DISTUTILS_SETUP)

    if os.path.exists(INSTALLER+"/deb_dist/"):
        log("The deb_dist/ directory already exists, removing..")
        shutil.rmtree(INSTALLER+"/deb_dist/")

    if os.path.exists(INSTALLER+"/deb_archive/"):
        log("The deb_archive/ directory already exists, removing..")
        shutil.rmtree(INSTALLER+"/deb_archive/")

def create_distutils_setup_package():
    log("Creating Distutils setup package")
    subprocess.call("%s %s/make-setup.py -v %s" % \
            (sys.executable, INSTALLER, VERSION), shell=True)
    assert os.path.exists(DISTUTILS_SETUP),\
            "Distutils Setup directory not found"

def modify_control_file():
    log("Modyfing debian control file")
    control_file = DEBIAN+"/control"

    # Read contents
    with open(control_file, "r") as f:
        contents = f.read()

    # Set architecture to i386 or amd64
    contents = contents.replace("Architecture: all",
            "Architecture: %s" % ARCHITECTURE)

    # Extend the Package section, remove the two ending new lines
    contents = re.sub("[\r\n]+$", "", contents)
    contents += "\n"

    # Extend description
    description = DESCRIPTION_EXTENDED
    description = re.sub("[\r\n]+", "\n", description)
    description = re.sub("\n$", "", description)
    contents += "%s\n" % description

    # Other fields
    contents += "Version: %s-1\n" % VERSION
    contents += "Maintainer: %s\n" % MAINTAINER
    contents += "Homepage: %s\n" % HOMEPAGE

    # Control file should end with two new lines
    contents += "\n"
    with open(control_file, "w") as f:
        f.write(contents)

def create_copyright_file():
    # The license is "Unknown" when opening deb package in
    # Ubuntu Software Center. It's a known bug:
    # https://bugs.launchpad.net/ubuntu/+source/software-center/+bug/435183
    log("Creating debian copyright file")
    copyright = COPYRIGHT
    copyright = re.sub("[\r\n]", "\n", copyright)
    copyright += "\n"
    copyright += "License: BSD 3-clause\n"
    with open(INSTALLER+"/../../../LICENSE.txt", "r") as f:
        license = f.readlines()
    for line in license:
        if not len(re.sub("\s+", "", line)):
            copyright += " .\n"
        else:
            copyright += " "+line.rstrip()+"\n"
    copyright += "\n"
    with open(DEBIAN+"/copyright", "w") as f:
        f.write(copyright)

def copy_postinst_script():
    # When creating .postinst file in the debian directory,
    # it will overwrite the default postinst script created
    # by dh_pysupport, its contents are:
    # -----------------------------------------------------
    # if which update-python-modules >/dev/null 2>&1; then
    #     update-python-modules  python-cefpython3.public
    # fi
    # -----------------------------------------------------
    # The command above creates symlinks for libraries and
    # executables, so that they appear to be in one directory.
    # CEF executable requires that libcef.so and the subprocess
    # executable are in the same directory.
    # This solution does not to work correctly in CEF3 branch
    # 1650, so we will have to put .so libraries along with
    # other files in a real single directory.
    log("Copying .postinst script")
    shutil.copy(INSTALLER+"/debian.postinst",
            DEBIAN+"/python-%s.postinst" % (PACKAGE_NAME))

def create_debian_source_package():
    log("Creating Debian source package using stdeb")
    os.chdir(DISTUTILS_SETUP)
    shutil.copy("../stdeb.cfg.template", "stdeb.cfg")
    stdeb_cfg_add_deps("stdeb.cfg")
    subprocess.call("%s setup.py --command-packages=stdeb.command sdist_dsc"\
            % (sys.executable,), shell=True)

def stdeb_cfg_add_deps(stdeb_cfg):
    log("Adding deps to stdeb.cfg")
    with open(INSTALLER+"/deps.txt", "r") as f:
        deps = f.read()
    deps = deps.strip()
    deps = deps.splitlines()
    for i, dep in enumerate(deps):
        deps[i] = dep.strip()
    deps = ", ".join(deps)
    with open(stdeb_cfg, "a") as f:
        f.write("\nDepends: %s" % deps)

def deb_dist_cleanup():
    # Move the deb_dist/ directory and remove unnecessary files
    log("Preparing the deb_dist directory")
    os.system("mv %s %s"\
        % (DISTUTILS_SETUP+"/deb_dist", INSTALLER+"/deb_dist"))
    os.system("rm -rf %s" % DISTUTILS_SETUP)
    # Paths
    global DEB_DIST, DEB_DIST_PACKAGE, DEBIAN, DEBIAN_PACKAGE
    DEB_DIST = INSTALLER+"/deb_dist"
    DEB_DIST_PACKAGE = DEB_DIST+"/"+PACKAGE_NAME+"-"+VERSION
    DEBIAN = DEB_DIST_PACKAGE+"/debian"
    DEBIAN_PACKAGE = DEBIAN+"/python-"+PACKAGE_NAME
    # Remove unnecessary files
    os.chdir(DEB_DIST)
    os.system("rm *.gz")
    os.system("rm *.dsc")

def create_debian_binary_package():
    os.chdir(DEB_DIST_PACKAGE)
    # Will create .deb .dsc .gz in the upper directory DEB_DIST
    subprocess.call("dpkg-buildpackage -rfakeroot -uc -us", shell=True)

def modify_deb_archive():
    # CEF branch 1650 doesn't work when the .so files do not reside
    # in the same directory as the subprocess executable. The symlinks
    # created in /usr/lib/pymodules/ do not help. After launching
    # CEF and webpage being displayed, the CEF renderer process
    # crashes after a moment. The solution is to modify the deb
    # archive, move the /usr/lib/pyshared/.../*.so libraries to
    # the /usr/share/pyshared/.../ directory. Also some files with
    # hardcoded paths to /usr/lub/pyshared/ need to be modified
    # (eg. DEBIAN/md5sums, python-support/python-cefpython3.public).
    log("Modifying the deb archive")

    # Paths
    deb_archive_name = "python-%s_%s-1_%s.deb" \
            % (PACKAGE_NAME, VERSION, ARCHITECTURE)
    deb_archive_dir = INSTALLER+"/deb_archive"

    # Move the deb archive to the deb_archive/ directory
    log("Moving the deb archive")
    os.system("mkdir %s" % deb_archive_dir)
    os.system("mv %s %s" % (DEB_DIST+"/"+deb_archive_name,\
            deb_archive_dir+"/"+deb_archive_name))

    # Remove the deb_dist/ directory
    os.system("rm -rf %s" % DEB_DIST)

    # Extract the deb archive
    log("Extracting the deb archive")
    os.chdir(deb_archive_dir)
    # Extract the usr/ directory
    os.system("dpkg-deb -x %s ." % deb_archive_name)
    # Extract the DEBIAN/ directory
    os.system("dpkg-deb -e %s" % deb_archive_name)

    # Remove the deb archive that was extracted
    os.system("rm %s" % deb_archive_name)

    # Move the .so files from the ./usr/lib/pyshared/.../ directory
    # to the ./usr/share/pyshared/.../ directory. Also remove the
    # ./usr/lib/ directory.
    log("Moving the .so libraries")
    lib_pyshared = "./usr/lib/pyshared/%s/%s" \
            % (PYTHON_NAME, PACKAGE_NAME)
    share_pyshared = "./usr/share/pyshared/%s" % PACKAGE_NAME
    os.system("mv %s/*.so %s/" % (lib_pyshared, share_pyshared))
    os.system("rm -rf ./usr/lib/")

    # Modify also the paths in some text files.
    # The paths do not start with "/" on purpose. In the md5sums
    # file the paths are relative. In the python-cefpython3.public
    # file paths are absolute.
    log("Modifying paths in the text files")
    old_path = "usr/lib/pyshared/%s/%s/" % (PYTHON_NAME, PACKAGE_NAME)
    new_path = "usr/share/pyshared/%s/" % PACKAGE_NAME
    md5sums_file = "./DEBIAN/md5sums"
    cefpython3_public_file = "./usr/share/python-support/python-%s.public" \
            % PACKAGE_NAME
    old_md5sum = subprocess.check_output("md5sum %s | cut -c 1-32" \
            % cefpython3_public_file, shell=True).strip()
    # Modify paths in the text files
    replace_in_file(md5sums_file, old_path, new_path)
    replace_in_file(cefpython3_public_file, old_path, new_path)
    # Correct md5 sum for the python-cefpython3.public file
    new_md5sum = subprocess.check_output("md5sum %s | cut -c 1-32" \
            % cefpython3_public_file, shell=True).strip()
    replace_in_file(md5sums_file, old_md5sum, new_md5sum)

    # Create deb archive from the modified ./DEBIAN/ and
    # ./usr/ directories.
    log("Creating deb archive from the modified files")
    os.system("fakeroot dpkg-deb -b . ./%s" % deb_archive_name)

def main():
    # Command line options
    parser = argparse.ArgumentParser(usage="%(prog)s [options]")
    parser.add_argument("-v", "--version", help="cefpython version",
            required=True)
    args = parser.parse_args()
    assert re.search(r"^\d+\.\d+$", args.version), (
            "Invalid version string")

    # Version
    global VERSION
    VERSION = args.version

    # Paths
    global DISTUTILS_SETUP
    DISTUTILS_SETUP = INSTALLER+"/"+PACKAGE_NAME+"-"+args.version+"-"+\
            LINUX_BITS+"-setup"

    remove_directories_from_previous_run()
    create_distutils_setup_package()
    create_debian_source_package()
    deb_dist_cleanup()
    modify_control_file()
    create_copyright_file()
    copy_postinst_script()
    create_debian_binary_package()
    modify_deb_archive()

    log("DONE")

if __name__ == "__main__":
    main()
