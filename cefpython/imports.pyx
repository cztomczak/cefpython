# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
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
import urllib
import json
import datetime
import random

if sys.version_info.major == 2:
    import urlparse
else:
    from urllib import parse as urlparse

if sys.version_info.major == 2:
    from urllib import pathname2url as urllib_pathname2url
else:
    from urllib.request import pathname2url as urllib_pathname2url

from cpython.version cimport PY_MAJOR_VERSION
import weakref

# We should allow multiple string types: str, unicode, bytes.
# PyToCefString() can handle them all.
# Important:
#   If you set it to basestring, Cython will accept exactly(!)
#   str/unicode in Py2 and str in Py3. This won't work in Py3
#   as we might want to pass bytes as well. Also it will
#   reject string subtypes, so using it in publi API functions
#   would be a bad idea.
ctypedef object py_string

# You can't use "void" along with cpdef function returning None, it is planned to be
# added to Cython in the future, creating this virtual type temporarily. If you
# change it later to "void" then don't forget to add "except *".
ctypedef object py_void
ctypedef long WindowHandle

from cpython cimport PyLong_FromVoidPtr

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
IF UNAME_SYSNAME == "Linux":
    from linux cimport *

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
ctypedef cef_types.cef_paint_element_type_t PaintElementType
ctypedef cef_types.cef_jsdialog_type_t JSDialogType
from cef_types cimport CefKeyEvent
from cef_types cimport CefMouseEvent
from cef_types cimport CefScreenInfo

# cannot cimport *, name conflicts
IF UNAME_SYSNAME == "Windows":
    cimport cef_types_win
ELIF UNAME_SYSNAME == "Darwin":
    cimport cef_types_mac
ELIF UNAME_SYSNAME == "Linux":
    cimport cef_types_linux

from cef_time cimport *
from cef_drag cimport *

IF CEF_VERSION == 1:
    from cef_v8 cimport *
    cimport cef_v8_static
    cimport cef_v8_stack_trace
    from v8function_handler cimport *
    from cef_request_cef1 cimport *
    from cef_web_urlrequest_cef1 cimport *
    cimport cef_web_urlrequest_static_cef1
    from web_request_client_cef1 cimport *
    from cef_stream cimport *
    cimport cef_stream_static
    from cef_response_cef1 cimport *
    from cef_stream cimport *
    from cef_content_filter cimport *
    from content_filter_handler cimport *
    from cef_download_handler cimport *
    from download_handler cimport *
    from cef_cookie_cef1 cimport *
    cimport cef_cookie_manager_namespace
    from cookie_visitor cimport *
    from cef_render_handler cimport *
    from cef_drag_data cimport *

IF UNAME_SYSNAME == "Windows":
    IF CEF_VERSION == 1:
        from http_authentication cimport *

IF CEF_VERSION == 3:
    from cef_values cimport *
    from cefpython_app cimport *
    from cef_process_message cimport *
    from cef_web_plugin_cef3 cimport *
    from cef_request_handler_cef3 cimport *
    from cef_request_cef3 cimport *
    from cef_cookie_cef3 cimport *
    from cef_string_visitor cimport *
    cimport cef_cookie_manager_namespace
    from cookie_visitor cimport *
    from string_visitor cimport *
    from cef_callback_cef3 cimport *
    from cef_response_cef3 cimport *
    from cef_resource_handler_cef3 cimport *
    from resource_handler_cef3 cimport *
    from cef_urlrequest_cef3 cimport *
    from web_request_client_cef3 cimport *
    from cef_command_line cimport *
    from cef_request_context cimport *
    from cef_request_context_handler cimport *
    from request_context_handler cimport *
    from cef_jsdialog_handler cimport *