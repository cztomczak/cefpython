# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void LoadHandler_OnLoadingStateChange(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool isLoading,
        cpp_bool canGoBack,
        cpp_bool canGoForward
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnLoadingStateChange")
        if callback:
            callback(pyBrowser, isLoading, canGoBack, canGoForward)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadStart(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        clientCallback = pyBrowser.GetClientCallback("OnLoadStart")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadEnd(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        int httpStatusCode
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        clientCallback = pyBrowser.GetClientCallback("OnLoadEnd")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame, httpStatusCode)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadError(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        cef_types.cef_errorcode_t cefErrorCode,
        const CefString& cefErrorText,
        const CefString& cefFailedUrl
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef list errorTextOut
    cdef object clientCallback
    try:
        # If webpage loading or file download is aborted by user
        # the error code will be ERR_ABORTED. In such cases calls
        # to OnLoadError should be ignored and not handled by user
        # scripts. The wxpython example implements such behavior.
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        errorTextOut = [CefToPyString(cefErrorText)]
        clientCallback = pyBrowser.GetClientCallback("OnLoadError")
        if clientCallback:
            clientCallback(
                    pyBrowser, pyFrame, cefErrorCode, errorTextOut,
                    CefToPyString(cefFailedUrl))
            # Providing custom error messsage not yet supported in CEF 3.
            # | PyToCefString(errorTextOut[0], cefErrorText)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
