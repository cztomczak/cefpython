# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

STATUSTYPE_TEXT = cef_types.STATUSTYPE_TEXT
STATUSTYPE_MOUSEOVER_URL = cef_types.STATUSTYPE_MOUSEOVER_URL
STATUSTYPE_KEYBOARD_FOCUS_URL = cef_types.STATUSTYPE_KEYBOARD_FOCUS_URL

cdef public void DisplayHandler_OnAddressChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefString& cefURL
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef str pyUrl
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyUrl = CefToPyString(cefURL)
        callback = pyBrowser.GetClientCallback("OnAddressChange")
        if callback:
            callback(pyBrowser, pyFrame, pyUrl)
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DisplayHandler_OnConsoleMessage(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefMessage,
        CefString& cefSource,
        int line
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef str pyMessage
    cdef str pySource
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMessage = CefToPyString(cefMessage)
        pySource = CefToPyString(cefSource)
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
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
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
        cpp_bool canGoBack,
        cpp_bool canGoForward
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
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
    cdef str pyText
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyText = CefToPyString(cefText)
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
    cdef str pyTitle
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyTitle = CefToPyString(cefTitle)
        callback = pyBrowser.GetClientCallback("OnTitleChange")
        if callback:
            ret = bool(callback(pyBrowser, pyTitle))
            IF UNAME_SYSNAME == "Windows":
                if ret:
                    WindowUtils.SetTitle(pyBrowser, pyTitle)
                    WindowUtils.SetIcon(pyBrowser, icon="inherit")
            return
        else:
            IF UNAME_SYSNAME == "Windows":
                WindowUtils.SetTitle(pyBrowser, pyTitle)
                WindowUtils.SetIcon(pyBrowser, icon="inherit")
            return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DisplayHandler_OnTooltip(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefText
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list pyText
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyText = [CefToPyString(cefText)] # In/Out
        callback = pyBrowser.GetClientCallback("OnTooltip")
        if callback:
            ret = callback(pyBrowser, pyText)
            PyToCefString(pyText[0], cefText);
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
