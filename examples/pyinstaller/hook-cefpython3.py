"""
This is PyInstaller hook file for CEF Python. This file
helps pyinstaller find CEF Python dependencies that are
required to run final executable.

See PyInstaller docs for hooks:
https://pyinstaller.readthedocs.io/en/stable/hooks.html
"""

import glob
import os
import platform
import re
import sys
import PyInstaller
from PyInstaller.utils.hooks import is_module_satisfies
from PyInstaller import log as logging

# Constants
CEFPYTHON_MIN_VERSION = "57.0"
PYINSTALLER_MIN_VERSION = "3.2.1"

# Makes assumption that using "python.exe" and not "pyinstaller.exe"
# TODO: use this code to work cross-platform:
# > from PyInstaller.utils.hooks import get_package_paths
# > get_package_paths("cefpython3")
CEFPYTHON3_DIR = os.path.join(
    os.path.dirname(sys.executable),
    'Lib', 'site-packages', 'cefpython3')

if platform.system() == "Windows":
    CYTHON_MODULE_EXT = ".pyd"
else:
    CYTHON_MODULE_EXT = ".so"

# Globals
logger = logging.getLogger(__name__)


# Functions
def check_platforms():
    if platform.system() != "Windows":
        raise SystemExit("Error: Currently only Windows platform is "
                         " supported, see Issue #135.")


def check_pyinstaller_version():
    """Using is_module_satisfies() for pyinstaller fails when
    installed using 'pip install develop.zip' command
    (PyInstaller Issue #2802)."""
    # Example version string for dev version of pyinstaller:
    # > 3.3.dev0+g5dc9557c
    version = PyInstaller.__version__
    match = re.search(r"^\d+\.\d+", version)
    if not (match.group(0) >= PYINSTALLER_MIN_VERSION):
        raise SystemExit("Error: pyinstaller %s or higher is required"
                         % PYINSTALLER_MIN_VERSION)


def check_cefpython3_version():
    if not is_module_satisfies("cefpython3 >= %s" % CEFPYTHON_MIN_VERSION):
        raise SystemExit("Error: cefpython3 %s or higher is required"
                         % CEFPYTHON_MIN_VERSION)


def get_cefpython_modules():
    """Get all cefpython Cython modules in the cefpython3 package.
    It returns a list of names without file extension. Eg.
    'cefpython_py27'. """
    pyds = glob.glob(os.path.join(CEFPYTHON3_DIR,
                                  "cefpython_py*" + CYTHON_MODULE_EXT))
    assert len(pyds) > 1, "Missing cefpython3 Cython modules"
    modules = []
    for path in pyds:
        filename = os.path.basename(path)
        mod = filename.replace(CYTHON_MODULE_EXT, "")
        modules.append(mod)
    return modules


def get_excluded_cefpython_modules():
    """CEF Python package includes Cython modules for various Python
       versions. When using Python 2.7 pyinstaller should not
       bundle modules for eg. Python 3.6, otherwise it will
       cause to include Python 3 dll dependencies. Returns a list
       of fully qualified names eg. 'cefpython3.cefpython_py27'."""
    pyver = "".join(map(str, sys.version_info[:2]))
    pyver_string = "py%s" % pyver
    modules = get_cefpython_modules()
    excluded = []
    for mod in modules:
        if pyver_string in mod:
            continue
        excluded.append("cefpython3.%s" % mod)
        logger.info("Exclude cefpython3 module: %s" % excluded[-1])
    return excluded


def get_cefpython3_datas():
    """Returning all cefpython binaries as DATAS, because
    pyinstaller does strange things and fails if these are
    returned as BINARIES. It first updates manifest in .dll files:
    >> Updating manifest in chrome_elf.dll

    And then because of that it fails to load the library:
    >> hsrc = win32api.LoadLibraryEx(filename, 0, LOAD_LIBRARY_AS_DATAFILE)
    >> pywintypes.error: (5, 'LoadLibraryEx', 'Access is denied.')

    It is not required for pyinstaller to modify in any way
    CEF binaries or to look for its dependencies. CEF binaries
    does not have any external dependencies like MSVCR or similar.

    The .pak .dat and .bin files cannot be marked as BINARIES
    as pyinstaller would fail to find binary depdendencies on
    these files.

    DATAS are in format: tuple(full_path, dest_subdir).
    """
    ret = list()

    # Binaries, licenses and readmes in the cefpython3/ directory
    for filename in os.listdir(CEFPYTHON3_DIR):
        # Ignore Cython modules which are already handled by
        # pyinstaller automatically.
        if filename[:-4] in get_cefpython_modules():
            continue
        # CEF binaries and datas
        if filename[-4:] in [".exe", ".dll", ".so", ".pak", ".dat", ".bin",
                             ".txt"]\
                or filename in ["License", "subprocess"]:
            logger.info("Include cefpython3 data: %s" % filename)
            ret.append((os.path.join(CEFPYTHON3_DIR, filename),
                        ""))

    # The .pak files in cefpython3/locales/ directory
    locales_dir = os.path.join(CEFPYTHON3_DIR, "locales")
    assert os.path.exists(locales_dir), "locales/ dir not found in cefpython3"
    for filename in os.listdir(locales_dir):
        logger.info("Include cefpython3 data: %s/%s" % (
            os.path.basename(locales_dir), filename))
        ret.append((os.path.join(locales_dir, filename),
                    "locales"))
    return ret


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

# Checks
check_platforms()
check_pyinstaller_version()
check_cefpython3_version()

# Info
logger.info("CEF Python package directory: %s" % CEFPYTHON3_DIR)

# Hidden imports.
# PyInstaller has no way on detecting imports made by Cython
# modules, so all pure Python imports made in cefpython .pyx
# files need to be manually entered here.
# TODO: Write a tool script that would find such imports in
#       .pyx files automatically.
hiddenimports = [
    "base64",
    "codecs",
    "copy",
    "datetime",
    "inspect",
    "json",
    "os",
    "platform",
    "random",
    "re",
    "sys",
    "time",
    "traceback",
    "types",
    "urllib",
    "weakref",
]
if sys.version_info.major == 2:
    hiddenimports += [
        "urlparse",
    ]

# Excluded modules
excludedimports = get_excluded_cefpython_modules()

# Include binaries
binaries = []

# Include datas
datas = get_cefpython3_datas()

# Notify pyinstaller.spec code that this hook was executed
# and that it succeeded.
os.environ["PYINSTALLER_CEFPYTHON3_HOOK_SUCCEEDED"] = "1"
