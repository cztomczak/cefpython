# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

NAVTYPE_LINKCLICKED = cef_types.NAVTYPE_LINKCLICKED
NAVTYPE_FORMSUBMITTED = cef_types.NAVTYPE_FORMSUBMITTED
NAVTYPE_BACKFORWARD = cef_types.NAVTYPE_BACKFORWARD
NAVTYPE_RELOAD = cef_types.NAVTYPE_RELOAD
NAVTYPE_FORMRESUBMITTED = cef_types.NAVTYPE_FORMRESUBMITTED
NAVTYPE_OTHER = cef_types.NAVTYPE_OTHER
NAVTYPE_LINKDROPPED = cef_types.NAVTYPE_LINKDROPPED

cdef public cpp_bool RequestHandler_OnBeforeBrowse(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefRequest] cefRequest,
        cef_types.cef_handler_navtype_t navType,
        cpp_bool isRedirect
        ) except * with gil:
    # TODO: not yet implemented.
    return False

    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    # cdef PyRequest pyRequest
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = None
        callback = pyBrowser.GetClientCallback("OnBeforeBrowse")
        if callback:
            return bool(callback(
                    pyBrowser, pyFrame, pyRequest, <int>navType, isRedirect))
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnBeforeResourceLoad(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefRequest] cefRequest,
        CefString& cefRedirectUrl,
        CefRefPtr[CefStreamReader]& cefResourceStream,
        CefRefPtr[CefResponse] cefResponse,
        int loadFlags
        ) except * with gil:
    # TODO: not yet implemented.
    return False

    cdef PyBrowser pyBrowser
    # cdef PyRequest pyRequest
    cdef list pyRedirectUrl
    # cdef PyResourceStream pyResourceStream
    # cdef PyResponse pyResponse
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyRequest = None
        pyRedirectUrl = [""]
        pyResourceStream = None
        pyResponse = None
        callback = pyBrowser.GetClientCallback("OnBeforeResourceLoad")
        if callback:
            ret = callback(
                    pyBrowser, pyRequest, pyRedirectUrl, pyResourceStream, pyResponse)
            assert type(pyRedirectUrl) == list
            assert type(pyRedirectUrl[0]) == str
            if pyRedirectUrl[0]:
                PyToCefString(pyRedirectUrl[0], cefRedirectUrl)
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceRedirect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefOldUrl,
        CefString& cefNewUrl
        ) except * with gil:
    # TODO: needs testing.
    cdef PyBrowser pyBrowser
    cdef str pyOldUrl
    # [""] pass by reference (out).
    cdef list pyNewUrl
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyOldUrl = CefToPyString(cefOldUrl)
        pyNewUrl = [CefToPyString(cefNewUrl)]
        callback = pyBrowser.GetClientCallback("OnResourceRedirect")
        if callback:
            callback(pyBrowser, pyOldUrl, pyNewUrl)
            if pyNewUrl[0]:
                PyToCefString(pyNewUrl[0], cefNewUrl)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceResponse(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefUrl,
        CefRefPtr[CefResponse] cefResponse,
        CefRefPtr[CefContentFilter]& cefContentFilter
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef str pyUrl
    # cdef PyResponse pyResponse
    # cdef PyContentFilter pyContentFilter
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyUrl = CefToPyString(cefUrl)
        pyResponse = CreatePyResponse(cefResponse)
        pyContentFilter = None
        callback = pyBrowser.GetClientCallback("OnResourceResponse")
        if callback:
            callback(pyBrowser, pyUrl, pyResponse, pyContentFilter)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnProtocolExecution(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefUrl,
        cpp_bool& cefAllowOSExecution
        ) except * with gil:
    # TODO: needs testing.
    cdef PyBrowser pyBrowser
    cdef str pyUrl
    # [True] pass by reference (out).
    cdef list pyAllowExecution
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyUrl = CefToPyString(cefUrl)
        pyAllowOSExecution = [bool(cefAllowOSExecution)]
        callback = pyBrowser.GetClientCallback("OnProtocolExecution")
        if callback:
            ret = callback(
                    pyBrowser, pyUrl, pyAllowOSExecution)
            cefAllowOSExecution = bool(pyAllowOSExecution[0])
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_GetDownloadHandler(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& cefMimeType,
        CefString& cefFilename,
        cef_types.int64 cefContentLength,
        CefRefPtr[CefDownloadHandler]& cefDownloadHandler
        ) except * with gil:
    # TODO: not yet implemented.
    return False

    cdef PyBrowser pyBrowser
    cdef str pyMimeType
    cdef str pyFilename
    cdef int pyContentLength
    # cdef PyDownloadHandler pyDownloadHandler
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMimeType = CefToPyString(cefMimeType)
        pyFilename = CefToPyString(cefFilename)
        pyContentLength = int(cefContentLength)
        pyDownloadHandler = None
        callback = pyBrowser.GetClientCallback("GetDownloadHandler")
        if callback:
            return bool(callback(pyBrowser, pyMimeType, pyFilename, pyContentLength, pyDownloadHandler))
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_GetAuthCredentials(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool cefIsProxy,
        CefString& cefHost,
        int cefPort,
        CefString& cefRealm,
        CefString& cefScheme,
        CefString& cefUsername,
        CefString& cefPassword
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_bool pyIsProxy
    cdef str pyHost
    cdef int pyPort
    cdef str pyRealm
    cdef str pyScheme
    # [""] pass by reference (out).
    cdef list pyUsername
    cdef list pyPassword
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyIsProxy = bool(cefIsProxy)
        pyHost = CefToPyString(cefHost)
        pyPort = int(cefPort)
        pyRealm = CefToPyString(cefRealm)
        pyScheme = CefToPyString(cefScheme)
        pyUsername = [""]
        pyPassword = [""]
        callback = pyBrowser.GetClientCallback("GetAuthCredentials")
        if callback:
            ret = callback(
                    pyBrowser,
                    pyIsProxy, pyHost, pyPort, pyRealm, pyScheme,
                    pyUsername, pyPassword)
            if ret:
                PyToCefString(pyUsername[0], cefUsername)
                PyToCefString(pyPassword[0], cefPassword)
            return bool(ret)
        else:
            # Default implementation.
            IF UNAME_SYSNAME == "Windows":
                ret = HttpAuthenticationDialog(
                        pyBrowser,
                        pyIsProxy, pyHost, pyPort, pyRealm, pyScheme,
                        pyUsername, pyPassword)
                if ret:
                    PyToCefString(pyUsername[0], cefUsername)
                    PyToCefString(pyPassword[0], cefPassword)
                return bool(ret)
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& mainUrl
        ) except * with gil:
    # TODO: not yet implemented.
    return <CefRefPtr[CefCookieManager]>NULL
    cdef PyBrowser pyBrowser
    cdef str pyMainUrl
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMainUrl = CefToPyString(mainUrl)
        callback = pyBrowser.GetClientCallback("GetCookieManager")
        if callback:
            ret = bool(callback(
                    pyBrowser, pyMainUrl))
            if ret:
                pass
            return <CefRefPtr[CefCookieManager]>NULL
        else:
            return <CefRefPtr[CefCookieManager]>NULL
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
