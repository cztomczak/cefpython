# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public cpp_bool LifespanHandler_OnBeforePopup(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        const CefString& targetUrl,
        const CefString& targetFrameName,
        const int popupFeatures,
        CefWindowInfo& windowInfo,
        CefRefPtr[CefClient]& client,
        CefBrowserSettings& settings,
        cpp_bool* noJavascriptAccess
        ) except * with gil:
    # Empty place-holders: popupFeatures, client.
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame,
    cdef py_string pyTargetUrl
    cdef py_string pyTargetFrameName
    cdef list pyNoJavascriptAccess # out bool pyNoJavascriptAccess[0]
    cdef list pyWindowInfo
    cdef list pyBrowserSettings
    cdef object callback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyTargetUrl = CefToPyString(targetUrl)
        pyTargetFrameName = CefToPyString(targetFrameName)
        pyNoJavascriptAccess = [noJavascriptAccess[0]]
        pyWindowInfo = []
        pyBrowserSettings = []
        callback = pyBrowser.GetClientCallback("OnBeforePopup")
        if callback:
            returnValue = bool(callback(pyBrowser, pyFrame, pyTargetUrl,
                    pyTargetFrameName, None, pyWindowInfo, None,
                    pyBrowserSettings, pyNoJavascriptAccess))
            noJavascriptAccess[0] = <cpp_bool>bool(pyNoJavascriptAccess[0])
            if len(pyBrowserSettings):
                SetBrowserSettings(pyBrowserSettings[0], &settings)
            if len(pyWindowInfo):
                SetCefWindowInfo(windowInfo, pyWindowInfo[0])
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LifespanHandler_OnAfterCreated(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = GetGlobalClientCallback("OnAfterCreated")
        if callback:
            callback(pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool LifespanHandler_RunModal(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("RunModal")
        if callback:
            return bool(callback(pyBrowser))
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool LifespanHandler_DoClose(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("DoClose")
        if callback:
            return bool(callback(pyBrowser))
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LifespanHandler_OnBeforeClose(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnBeforeClose")
        if callback:
            callback(pyBrowser)
        RemovePythonCallbacksForBrowser(pyBrowser.GetIdentifier())
        RemovePyFramesForBrowser(pyBrowser.GetIdentifier())
        RemovePyBrowser(pyBrowser.GetIdentifier())
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
