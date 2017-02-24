# Copyright (c) 2017 The CEF Python authors. All rights reserved.
# Licensed under BSD 3-clause license.

# NOTE: Template variables like {{VERSION}} are replaced with actual
#       values when make_installer.py tool generates this package
#       installer.

import os
import sys
import ctypes
import platform

__all__ = ["cefpython"]  # Disabled: "wx"
__version__ = "{{VERSION}}"
__author__ = "The CEF Python authors"

# If package was installed using PIP or setup.py then package
# dir is here:
#   /usr/local/lib/python2.7/dist-packages/cefpython3/

# If this is a debian package then package_dir returns:
#   /usr/lib/pymodules/python2.7/cefpython3
# The above path consists of symbolic links to the real directory:
#   /usr/share/pyshared/cefpython3

package_dir = os.path.dirname(os.path.abspath(__file__))

# This loads the libcef.so library for the subprocess executable.
os.environ["LD_LIBRARY_PATH"] = package_dir

# On Mac it works without setting library paths. Better not set it,
# as maybe user's app will set it itself.
# > os.environ["DYLD_LIBRARY_PATH"] = package_dir
# > os.environ["DYLD_FRAMEWORK_PATH"] = package_dir

# This env variable will be returned by cefpython.GetModuleDirectory().
os.environ["CEFPYTHON3_PATH"] = package_dir

# This loads the libcef library for the main python executable.
# This is required only on linux and Mac.
# The libffmpegsumo.so library does not need to be loaded here,
# it may cause issues to load it here in the browser process.
libcef = None
if platform.system() == "Darwin":
    cef_framework = "Chromium Embedded Framework.framework"
    libcef_name = "Chromium Embedded Framework"
    # Search for it in current directory or in ../Frameworks/ dir
    # in case this is user's app packaged for distribution.
    libcef1 = os.path.join(package_dir, cef_framework, libcef_name)
    libcef2 = os.path.join(package_dir, "..", "Frameworks", cef_framework,
                           libcef_name)
    if os.path.exists(libcef1):
        libcef = libcef1
    elif os.path.exists(libcef2):
        libcef = libcef2
    else:
        raise Exception("Can't find: " + cef_framework)
elif platform.system() == "Linux":
    libcef = os.path.join(package_dir, "libcef.so")
if libcef:
    ctypes.CDLL(libcef, ctypes.RTLD_GLOBAL)

# Load the cefpython module for proper Python version
if sys.version_info[:2] == (2, 8):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py27 as cefpython
elif sys.version_info[:2] == (3, 4):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py34 as cefpython
elif sys.version_info[:2] == (3, 5):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py35 as cefpython
elif sys.version_info[:2] == (3, 6):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py36 as cefpython
else:
    raise Exception("Python version not supported: " + sys.version)
