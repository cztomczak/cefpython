# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# enum cef_jsdialog_type_t
JSDIALOGTYPE_ALERT = cef_types.JSDIALOGTYPE_ALERT
JSDIALOGTYPE_CONFIRM = cef_types.JSDIALOGTYPE_CONFIRM
JSDIALOGTYPE_PROMPT = cef_types.JSDIALOGTYPE_PROMPT

# -----------------------------------------------------------------------------
# PyJavascriptDialogCallback
# -----------------------------------------------------------------------------
cdef PyJavascriptDialogCallback CreatePyJavascriptDialogCallback(
        CefRefPtr[CefJSDialogCallback] cefCallback):
    cdef PyJavascriptDialogCallback pyCallback = PyJavascriptDialogCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyJavascriptDialogCallback:
    cdef CefRefPtr[CefJSDialogCallback] cefCallback

    cpdef py_void Continue(self, py_bool allow, py_string userInput):
        self.cefCallback.get().Continue(bool(allow),
                                        PyToCefStringValue(userInput))
# -----------------------------------------------------------------------------
# JavascriptDialogHandler
# -----------------------------------------------------------------------------

cdef public cpp_bool JavascriptDialogHandler_OnJavascriptDialog(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& origin_url,
        const CefString& accept_lang,
        cef_types.cef_jsdialog_type_t dialog_type,
        const CefString& message_text,
        const CefString& default_prompt_text,
        CefRefPtr[CefJSDialogCallback] callback,
        cpp_bool& suppress_message
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyOriginUrl
    cdef py_string pyAcceptLang
    cdef py_string pyMessageText
    cdef py_string pyDefaultPromptText
    cdef PyJavascriptDialogCallback pyCallback
    cdef list pySuppressMessage = []
    
    cdef object clientCallback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyOriginUrl = CefToPyString(origin_url)
        pyAcceptLang = CefToPyString(accept_lang)
        pyMessageText = CefToPyString(message_text)
        pyDefaultPromptText = CefToPyString(default_prompt_text)
        pyCallback = CreatePyJavascriptDialogCallback(callback)
        pySuppressMessage = [bool(suppress_message)]
        
        clientCallback = pyBrowser.GetClientCallback("OnJavascriptDialog")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyOriginUrl, pyAcceptLang,
                    dialog_type, pyMessageText, pyDefaultPromptText,
                    pyCallback, pySuppressMessage)
            (&suppress_message)[0] = <cpp_bool>bool(pySuppressMessage[0])
            return returnValue
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool JavascriptDialogHandler_OnBeforeUnloadJavascriptDialog(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& message_text,
        cpp_bool is_reload,
        CefRefPtr[CefJSDialogCallback] callback
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyMessageText
    cdef py_bool pyIsReload
    cdef PyJavascriptDialogCallback pyCallback

    cdef object clientCallback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMessageText = CefToPyString(message_text)
        pyIsReload = bool(is_reload)
        pyCallback = CreatePyJavascriptDialogCallback(callback)

        clientCallback = pyBrowser.GetClientCallback(\
                "OnBeforeUnloadJavascriptDialog")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyMessageText, pyIsReload,\
                    pyCallback)
            return returnValue
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void JavascriptDialogHandler_OnResetJavascriptDialogState(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback(\
                "OnResetJavascriptDialogState")
        if callback:
            callback(pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void JavascriptDialogHandler_OnJavascriptDialogClosed(
        CefRefPtr[CefBrowser] cefBrowser,
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnJavascriptDialogClosed")
        if callback:
            callback(pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

