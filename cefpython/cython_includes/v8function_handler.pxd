# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport CefString
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Value
from cef_v8 cimport CefV8ValueList
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Context

cdef extern from "v8function_handler/v8function_handler.h":

    # DelPythonCallbac() type.
    ctypedef void (*RemovePythonCallback_type)(
            int callbackID
    )

    cdef cppclass CefV8Handler:
        pass

    # V8FunctionHandler class.
    cdef cppclass V8FunctionHandler(CefV8Handler):
        # V8FunctionHandler callbacks.
        void SetCallback_V8Execute(V8Execute_type)
        void SetCallback_RemovePythonCallback(RemovePythonCallback_type)
        # Context.
        void SetContext(CefRefPtr[CefV8Context])
        void SetPythonCallbackID(int callbackID)
        CefRefPtr[CefV8Context] GetContext()