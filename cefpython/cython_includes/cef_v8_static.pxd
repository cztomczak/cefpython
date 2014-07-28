# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Value
from cef_string cimport CefString
from cef_v8 cimport CefV8Handler
from cef_v8 cimport CefV8Accessor
from cef_v8 cimport CefV8Context
from libcpp cimport bool as cpp_bool

# Importing static methods only in this file. This is in a separate file as we do not want
# these names to be imported into global namespace, you will be using them like this:
# > cimport cef_v8_static
# > cef_v8_static.CreateArray()

cdef extern from "include/cef_v8.h" namespace "CefV8Value":

    cdef CefRefPtr[CefV8Value] CreateArray(int length)
    cdef CefRefPtr[CefV8Value] CreateBool(cpp_bool value)
    cdef CefRefPtr[CefV8Value] CreateDouble(double value)
    cdef CefRefPtr[CefV8Value] CreateFunction(
        CefString& name,
        CefRefPtr[CefV8Handler] handler)
    cdef CefRefPtr[CefV8Value] CreateInt(int value)
    cdef CefRefPtr[CefV8Value] CreateNull()
    cdef CefRefPtr[CefV8Value] CreateObject(CefRefPtr[CefV8Accessor] accessor)
    cdef CefRefPtr[CefV8Value] CreateString(CefString& value)
    # cdef CefRefPtr[CefV8Value] CreateUndefined()

cdef extern from "include/cef_v8.h" namespace "CefV8Context":

    cdef CefRefPtr[CefV8Context] GetCurrentContext()

