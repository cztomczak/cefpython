# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void LoadHandler_OnLoadEnd(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        int httpStatusCode
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        callback = pyBrowser.GetClientCallback("OnLoadEnd")
        if callback:
            callback(pyBrowser, pyFrame, httpStatusCode)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnLoadStart(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        callback = pyBrowser.GetClientCallback("OnLoadStart")
        if callback:
            callback(pyBrowser, pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool LoadHandler_OnLoadError(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        cef_types.cef_handler_errorcode_t cefErrorCode,
        CefString& cefFailedUrl,
        CefString& cefErrorText
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef str pyFailedUrl
    cdef object callback
    cdef list errorText
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyFailedUrl = CefToPyString(cefFailedUrl)
        callback = pyBrowser.GetClientCallback("OnLoadError")
        if callback:
            errorText = [""]
            ret = callback(
                    pyBrowser, pyFrame, cefErrorCode, pyFailedUrl, errorText)
            if ret:
                PyToCefString(errorText[0], cefErrorText)
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
