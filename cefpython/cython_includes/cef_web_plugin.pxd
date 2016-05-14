# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport CefString

# CEF 3 only.

cdef extern from "include/cef_web_plugin.h":
    cdef cppclass CefWebPluginInfo:
        CefString GetName()
        CefString GetPath()
        CefString GetVersion()
        CefString GetDescription()
