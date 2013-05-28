# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import os
import sys
import cython
import platform
import traceback
import time
import types
import re
import copy
import inspect # used by JavascriptBindings.__SetObjectMethods()
import urlparse
import urllib
import json
import datetime

if sys.version_info.major == 2:
    from urllib import pathname2url as urllib_pathname2url
else:
    from urllib.request import pathname2url as urllib_pathname2url

from Cython.Shadow import void
from cpython.version cimport PY_MAJOR_VERSION
import weakref

# We should allow multiple string types: str, unicode, bytes.
# PyToCefString() can handle them all.
ctypedef object py_string

# You can't use "void" along with cpdef function returning None, it is planned to be
# added to Cython in the future, creating this virtual type temporarily. If you
# change it later to "void" then don't forget to add "except *".
ctypedef object py_void
ctypedef long WindowHandle

from cpython cimport bool as py_bool
from libcpp cimport bool as cpp_bool

from libcpp.map cimport map as cpp_map
from multimap cimport multimap as cpp_multimap
from libcpp.pair cimport pair as cpp_pair
from libcpp.vector cimport vector as cpp_vector

from libcpp.string cimport string as cpp_string
from wstring cimport wstring as cpp_wstring

from libc.string cimport strlen
from libc.string cimport memcpy

# preincrement and dereference must be "as" otherwise not seen.
from cython.operator cimport preincrement as preinc, dereference as deref

# from cython.operator cimport address as addr # Address of an c++ object?

from libc.stdlib cimport calloc, malloc, free
from libc.stdlib cimport atoi

# When pyx file cimports * from a pxd file and that pxd cimports * from another pxd
# then these names will be visible in pyx file.

# Circular imports are allowed in form "cimport ...", but won't work if you do
# "from ... cimport *", this is important to know in pxd files.

from libc.stdint cimport uint64_t
from libc.stdint cimport uintptr_t

cimport ctime

IF UNAME_SYSNAME == "Windows":
    from windows cimport *

from cpp_utils cimport *

from cef_string cimport *
cdef extern from *:
    ctypedef CefString ConstCefString "const CefString"

from cef_types_wrappers cimport *
from cef_task cimport *
from cef_runnable cimport *

from cef_platform cimport *

from cef_ptr cimport *
from cef_app cimport *
from cef_browser cimport *
cimport cef_browser_static
from cef_client cimport *
from client_handler cimport *
from cef_frame cimport *

# cannot cimport *, that would cause name conflicts with constants.
cimport cef_types
IF CEF_VERSION == 1:
    ctypedef cef_types.cef_paint_element_type_t PaintElementType

# cannot cimport *, name conflicts
IF UNAME_SYSNAME == "Windows":
    cimport cef_types_win
ELIF UNAME_SYSNAME == "Darwin":
    cimport cef_types_mac
ELIF UNAME_SYSNAME == "Linux":
    cimport cef_types_linux

IF CEF_VERSION == 1:
    from cef_v8 cimport *
    cimport cef_v8_static
    cimport cef_v8_stack_trace
    from v8function_handler cimport *
    from cef_request cimport *
    cimport cef_request_static
    from cef_web_urlrequest cimport *
    cimport cef_web_urlrequest_static
    from web_request_client cimport *
    from cef_stream cimport *
    cimport cef_stream_static
    from cef_response cimport *
    from cef_stream cimport *
    from cef_content_filter cimport *
    from content_filter_handler cimport *
    from cef_download_handler cimport *
    from cef_cookie cimport *
    cimport cef_cookie_static
    cimport cef_cookie_manager_namespace
    from cookie_visitor cimport *
    from cef_time cimport *
    from cef_render_handler cimport *
    from cef_drag cimport *
    from cef_drag_data cimport *

IF UNAME_SYSNAME == "Windows":
    IF CEF_VERSION == 1:
        from http_authentication cimport *
