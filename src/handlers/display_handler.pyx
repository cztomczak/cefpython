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


cdef public cpp_bool DisplayHandler_OnAutoResize(
        CefRefPtr[CefBrowser] cef_browser,
        const CefSize& new_size
        ) except * with gil:
    cdef PyBrowser browser
    cdef object callback
    try:
        browser = GetPyBrowser(cef_browser, "OnAutoResize")
        callback = browser.GetClientCallback("OnAutoResize")
        if callback:
            return bool(callback(browser=browser, new_size=[new_size.width,
                                                  new_size.height]))
        return False
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
        cef_log_severity_t level,
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
            returnValue = callback(browser=pyBrowser, level=level,
                                   message=pyMessage, source=pySource,
                                   line=line)
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnLoadingProgressChange(
        CefRefPtr[CefBrowser] cefBrowser,
        double progress
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnLoadingProgressChange")
        callback = pyBrowser.GetClientCallback("OnLoadingProgressChange")
        if callback:
            callback(browser=pyBrowser, progress=progress)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DisplayHandler_OnCursorChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefCursorHandle cursor
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnCursorChange")
        callback = pyBrowser.GetClientCallback("OnCursorChange")
        if callback:
            ret = callback(browser=pyBrowser, cursor=<uintptr_t>cursor)
            if ret:
                return True
            else:
                return False
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
