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
            ) noexcept with gil:
    cdef PyBrowser browser
    cdef PyFrame frame
    cdef PyRequest request
    cdef PyCookie cookie
    cdef object callback
    cdef py_bool retval
    try:
        # CEF documents browser/frame as optional
        # (cef_resource_request_handler.h). Without them, allow the cookie, as
        # CEF does by default; see api/RequestHandler.md.
        if not cef_browser.get() or not cef_frame.get():
            Debug("CanSendCookie: no browser/frame for the request;"
                  " allowing by default")
            return True
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cef_browser):
            return False

        browser = GetPyBrowser(cef_browser, "CanSendCookie")
        frame = GetPyFrame(cef_browser, cef_frame)
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
            ) noexcept with gil:
    cdef PyBrowser browser
    cdef PyFrame frame
    cdef PyRequest request
    cdef PyResponse response
    cdef PyCookie cookie
    cdef object callback
    cdef py_bool retval
    try:
        # See CanSendCookie above.
        if not cef_browser.get() or not cef_frame.get():
            Debug("CanSaveCookie: no browser/frame for the request;"
                  " allowing by default")
            return True
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cef_browser):
            return False

        browser = GetPyBrowser(cef_browser, "CanSaveCookie")
        frame = GetPyFrame(cef_browser, cef_frame)
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
