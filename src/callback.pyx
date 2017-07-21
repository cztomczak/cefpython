# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

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
