# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

"""
Create a Debian Package.

Required dependencies:
  sudo apt-get install python-support
  sudo apt-get install python-pip
  sudo pip install -U stdeb
"""

import subprocess
import os, sys
import platform
import argparse
import re
import shutil

BITS = platform.architecture()[0]
assert (BITS == "32bit" or BITS == "64bit")
PACKAGE_NAME = "cefpython3"
PYTHON_VERSION_WITH_DOT = (str(sys.version_info.major) + "."
        + str(sys.version_info.minor))

def replace_in_file(f_path, s_what, s_with):
    contents = ""
    with open(f_path, "r") as f:
        contents = f.read()
    assert contents, ("Failed reading file: %s" % f_path)
    contents = contents.replace(s_what, s_with)
    with open(f_path, "w") as f:
        f.write(contents)

def main():

    # Options
    parser = argparse.ArgumentParser(usage="%(prog)s [options]")
    parser.add_argument("-v", "--version", help="cefpython version",
            required=True)
    args = parser.parse_args()
    assert re.search(r"^\d+\.\d+$", args.version), (
            "Invalid version string")
    
    # Directories
    installer_dir = os.path.dirname(os.path.abspath(__file__))
    setup_dir = installer_dir+"/"+PACKAGE_NAME+"-"+args.version+"-linux-"+BITS+"-setup"
    
    # Call make-setup.py
    if os.path.exists(setup_dir):
        print("Setup directory already exists, removing..")
        shutil.rmtree(setup_dir)
    subprocess.call("%s %s/make-setup.py -v %s" % \
            (sys.executable, installer_dir, args.version), shell=True)
    assert os.path.exists(setup_dir), "Setup directory not found"
    
    # Create debian package
    os.chdir(setup_dir)
    shutil.copy("../stdeb.cfg.template", "stdeb.cfg")
    
    # Create debian source package
    subprocess.call("%s setup.py --command-packages=stdeb.command sdist_dsc"\
            % (sys.executable,), shell=True)
    
    # Set architecture
    if BITS == "32bit":
        architecture = "i386"
    elif BITS == "64bit":
        architecture = "amd64"
    control_file = setup_dir+"/deb_dist/"+PACKAGE_NAME+"-"+args.version+"/debian/control"
    replace_in_file(control_file, "Architecture: all", "Architecture: %s" % architecture)
    
    # Create debian binary package
    os.chdir("deb_dist/%s-%s/" % (PACKAGE_NAME, args.version))
    # When creating .postinst file in the debian directory,
    # it will overwrite the default postinst script created
    # by dh_pysupport, its contents are:
    # -----------------------------------------------------
    # if which update-python-modules >/dev/null 2>&1; then
    #     update-python-modules  python-cefpython3.public
    # fi
    # -----------------------------------------------------
    # This command creates symbolic links for both shared/ and lib/
    # files. This is critical as this makes all files appear in single
    # directory, so that subprocess executable which is in shared/
    # can see libcef.so which is in lib/.
    with open("debian/python-%s.postinst" % (PACKAGE_NAME), "w") as f:
        f.write("#! /bin/sh\n")
        f.write("set -e\n")
        f.write("chmod 755 /usr/share/pyshared/%s/cefclient\n"\
                % (PACKAGE_NAME,))
        f.write("chmod 755 /usr/share/pyshared/%s/subprocess\n"\
                % (PACKAGE_NAME,))
        f.write("update-python-modules python-cefpython3.public\n")
    subprocess.call("dpkg-buildpackage -rfakeroot -uc -us", shell=True)

    print("DONE")

if __name__ == "__main__":
    main()
