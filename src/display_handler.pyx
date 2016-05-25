# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void DisplayHandler_OnAddressChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        const CefString& cefUrl
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef py_string pyUrl
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyUrl = CefToPyString(cefUrl)
        callback = pyBrowser.GetClientCallback("OnAddressChange")
        if callback:
            callback(pyBrowser, pyFrame, pyUrl)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnTitleChange(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefTitle
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyTitle
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyTitle = CefToPyString(cefTitle)
        callback = pyBrowser.GetClientCallback("OnTitleChange")
        if callback:
            callback(pyBrowser, pyTitle)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DisplayHandler_OnTooltip(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefText
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyText
    cdef list pyTextOut
    cdef object callback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyText = CefToPyString(cefText)
        pyTextOut = [pyText]
        callback = pyBrowser.GetClientCallback("OnTooltip")
        if callback:
            returnValue = callback(pyBrowser, pyTextOut)
            # pyText and pyTextOut[0] are not the same strings!
            PyToCefString(pyTextOut[0], cefText)
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnStatusMessage(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefValue
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyValue
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyValue = CefToPyString(cefValue)
        callback = pyBrowser.GetClientCallback("OnStatusMessage")
        if callback:
            callback(pyBrowser, pyValue)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DisplayHandler_OnConsoleMessage(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefMessage,
        const CefString& cefSource,
        int line
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyMessage
    cdef py_string pySource
    cdef py_bool returnValue
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMessage = CefToPyString(cefMessage)
        pySource = CefToPyString(cefSource)
        callback = pyBrowser.GetClientCallback("OnConsoleMessage")
        if callback:
            returnValue = callback(pyBrowser, pyMessage, pySource, line)
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
