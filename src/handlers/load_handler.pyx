# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

cdef public void LoadHandler_OnLoadingStateChange(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool isLoading,
        cpp_bool canGoBack,
        cpp_bool canGoForward
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnLoadingStateChange")
        callback = pyBrowser.GetClientCallback("OnLoadingStateChange")
        if callback:
            callback(browser=pyBrowser,
                     is_loading=isLoading,
                     can_go_back=canGoBack,
                     can_go_forward=canGoForward)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadStart(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        # A frame torn down mid-navigation (rapid create -> navigate -> destroy)
        # can already be detached by the time this UI-thread callback runs, in
        # which case CefFrame::GetBrowser() returns NULL. There is then no
        # browser to resolve a PyBrowser/PyFrame from and the load event refers
        # to a frame that no longer exists, so skipping is correct.
        if not cefFrame.get().GetBrowser().get():
            Debug("OnLoadStart: frame has no browser (detached during"
                  " lifecycle transition), skipping")
            return
        pyBrowser = GetPyBrowser(cefBrowser, "OnLoadStart")
        pyFrame = GetPyFrame(cefFrame)
        clientCallback = pyBrowser.GetClientCallback("OnLoadStart")
        if clientCallback:
            clientCallback(browser=pyBrowser, frame=pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadEnd(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        int httpStatusCode
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        # See OnLoadStart: a detached frame yields a NULL CefFrame::GetBrowser()
        # on the UI thread; nothing to dispatch on, so skip.
        if not cefFrame.get().GetBrowser().get():
            Debug("OnLoadEnd: frame has no browser (detached during"
                  " lifecycle transition), skipping")
            return
        pyBrowser = GetPyBrowser(cefBrowser, "OnLoadEnd")
        pyFrame = GetPyFrame(cefFrame)
        clientCallback = pyBrowser.GetClientCallback("OnLoadEnd")
        if clientCallback:
            clientCallback(browser=pyBrowser,
                           frame=pyFrame,
                           http_code=httpStatusCode)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadError(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        cef_types.cef_errorcode_t cefErrorCode,
        const CefString& cefErrorText,
        const CefString& cefFailedUrl
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef list errorTextOut
    cdef object clientCallback
    try:
        # If webpage loading or file download is aborted by user
        # the error code will be ERR_ABORTED. In such cases calls
        # to OnLoadError should be ignored and not handled by user
        # scripts. The wxpython example implements such behavior.
        # See OnLoadStart: a detached frame yields a NULL CefFrame::GetBrowser()
        # on the UI thread; nothing to dispatch on, so skip.
        if not cefFrame.get().GetBrowser().get():
            Debug("OnLoadError: frame has no browser (detached during"
                  " lifecycle transition), skipping")
            return
        pyBrowser = GetPyBrowser(cefBrowser, "OnLoadError")
        pyFrame = GetPyFrame(cefFrame)
        errorTextOut = [CefToPyString(cefErrorText)]
        clientCallback = pyBrowser.GetClientCallback("OnLoadError")
        if clientCallback:
            clientCallback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    error_code=cefErrorCode,
                    error_text_out=errorTextOut,
                    failed_url=CefToPyString(cefFailedUrl))
            # Providing custom error messsage not yet supported in CEF 3.
            # | PyToCefString(errorTextOut[0], cefErrorText)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
