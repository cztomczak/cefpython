# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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
# On Mac it works without setting library paths.
os.environ["LD_LIBRARY_PATH"] = package_dir

# This env variable will be returned by cefpython.GetModuleDirectory().
os.environ["CEFPYTHON3_PATH"] = package_dir

# This loads the libcef library for the main python executable.
# Loading library dynamically using ctypes.CDLL is required on Linux.
# TODO: Check if on Linux libcef.so can be linked like on Mac.
# On Mac the CEF framework dependency information is added to
# the cefpython*.so module by linking to CEF framework.
# The libffmpegsumo.so library does not need to be loaded here,
# it may cause issues to load it here in the browser process.
if platform.system() == "Linux":
    libcef = os.path.join(package_dir, "libcef.so")
    ctypes.CDLL(libcef, ctypes.RTLD_GLOBAL)

# Load the cefpython module for given Python version
if sys.version_info[:2] == (2, 7):
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
elif sys.version_info[:2] == (3, 7):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py37 as cefpython
elif sys.version_info[:2] == (3, 8):
    # noinspection PyUnresolvedReferences
    from . import cefpython_py38 as cefpython
else:
    raise Exception("Python version not supported: " + sys.version)
