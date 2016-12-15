# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_request_context_handler cimport CefRequestContextHandler

cdef extern from "include/cef_request_context.h":
    cdef cppclass CefRequestContext:
        @staticmethod
        CefRefPtr[CefRequestContext] GetGlobalContext()
        @staticmethod
        CefRefPtr[CefRequestContext] CreateContext(
                CefRefPtr[CefRequestContext] other,
                CefRefPtr[CefRequestContextHandler] handler)
