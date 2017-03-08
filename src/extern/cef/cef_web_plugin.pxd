# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString

# CEF 3 only.

cdef extern from "include/cef_web_plugin.h":
    cdef cppclass CefWebPluginInfo:
        CefString GetName()
        CefString GetPath()
        CefString GetVersion()
        CefString GetDescription()
