# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef int g_pythonCallbackMaxId = 0
# [callbackId] = (browserId, frameId, func)
cdef dict g_pythonCallbacks = {}

# TODO: send callbackId using CefBinaryNamedValue, see:
#       http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10881

cdef struct PythonCallback:
    int callbackId
    char uniqueCefBinaryValueSize[16]

cdef CefRefPtr[CefBinaryValue] PutPythonCallback(
        object browserId,
        object frameId, 
        object func
        ) except *:
    global g_pythonCallbacks
    global g_pythonCallbackMaxId
    if not browserId:
        raise Exception("PutPythonCallback() FAILED: browserId is empty")
    if not frameId:
        raise Exception("PutPythonCallback() FAILED: frameId is empty")
    cdef PythonCallback pyCallback
    g_pythonCallbackMaxId += 1
    pyCallback.callbackId = g_pythonCallbackMaxId
    cdef CefRefPtr[CefBinaryValue] binaryValue = CefBinaryValue_Create(
            &pyCallback, sizeof(pyCallback))
    g_pythonCallbacks[g_pythonCallbackMaxId] = (browserId, frameId, func)
    return binaryValue

cdef public void RemovePythonCallbacksForFrame(
        object frameId
        ) except * with gil:
    # Cannot remove elements from g_pythonCallbacks (dict) while iterating.
    cdef list toRemove = []
    try:
        global g_pythonCallbacks
        for callbackId, value in g_pythonCallbacks.iteritems():
            if value[1] == frameId:
                toRemove.append(callbackId)
        for callbackId in toRemove:
            del g_pythonCallbacks[callbackId]
            Debug("RemovePythonCallbacksForFrame(): " \
                  "removed python callback, callbackId = %s" \
                  % callbackId)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef void RemovePythonCallbacksForBrowser(
        int browserId) except *:
    cdef list toRemove = []
    global g_pythonCallbacks
    for callbackId, value in g_pythonCallbacks.iteritems():
        if value[0] == browserId:
            toRemove.append(callbackId)
    for callbackId in toRemove:
        del g_pythonCallbacks[callbackId]
        Debug("RemovePythonCallbacksForBrowser(): " \
              "removed python callback, callbackId = %s" \
              % callbackId)

cdef public cpp_bool ExecutePythonCallback(
        CefRefPtr[CefBrowser] cefBrowser,
        int callbackId, 
        CefRefPtr[CefListValue] cefFuncArgs,
        ) except * with gil:
    cdef object func
    cdef list funcArgs
    cdef object returnValue
    try:
        global g_pythonCallbacks
        if callbackId in g_pythonCallbacks:
            func = g_pythonCallbacks[callbackId][2]
            funcArgs = CefListValueToPyList(
                    cefBrowser, cefFuncArgs)
            func(*funcArgs)
            return True
        else:
            Debug("ExecutePythonCallback() FAILED: callback not found, " \
                  "callbackId = %s" % callbackId)
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
