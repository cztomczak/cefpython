# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef dict g_PythonCallbacks = {}
# Next callbackId.
cdef int g_PythonCallbackCount = 0

cpdef int PutPythonCallback(
        object pythonCallback
        ) except *:
    # Called from v8utils.pyx > PyToV8Value().
    global g_PythonCallbacks
    global g_PythonCallbackCount
    g_PythonCallbackCount += 1
    callbackId = g_PythonCallbackCount
    g_PythonCallbacks[callbackId] = pythonCallback
    return callbackId

cpdef object GetPythonCallback(int callbackId):
    global g_PythonCallbacks
    if callbackId not in g_PythonCallbacks:
        raise Exception("GetPythonCallback() failed: invalid callbackId: %s" % callbackId)
    return g_PythonCallbacks[callbackId]

cdef void RemovePythonCallback(
        int callbackId
        ) except * with gil:
    # Called from v8function_handler.h > ~V8FunctionHandler().
    # Added "with gil" as it's called from C++.
    global g_PythonCallbacks
    del g_PythonCallbacks[callbackId]
