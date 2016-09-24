# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "../cefpython.pyx"

# noinspection PyUnresolvedReferences
from cef_types cimport WindowOpenDisposition
# noinspection PyUnresolvedReferences
cimport cef_types

# WindowOpenDisposition
WOD_UNKNOWN = cef_types.WOD_UNKNOWN
WOD_SUPPRESS_OPEN = cef_types.WOD_SUPPRESS_OPEN
WOD_CURRENT_TAB = cef_types.WOD_CURRENT_TAB
WOD_SINGLETON_TAB = cef_types.WOD_SINGLETON_TAB
WOD_NEW_FOREGROUND_TAB = cef_types.WOD_NEW_FOREGROUND_TAB
WOD_NEW_BACKGROUND_TAB = cef_types.WOD_NEW_BACKGROUND_TAB
WOD_NEW_POPUP = cef_types.WOD_NEW_POPUP
WOD_NEW_WINDOW = cef_types.WOD_NEW_WINDOW
WOD_SAVE_TO_DISK = cef_types.WOD_SAVE_TO_DISK
WOD_OFF_THE_RECORD = cef_types.WOD_OFF_THE_RECORD
WOD_IGNORE_ACTION = cef_types.WOD_IGNORE_ACTION


cdef public cpp_bool LifespanHandler_OnBeforePopup(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        const CefString& targetUrl,
        const CefString& targetFrameName,
        cef_types.cef_window_open_disposition_t targetDisposition,
        cpp_bool userGesture,
        const int popupFeaturesNotImpl,
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
                    pyTargetFrameName, targetDisposition, userGesture, None,
                    pyWindowInfo, None, pyBrowserSettings,
                    pyNoJavascriptAccess))
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
