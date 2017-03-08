# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser

cdef extern from "client_handler/request_context_handler.h":
    cdef cppclass RequestContextHandler:
        RequestContextHandler(CefRefPtr[CefBrowser] browser)
        void SetBrowser(CefRefPtr[CefBrowser] browser)
