# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# cef_termination_status_t
TS_ABNORMAL_TERMINATION = cef_types.TS_ABNORMAL_TERMINATION
TS_PROCESS_WAS_KILLED = cef_types.TS_PROCESS_WAS_KILLED
TS_PROCESS_CRASHED = cef_types.TS_PROCESS_CRASHED

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

cdef public void LoadHandler_OnRendererProcessTerminated(
        CefRefPtr[CefBrowser] cefBrowser,
        cef_types.cef_termination_status_t cefStatus
        ) except * with gil:
    # TODO: proccess may crash during browser creation. Let this callback 
    # to be set either through  cefpython.SetGlobalClientCallback() 
    # or PyBrowser.SetClientCallback(). Modify the 
    # PyBrowser.GetClientCallback() implementation to return a global 
    # callback first if set.
    cdef PyBrowser pyBrowser
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        clientCallback = pyBrowser.GetClientCallback(
                "OnRendererProcessTerminated")
        if clientCallback:
            clientCallback(pyBrowser, cefStatus)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LoadHandler_OnPluginCrashed(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefPluginPath
        ) except * with gil:
    # TODO: plugin may crash during browser creation. Let this callback 
    # to be set either through  cefpython.SetGlobalClientCallback() 
    # or PyBrowser.SetClientCallback(). Modify the 
    # PyBrowser.GetClientCallback() implementation to return a global 
    # callback first if set.
    cdef PyBrowser pyBrowser
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        clientCallback = pyBrowser.GetClientCallback("OnPluginCrashed")
        if clientCallback:
            clientCallback(pyBrowser, CefToPyString(cefPluginPath))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
