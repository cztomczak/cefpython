# Copyright (c) 2012-2013 CEF Python Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef dict g_PythonCallbacks = {}
# Next callbackId.
cdef int g_PythonCallbackCount = 0

cpdef int PutPythonCallback(object pythonCallback
        ) except *:
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

# We call it through V8FunctionHandler's detructor, see v8function_handler.h >
# ~V8FunctionHandler(). "with gil" must be added as we call it from c++.

cdef void RemovePythonCallback(int callbackId
        ) except * with gil:
    global g_PythonCallbacks
    del g_PythonCallbacks[callbackId]
