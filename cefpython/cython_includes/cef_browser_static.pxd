# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_ptr cimport CefRefPtr
IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefWindowInfo
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefWindowHandle, CefWindowInfo
from cef_client cimport CefClient
from cef_types_wrappers cimport CefBrowserSettings
from cef_request_context cimport CefRequestContext
from cef_browser cimport CefBrowser
from libcpp cimport bool as cpp_bool
from cef_string cimport CefString

IF CEF_VERSION == 1:

    # Specifying namespace allows to import a static method.
    cdef extern from "include/cef_browser.h" namespace "CefBrowser":

        cdef CefRefPtr[CefBrowser] CreateBrowserSync(
            CefWindowInfo&,
            CefRefPtr[CefClient],
            CefString&,
            CefBrowserSettings&) nogil

ELIF CEF_VERSION == 3:

    # Specifying namespace allows to import a static method.
    cdef extern from "include/cef_browser.h" namespace "CefBrowserHost":

        cdef CefRefPtr[CefBrowser] CreateBrowserSync(
            CefWindowInfo&,
            CefRefPtr[CefClient],
            CefString&,
            CefBrowserSettings&,
            CefRefPtr[CefRequestContext]) nogil