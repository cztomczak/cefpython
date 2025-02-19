# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"
include "../frame.pyx"
include "../process_message_utils.pyx"

cdef public cpp_bool CookieAccessFilter_CanSendCookie(
            CefRefPtr[CefBrowser] cef_browser,
            CefRefPtr[CefFrame] cef_frame,
            CefRefPtr[CefRequest] cef_request,
            const CefCookie& cef_cookie
            ) except * with gil:
    cdef PyBrowser browser
    cdef PyFrame frame
    cdef PyRequest request
    cdef PyCookie cookie
    cdef object callback
    cdef py_bool retval
    try:
        Debug("CookieAccessFilter_CanSendCookie")
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cef_browser):
            return False

        browser = GetPyBrowser(cef_browser, "CanSendCookie")
        frame = GetPyFrame(cef_frame)
        request = CreatePyRequest(cef_request)
        cookie = CreatePyCookie(cef_cookie)
        callback = browser.GetClientCallback("CanSendCookie")
        if callback:
            retval = callback(
                    browser=browser,
                    frame=frame,
                    request=request,
                    cookie=cookie)
            return bool(retval)
        else:
            # Return True by default
            return True
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool CookieAccessFilter_CanSaveCookie(
            CefRefPtr[CefBrowser] cef_browser,
            CefRefPtr[CefFrame] cef_frame,
            CefRefPtr[CefRequest] cef_request,
            CefRefPtr[CefResponse] cef_response,
            const CefCookie& cef_cookie
            ) except * with gil:
    cdef PyBrowser browser
    cdef PyFrame frame
    cdef PyRequest request
    cdef PyResponse response
    cdef PyCookie cookie
    cdef object callback
    cdef py_bool retval
    try:
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cef_browser):
            return False

        browser = GetPyBrowser(cef_browser, "CanSaveCookie")
        frame = GetPyFrame(cef_frame)
        request = CreatePyRequest(cef_request)
        response = CreatePyResponse(cef_response)
        cookie = CreatePyCookie(cef_cookie)
        callback = browser.GetClientCallback("CanSaveCookie")
        if callback:
            retval = callback(
                    browser=browser,
                    frame=frame,
                    request=request,
                    response=response,
                    cookie=cookie)
            return bool(retval)
        else:
            # Return True by default
            return True
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
