# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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
    # Empty place-holders: popupFeatures, windowInfo, client, browserSettings.
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame,
    cdef py_string pyTargetUrl
    cdef py_string pyTargetFrameName
    cdef list pyNoJavascriptAccess # out bool pyNoJavascriptAccess[0]
    cdef object callback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyTargetUrl = CefToPyString(targetUrl)
        pyTargetFrameName = CefToPyString(targetFrameName)
        pyNoJavascriptAccess = [noJavascriptAccess[0]]
        callback = pyBrowser.GetClientCallback("OnBeforePopup")
        if callback:
            returnValue = bool(callback(pyBrowser, pyFrame, pyTargetUrl,
                    pyTargetFrameName, None, None, None, None, 
                    pyNoJavascriptAccess))
            noJavascriptAccess[0] = <cpp_bool>bool(pyNoJavascriptAccess[0])
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
