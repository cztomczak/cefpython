# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Create a Windows package installer.

import sys
import os
import platform
import argparse
import re
import struct
import sysconfig

BITS = str(8 * struct.calcsize('P')) + 'bit'
assert (BITS == "32bit" or BITS == "64bit")

ISCC = r"c:\Program Files (x86)\Inno Setup 5\ISCC.exe"
if "INNO5" in os.environ:
    ISCC = os.environ["INNO5"]

TEMPLATE_FILE = os.getcwd()+r"\innosetup.template"
ISS_FILE = os.getcwd()+r"\innosetup.generated"

def main():
    parser = argparse.ArgumentParser(usage="%(prog)s [options]")
    parser.add_argument("-v", "--version", help="cefpython version",
            required=True)
    args = parser.parse_args()
    assert re.search(r"^\d+\.\d+$", args.version), "Invalid version string"

    vars = {}
    vars["PACKAGE_NAME"] = "cefpython3"
    vars["APP_VERSION"] = args.version
    vars["PYTHON_VERSION"] = (str(sys.version_info.major) + "."
            + str(sys.version_info.minor))
    vars["PYTHON_VERSION_NODOT"] = (str(sys.version_info.major) + ""
            + str(sys.version_info.minor))
    vars["PYTHON_ARCHITECTURE"] = platform.architecture()[0]
    vars["BINARIES_DIR"] = os.path.realpath(
        os.getcwd() + r"\..\binaries_%s" % BITS)
    vars["PYD_FILE"] = (vars["BINARIES_DIR"]+r"\cefpython_py"
            + str(sys.version_info.major) + str(sys.version_info.minor)
            + ".pyd")
    vars["INSTALLER_DIR"] = os.getcwd()
    vars["WX_SUBPACKAGE_DIR"] = os.path.realpath(os.getcwd()+r"\..\.."
            "\wx-subpackage")
    vars["PLATFORM"] = sysconfig.get_platform()

    if BITS == "32bit":
        # We must keep compatibility, 32bit installers didn't contain
        # architecture information in AppName. So make it an empty string.
        vars["APP_NAME_BITS"] = ""
        vars["HKEY_CURRENT_USER"] = "HKEY_CURRENT_USER"
        vars["HKEY_LOCAL_MACHINE"] = "HKEY_LOCAL_MACHINE"
    elif BITS == "64bit":
        vars["APP_NAME_BITS"] = "64bit"
        # Inno setup installer is a 32bit application. To query 64bit
        # registry from within 32bit application you need to add _64
        # postfix.
        vars["HKEY_CURRENT_USER"] = "HKEY_CURRENT_USER_64"
        vars["HKEY_LOCAL_MACHINE"] = "HKEY_LOCAL_MACHINE_64"

    print("Reading template: %s" % TEMPLATE_FILE)

    f = open(TEMPLATE_FILE)
    template = f.read()
    f.close()

    f = open(ISS_FILE, "w")
    f.write(template % vars)
    f.close()

    print("Saved: %s" % ISS_FILE)

    initPyTemplate = os.getcwd()+r"\__init__.py.template"
    initPyInstall = os.getcwd()+r"\__init__.py.generated"

    f = open(initPyTemplate)
    initPyTemplateCode = f.read()
    f.close()

    f = open(initPyInstall, "w")
    f.write(initPyTemplateCode % vars)
    f.close()
    print("Saved: %s" % initPyInstall)

    iscc_command = '"'+ ISCC + '" ' + ISS_FILE
    print("Running ISCC: %s" % iscc_command)
    exit_code = os.system(iscc_command)
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
