# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"
include "../frame.pyx"

cdef public void V8FunctionHandler_Execute(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& frameId,
        CefString& cefFuncName,
        CefRefPtr[CefListValue] cefFuncArgs
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef CefRefPtr[CefFrame] cefFrame
    cdef PyFrame pyFrame  # may be None
    cdef py_string funcName
    cdef object func
    cdef list funcArgs
    cdef object returnValue
    cdef py_string errorMessage
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "V8FunctionHandler_Execute")
        cefFrame = cefBrowser.get().GetFrameByName(frameId)
        if cefFrame.get():
            pyFrame = GetPyFrame(cefFrame)
        else:
            pyFrame = None
        funcName = CefToPyString(cefFuncName)
        Debug("V8FunctionHandler_Execute(): funcName=%s" % funcName)
        jsBindings = pyBrowser.GetJavascriptBindings()
        func = jsBindings.GetFunctionOrMethod(funcName)
        if not func:
            # The Renderer process already checks whether function
            # name is valid before calling V8FunctionHandler_Execute(),
            # but it is possible for the javascript bindings to change
            # during execution, so it's possible for the Browser/Renderer
            # bindings to be out of sync due to delay in process messaging.
            errorMessage = "V8FunctionHandler_Execute() FAILED: " \
                           "python function not found: %s" % funcName
            NonCriticalError(errorMessage)
            # Raise a javascript exception in that frame if it still exists
            if pyFrame:
                pyFrame.ExecuteJavascript("throw '%s';" % errorMessage)
            return
        funcArgs = CefListValueToPyList(cefBrowser, cefFuncArgs)
        func(*funcArgs)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
