# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Imports are in a separate files so that we can "include" them easily
# in other pyx files, this is required for the PyCharm so that unresolved
# references and other errors are fixed.

import os
import sys
import win32con
import win32gui
import win32api
import cython
import traceback
import time
import types
import re

from libcpp cimport bool as cbool
from libcpp.map cimport map
from libcpp.vector cimport vector
from cython.operator cimport preincrement as preinc, dereference as deref # must be "as" otherwise not seen.
# from cython.operator cimport address as addr # Address of an c++ object?
from libc.stdlib cimport malloc, free
from libc.stdlib cimport atoi

# When pyx file cimports * from a pxd file and that cimports * from another pxd
# then these another names will be visible in pyx file.

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *", this
# is important to know in pxd files.

# <CefRefPtr[ClientHandler]?>new ClientHandler() # <...?> means to throw an error if the cast is not allowed

from windows cimport *
from cef_string cimport *
from cef_type_wrappers cimport *
from cef_task cimport *
from cef_win cimport *
from cef_ptr cimport *
from cef_app cimport *
from cef_browser cimport *
from cef_client cimport *
from clienthandler cimport *
from cef_frame cimport *
cimport cef_types # cannot cimport *, that would cause name conflicts with constants.
cimport cef_types_win # same as cef_types.
from cef_v8 cimport *
cimport cef_v8_static
from v8functionhandler cimport *
