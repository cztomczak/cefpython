# Copyright (c) 2015 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser

cdef extern from "client_handler/util_mac.h":
    void MacInitialize()
    void MacShutdown()
    void MacSetWindowTitle(CefRefPtr[CefBrowser] browser, char* title)
