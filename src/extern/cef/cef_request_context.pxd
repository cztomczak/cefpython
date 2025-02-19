# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_request_context_handler cimport CefRequestContextHandler
from cef_callback cimport CefCompletionCallback
from cef_cookie cimport CefCookieManager

cdef extern from "include/cef_request_context.h":
    cdef cppclass CefRequestContext:
        @staticmethod
        CefRefPtr[CefRequestContext] GetGlobalContext()
        @staticmethod
        CefRefPtr[CefRequestContext] CreateContext(
                CefRefPtr[CefRequestContext] other,
                CefRefPtr[CefRequestContextHandler] handler)
        CefRefPtr[CefCookieManager] GetCookieManager(
                CefRefPtr[CefCompletionCallback] callback)
