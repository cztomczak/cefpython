# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

# enum cef_jsdialog_type_t
cimport cef_types
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

    cpdef py_void Continue(self, py_bool allow, py_string user_input):
        self.cefCallback.get().Continue(bool(allow),
                                        PyToCefStringValue(user_input))
# -----------------------------------------------------------------------------
# JavascriptDialogHandler
# -----------------------------------------------------------------------------

cdef public cpp_bool JavascriptDialogHandler_OnJavascriptDialog(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& origin_url,
        cef_types.cef_jsdialog_type_t dialog_type,
        const CefString& message_text,
        const CefString& default_prompt_text,
        CefRefPtr[CefJSDialogCallback] callback,
        cpp_bool& suppress_message
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyOriginUrl
    cdef py_string pyMessageText
    cdef py_string pyDefaultPromptText
    cdef PyJavascriptDialogCallback pyCallback
    cdef list pySuppressMessage = []
    
    cdef object clientCallback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnJavascriptDialog")
        pyOriginUrl = CefToPyString(origin_url)
        pyMessageText = CefToPyString(message_text)
        pyDefaultPromptText = CefToPyString(default_prompt_text)
        pyCallback = CreatePyJavascriptDialogCallback(callback)
        pySuppressMessage = [bool(suppress_message)]
        
        clientCallback = pyBrowser.GetClientCallback("OnJavascriptDialog")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    origin_url=pyOriginUrl,
                    dialog_type=dialog_type,
                    message_text=pyMessageText,
                    default_prompt_text=pyDefaultPromptText,
                    callback=pyCallback,
                    suppress_message_out=pySuppressMessage)
            (&suppress_message)[0] = bool(pySuppressMessage[0])
            return bool(returnValue)
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
        pyBrowser = GetPyBrowser(cefBrowser,
                                         "OnBeforeUnloadJavascriptDialog")
        pyMessageText = CefToPyString(message_text)
        pyIsReload = bool(is_reload)
        pyCallback = CreatePyJavascriptDialogCallback(callback)

        clientCallback = pyBrowser.GetClientCallback(
                "OnBeforeUnloadJavascriptDialog")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    message_text=pyMessageText,
                    is_reload=pyIsReload,
                    callback=pyCallback)
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void JavascriptDialogHandler_OnResetJavascriptDialogState(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser,
                                         "OnResetJavascriptDialogState")
        callback = pyBrowser.GetClientCallback(
                "OnResetJavascriptDialogState")
        if callback:
            callback(browser=pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void JavascriptDialogHandler_OnJavascriptDialogClosed(
        CefRefPtr[CefBrowser] cefBrowser,
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser,
                                         "OnJavascriptDialogClosed")
        callback = pyBrowser.GetClientCallback("OnJavascriptDialogClosed")
        if callback:
            callback(browser=pyBrowser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

