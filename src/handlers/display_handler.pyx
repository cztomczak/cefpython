# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

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
        pyBrowser = GetPyBrowser(cefBrowser, "OnAddressChange")
        pyFrame = GetPyFrame(cefFrame)
        pyUrl = CefToPyString(cefUrl)
        callback = pyBrowser.GetClientCallback("OnAddressChange")
        if callback:
            callback(browser=pyBrowser, frame=pyFrame, url=pyUrl)
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnTitleChange")
        pyTitle = CefToPyString(cefTitle)
        callback = pyBrowser.GetClientCallback("OnTitleChange")
        if callback:
            callback(browser=pyBrowser, title=pyTitle)
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnTooltip")
        pyText = CefToPyString(cefText)
        pyTextOut = [pyText]
        callback = pyBrowser.GetClientCallback("OnTooltip")
        if callback:
            returnValue = callback(browser=pyBrowser, text_out=pyTextOut)
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnStatusMessage")
        pyValue = CefToPyString(cefValue)
        callback = pyBrowser.GetClientCallback("OnStatusMessage")
        if callback:
            callback(browser=pyBrowser, value=pyValue)
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnConsoleMessage")
        pyMessage = CefToPyString(cefMessage)
        pySource = CefToPyString(cefSource)
        callback = pyBrowser.GetClientCallback("OnConsoleMessage")
        if callback:
            returnValue = callback(browser=pyBrowser, message=pyMessage,
                                   source=pySource, line=line)
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
