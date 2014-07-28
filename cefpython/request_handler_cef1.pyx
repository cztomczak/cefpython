# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
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
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef PyRequest pyRequest
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
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
        CefRefPtr[CefStreamReader]& cefStreamReader,
        CefRefPtr[CefResponse] cefResponse,
        int loadFlags
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyRequest pyRequest
    cdef list pyRedirectUrl
    cdef PyStreamReader pyStreamReader
    cdef PyResponse pyResponse
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyRequest = CreatePyRequest(cefRequest)
        pyRedirectUrl = [""]
        pyStreamReader = PyStreamReader()
        pyResponse = CreatePyResponse(cefResponse)
        callback = pyBrowser.GetClientCallback("OnBeforeResourceLoad")
        if callback:
            ret = callback(pyBrowser, pyRequest, pyRedirectUrl, 
                    pyStreamReader, pyResponse, loadFlags)
            assert type(pyRedirectUrl) == list
            assert type(pyRedirectUrl[0]) == str
            if pyRedirectUrl[0]:
                PyToCefString(pyRedirectUrl[0], cefRedirectUrl)
            if pyStreamReader.HasCefStreamReader():
                cefStreamReader.swap(pyStreamReader.GetCefStreamReader())
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
    cdef PyBrowser pyBrowser
    cdef str pyOldUrl
    cdef list pyNewUrl # = [""] pass by reference (out).
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
    cdef PyResponse pyResponse
    cdef PyContentFilter pyContentFilter
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyUrl = CefToPyString(cefUrl)
        pyResponse = CreatePyResponse(cefResponse)
        pyContentFilter = PyContentFilter()
        callback = pyBrowser.GetClientCallback("OnResourceResponse")
        if callback:
            callback(pyBrowser, pyUrl, pyResponse, pyContentFilter)
            if pyContentFilter.HasHandler():
                cefContentFilter.swap(pyContentFilter.GetCefContentFilter())
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
    cdef list pyAllowOSExecution # = [True] pass by reference (out).
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
            # Since Cython 0.17.4 assigning a value to an argument
            # passed by reference will throw an error, the fix is to
            # to use "(&arg)[0] =" instead of "arg =", see this topic:
            # https://groups.google.com/forum/#!msg/cython-users/j58Sp3QMrD4/y9vJy9YBi_kJ
            # For CefRefPtr you should use swap() method instead.
            (&cefAllowOSExecution)[0] = bool(pyAllowOSExecution[0])
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_GetDownloadHandler(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefMimeType,
        const CefString& cefFilename,
        cef_types.int64 cefContentLength,
        CefRefPtr[CefDownloadHandler]& cefDownloadHandler
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef str pyMimeType
    cdef str pyFilename
    cdef long pyContentLength
    cdef object callback
    cdef object userDownloadHandler
    cdef CefRefPtr[CefDownloadHandler] downloadHandler
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMimeType = CefToPyString(cefMimeType)
        pyFilename = CefToPyString(cefFilename)
        pyContentLength = <long>cefContentLength
        callback = pyBrowser.GetClientCallback("GetDownloadHandler")
        if callback:
            userDownloadHandler = callback(pyBrowser, pyMimeType, pyFilename,
                    pyContentLength)
            if userDownloadHandler:
                downloadHandler = StoreUserDownloadHandler(userDownloadHandler)
                cefDownloadHandler.swap(downloadHandler)
                return True
            else:
                return False
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
    cdef list pyUsername # = [""] pass by reference (out).
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
            ELSE:
                return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
        CefRefPtr[CefBrowser] cefBrowser,
        CefString& mainUrl
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef str pyMainUrl
    cdef object callback
    cdef PyCookieManager ret
    try:
        assert IsThread(TID_IO), "Must be called on the IO thread"
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMainUrl = CefToPyString(mainUrl)
        callback = pyBrowser.GetClientCallback("GetCookieManager")
        if callback:
            ret = callback(pyBrowser, pyMainUrl)
            if ret:
                if isinstance(ret, PyCookieManager):
                    return ret.cefCookieManager
                else:
                    raise Exception("Expected CookieManager object")
            return <CefRefPtr[CefCookieManager]>NULL
        else:
            return <CefRefPtr[CefCookieManager]>NULL
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
