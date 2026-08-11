# Copyright (c) 2015 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser
from libcpp.string cimport string as cpp_string

cdef extern from "client_handler/util_mac.h":
    void MacInitialize()
    void MacShutdown()
    cpp_string MacGetMainBundlePath()
    void MacSetWindowTitle(CefRefPtr[CefBrowser] browser, char* title)
