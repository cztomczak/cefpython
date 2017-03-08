# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef PyWebPluginInfo CreatePyWebPluginInfo(
        CefRefPtr[CefWebPluginInfo] cefPlugin):
    cdef PyWebPluginInfo pyPlugin = PyWebPluginInfo()
    pyPlugin.cefPlugin = cefPlugin
    return pyPlugin

cdef class PyWebPluginInfo:
    cdef CefRefPtr[CefWebPluginInfo] cefPlugin

    cpdef py_string GetName(self):
        return CefToPyString(self.cefPlugin.get().GetName())

    cpdef py_string GetPath(self):
        return CefToPyString(self.cefPlugin.get().GetPath())

    cpdef py_string GetVersion(self):
        return CefToPyString(self.cefPlugin.get().GetVersion())

    cpdef py_string GetDescription(self):
        return CefToPyString(self.cefPlugin.get().GetDescription())
