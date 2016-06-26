# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_ptr cimport CefRefPtr
IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowInfo
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefWindowInfo
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport CefWindowInfo
# noinspection PyUnresolvedReferences
from cef_client cimport CefClient
from cef_types cimport CefBrowserSettings
# noinspection PyUnresolvedReferences
from cef_request_context cimport CefRequestContext
# noinspection PyUnresolvedReferences
from cef_browser cimport CefBrowser
from cef_string cimport CefString

# Specifying namespace allows to import a static method.
cdef extern from "include/cef_browser.h" namespace "CefBrowserHost":

    cdef CefRefPtr[CefBrowser] CreateBrowserSync(
        CefWindowInfo&,
        CefRefPtr[CefClient],
        CefString&,
        CefBrowserSettings&,
        CefRefPtr[CefRequestContext]) nogil
