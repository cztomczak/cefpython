# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

cdef public void V8FunctionHandler_Execute(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefString& cefFunctionName,
        CefRefPtr[CefListValue] cefFunctionArguments
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef py_string functionName
    cdef object function
    cdef list functionArguments
    cdef object returnValue
    cdef py_string jsErrorMessage
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "V8FunctionHandler_Execute")
        pyFrame = GetPyFrame(cefFrame)
        functionName = CefToPyString(cefFunctionName)
        Debug("V8FunctionHandler_Execute(): functionName=%s" % functionName)
        jsBindings = pyBrowser.GetJavascriptBindings()
        function = jsBindings.GetFunctionOrMethod(functionName)
        if not function:
            # The Renderer process already checks whether function
            # name is valid before calling V8FunctionHandler_Execute(),
            # but it is possible for the javascript bindings to change
            # during execution, so it's possible for the Browser/Renderer
            # bindings to be out of sync due to delay in process messaging.
            jsErrorMessage = "V8FunctionHandler_Execute() FAILED: " \
                    "python function not found: %s" % functionName
            Debug(jsErrorMessage)
            # Raise a javascript exception in that frame.
            pyFrame.ExecuteJavascript("throw '%s';" % jsErrorMessage)
            return
        functionArguments = CefListValueToPyList(cefBrowser, 
                cefFunctionArguments)
        returnValue = function(*functionArguments)
        if returnValue is not None:
            Debug("V8FunctionHandler_Execute() WARNING: function returned" \
                    "value, but returning values to javascript is not " \
                    "supported, functionName=%s" % functionName)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
