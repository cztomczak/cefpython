# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

STATUSTYPE_TEXT = <int>cef_types.STATUSTYPE_TEXT
STATUSTYPE_MOUSEOVER_URL = <int>cef_types.STATUSTYPE_MOUSEOVER_URL
STATUSTYPE_KEYBOARD_FOCUS_URL = <int>cef_types.STATUSTYPE_KEYBOARD_FOCUS_URL

cdef public void DisplayHandler_OnAddressChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefString& cefURL
        ) except * with gil:

    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnAddressChange() failed: pyBrowser is %s" % pyBrowser)
            return
        pyFrame = GetPyFrame(cefFrame)
        pyURL = ToPyString(cefURL)
        callback = pyBrowser.GetClientCallback("OnAddressChange")
        if callback:
            callback(pyBrowser, pyFrame, pyURL)
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool DisplayHandler_OnConsoleMessage(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefMessage,
        CefString& cefSource,
        int line
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnConsoleMessage() failed: pyBrowser is %s" % pyBrowser)
            return False
        pyMessage = ToPyString(cefMessage)
        pySource = ToPyString(cefSource)
        callback = pyBrowser.GetClientCallback("OnConsoleMessage")
        if callback:
            return bool(callback(pyBrowser, pyMessage, pySource, line))
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnContentsSizeChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        int width,
        int height
        ) except * with gil:

    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnContentsSizeChange() failed: pyBrowser is %s" % pyBrowser)
            return
        pyFrame = GetPyFrame(cefFrame)
        callback = pyBrowser.GetClientCallback("OnContentsSizeChange")
        if callback:
            callback(pyBrowser, pyFrame, width, height)
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnNavStateChange(
        CefRefPtr[CefBrowser] cefBrowser,
        c_bool canGoBack,
        c_bool canGoForward
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnNavStateChange() failed: pyBrowser is %s" % pyBrowser)
            return
        callback = pyBrowser.GetClientCallback("OnNavStateChange")
        if callback:
            callback(pyBrowser, canGoBack, canGoForward)
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnStatusMessage(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefText,
        cef_types.cef_handler_statustype_t statusType
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnStatusMessage() failed: pyBrowser is %s" % pyBrowser)
            return
        pyText = ToPyString(cefText)
        callback = pyBrowser.GetClientCallback("OnStatusMessage")
        if callback:
            callback(pyBrowser, pyText, statusType)
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnTitleChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefTitle
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnTitleChange() failed: pyBrowser is %s" % pyBrowser)
            return
        pyTitle = ToPyString(cefTitle)
        callback = pyBrowser.GetClientCallback("OnTitleChange")
        if callback:
            ret = bool(callback(pyBrowser, pyTitle))
            IF UNAME_SYSNAME == "Windows":
                if ret:
                    WindowUtils.SetTitle(pyBrowser, pyTitle)
                    WindowUtils.SetIcon(pyBrowser, "inherit")
            return
        else:
            IF UNAME_SYSNAME == "Windows":
                WindowUtils.SetTitle(pyBrowser, pyTitle)
                WindowUtils.SetIcon(pyBrowser, "inherit")
            return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool DisplayHandler_OnTooltip(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefText
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("DisplayHandler_OnTooltip() failed: pyBrowser is %s" % pyBrowser)
            return False
        pyText = [ToPyString(cefText)] # In/Out
        callback = pyBrowser.GetClientCallback("OnTooltip")
        if callback:
            ret = callback(pyBrowser, pyText)
            ToCefString(pyText[0], cefText);
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

