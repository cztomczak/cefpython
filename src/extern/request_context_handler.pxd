# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser

cdef extern from "client_handler/request_context_handler.h":
    cdef cppclass RequestContextHandler:
        RequestContextHandler(CefRefPtr[CefBrowser] browser)
        void SetBrowser(CefRefPtr[CefBrowser] browser)
