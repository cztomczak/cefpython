# Copyright (c) 2016 CEF Python. See the Authors and License files.

include "../cefpython.pyx"
cimport cef_types
from cef_types cimport TID_UI

FOCUS_SOURCE_NAVIGATION = cef_types.FOCUS_SOURCE_NAVIGATION
FOCUS_SOURCE_SYSTEM = cef_types.FOCUS_SOURCE_SYSTEM


cdef public void FocusHandler_OnTakeFocus(
        CefRefPtr[CefBrowser] cef_browser,
        cpp_bool next_
        ) except * with gil:
    cdef PyBrowser browser
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        browser = GetPyBrowser(cef_browser)
        callback = browser.GetClientCallback("OnTakeFocus")
        if callback:
            callback(browser=browser, next=next_)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


cdef public cpp_bool FocusHandler_OnSetFocus(
        CefRefPtr[CefBrowser] cef_browser,
        cef_types.cef_focus_source_t source
        ) except * with gil:
    cdef PyBrowser browser
    cdef py_bool ret
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        browser = GetPyBrowser(cef_browser)
        callback = browser.GetClientCallback("OnSetFocus")
        if callback:
            ret = callback(browser=browser, source=source)
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


cdef public void FocusHandler_OnGotFocus(
        CefRefPtr[CefBrowser] cef_browser
        ) except * with gil:
    cdef PyBrowser browser
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        browser = GetPyBrowser(cef_browser)
        callback = browser.GetClientCallback("OnGotFocus")
        if callback:
            callback(browser=browser)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
