# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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
