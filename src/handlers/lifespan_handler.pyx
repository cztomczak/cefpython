# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

# noinspection PyUnresolvedReferences
from cef_types cimport WindowOpenDisposition
# noinspection PyUnresolvedReferences
cimport cef_types

# WindowOpenDisposition
CEF_WOD_UNKNOWN = cef_types.CEF_WOD_UNKNOWN
CEF_WOD_CURRENT_TAB = cef_types.CEF_WOD_CURRENT_TAB
CEF_WOD_SINGLETON_TAB = cef_types.CEF_WOD_SINGLETON_TAB
CEF_WOD_NEW_FOREGROUND_TAB = cef_types.CEF_WOD_NEW_FOREGROUND_TAB
CEF_WOD_NEW_BACKGROUND_TAB = cef_types.CEF_WOD_NEW_BACKGROUND_TAB
CEF_WOD_NEW_POPUP = cef_types.CEF_WOD_NEW_POPUP
CEF_WOD_NEW_WINDOW = cef_types.CEF_WOD_NEW_WINDOW
CEF_WOD_SAVE_TO_DISK = cef_types.CEF_WOD_SAVE_TO_DISK
CEF_WOD_OFF_THE_RECORD = cef_types.CEF_WOD_OFF_THE_RECORD
CEF_WOD_IGNORE_ACTION = cef_types.CEF_WOD_IGNORE_ACTION


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
        CefRefPtr[CefDictionaryValue]& extra_info,
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnBeforePopup")
        pyFrame = GetPyFrame(cefFrame)
        pyTargetUrl = CefToPyString(targetUrl)
        pyTargetFrameName = CefToPyString(targetFrameName)
        pyNoJavascriptAccess = [noJavascriptAccess[0]]
        pyWindowInfo = []
        pyBrowserSettings = []
        callback = pyBrowser.GetClientCallback("OnBeforePopup")
        if callback:
            returnValue = bool(callback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    target_url=pyTargetUrl,
                    target_frame_name=pyTargetFrameName,
                    target_disposition=targetDisposition,
                    user_gesture=userGesture,
                    popup_features=None,
                    window_info_out=pyWindowInfo,
                    client=None,
                    browser_settings_out=pyBrowserSettings,
                    no_javascript_access_out=pyNoJavascriptAccess))
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
        pyBrowser = GetPyBrowser(cefBrowser, "OnAfterCreated")
        callback = GetGlobalClientCallback("OnAfterCreated")
        if callback:
            callback(browser=pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool LifespanHandler_DoClose(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "DoClose")
        callback = pyBrowser.GetClientCallback("DoClose")
        if callback:
            return bool(callback(browser=pyBrowser))
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LifespanHandler_OnBeforeClose(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef int browserId
    cdef object callback
    try:
        Debug("LifespanHandler_OnBeforeClose")
        # NOTE: browser_id may not necessarily be in g_pyBrowsers currently.
        #       I haven't yet debugged it but the logic in Shutdown that
        #       tries to force close browsers and removes references might
        #       have something to do with it. Such scenario is reproducible
        #       with the following steps:
        #       1. Run wxpython.py example
        #       2. Google "js alert" and open w3schools
        #       3. Open demo popup
        #       4. Close main window (not popup)
        pyBrowser = GetPyBrowser(cefBrowser, "OnBeforeClose")
        callback = pyBrowser.GetClientCallback("OnBeforeClose")
        if callback:
            callback(browser=pyBrowser)

        # Flush cookies to disk. Temporary solution for Issue #365.
        # A similar call is made in Browser.CloseBrowser. If using
        # GetCookieManager to implement custom cookie managers then
        # flushing of cookies would need to be handled manually.
        cefBrowser.get().GetHost().get().GetRequestContext().get() \
                .GetCookieManager(
                        <CefRefPtr[CefCompletionCallback]?>nullptr) \
                .get().FlushStore(<CefRefPtr[CefCompletionCallback]?>nullptr)

        browserId = pyBrowser.GetIdentifier()
        pyBrowser.cefBrowser.Assign(nullptr)
        cefBrowser.Assign(nullptr)
        del pyBrowser

        RemovePythonCallbacksForBrowser(browserId)
        RemovePyFramesForBrowser(browserId)
        RemovePyBrowser(browserId)

        if g_MessageLoop_called and not len(g_pyBrowsers):
            # Automatically quit message loop when last browser was closed.
            # This is required for hello_world.py example to work.
            PostTask(TID_UI, QuitMessageLoop)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
