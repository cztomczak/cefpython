# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef PyCallback CreatePyCallback(
        CefRefPtr[CefCallback] cefCallback):
    cdef PyCallback pyCallback = PyCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyCallback:
    cdef CefRefPtr[CefCallback] cefCallback
    
    cpdef py_void Continue(self):
        self.cefCallback.get().Continue()
    
    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()
