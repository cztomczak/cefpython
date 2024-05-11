# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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
from cef_values cimport CefDictionaryValue
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
        CefRefPtr[CefDictionaryValue],
        CefRefPtr[CefRequestContext]) nogil
