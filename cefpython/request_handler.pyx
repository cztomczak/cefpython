# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# cef_termination_status_t
TS_ABNORMAL_TERMINATION = cef_types.TS_ABNORMAL_TERMINATION
TS_PROCESS_WAS_KILLED = cef_types.TS_PROCESS_WAS_KILLED
TS_PROCESS_CRASHED = cef_types.TS_PROCESS_CRASHED

# -----------------------------------------------------------------------------
# PyAuthCallback
# -----------------------------------------------------------------------------
cdef PyAuthCallback CreatePyAuthCallback(
        CefRefPtr[CefAuthCallback] cefCallback):
    cdef PyAuthCallback pyCallback = PyAuthCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyAuthCallback:
    cdef CefRefPtr[CefAuthCallback] cefCallback
    
    cpdef py_void Continue(self, py_string username, py_string password):
        self.cefCallback.get().Continue(
                PyToCefStringValue(username),
                PyToCefStringValue(password))
    
    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()

# -----------------------------------------------------------------------------
# PyQuotaCallback
# -----------------------------------------------------------------------------
cdef PyQuotaCallback CreatePyQuotaCallback(
        CefRefPtr[CefQuotaCallback] cefCallback):
    cdef PyQuotaCallback pyCallback = PyQuotaCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyQuotaCallback:
    cdef CefRefPtr[CefQuotaCallback] cefCallback

    cpdef py_void Continue(self, py_bool allow):
        self.cefCallback.get().Continue(bool(allow))

    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()

# -----------------------------------------------------------------------------
# PyAllowCertificateErrorCallback
# -----------------------------------------------------------------------------
cdef PyAllowCertificateErrorCallback CreatePyAllowCertificateErrorCallback(
        CefRefPtr[CefAllowCertificateErrorCallback] cefCallback):
    cdef PyAllowCertificateErrorCallback pyCallback = \
            PyAllowCertificateErrorCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyAllowCertificateErrorCallback:
    cdef CefRefPtr[CefAllowCertificateErrorCallback] cefCallback

    cpdef py_void Continue(self, py_bool allow):
        self.cefCallback.get().Continue(bool(allow))

# -----------------------------------------------------------------------------
# RequestHandler
# -----------------------------------------------------------------------------

cdef public cpp_bool RequestHandler_OnBeforeResourceLoad(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefRequest] cefRequest
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef PyRequest pyRequest
    cdef object clientCallback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        clientCallback = pyBrowser.GetClientCallback("OnBeforeResourceLoad")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyFrame, pyRequest)
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnBeforeBrowse(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefRequest] cefRequest,
        cpp_bool cefIsRedirect
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef PyRequest pyRequest
    cdef py_bool pyIsRedirect
    cdef object clientCallback
    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        pyIsRedirect = bool(cefIsRedirect)
        clientCallback = pyBrowser.GetClientCallback("OnBeforeBrowse")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyFrame, pyRequest,
                                         pyIsRedirect)
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public CefRefPtr[CefResourceHandler] RequestHandler_GetResourceHandler(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefRequest] cefRequest
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef PyRequest pyRequest
    cdef object clientCallback
    cdef object returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        clientCallback = pyBrowser.GetClientCallback("GetResourceHandler")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyFrame, pyRequest)
            if returnValue:
                return CreateResourceHandler(returnValue)
            else:
                return <CefRefPtr[CefResourceHandler]>NULL
        else:
            return <CefRefPtr[CefResourceHandler]>NULL
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceRedirect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        const CefString& cefOldUrl,
        CefString& cefNewUrl
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef str pyOldUrl
    cdef list pyNewUrlOut
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyOldUrl = CefToPyString(cefOldUrl)
        pyNewUrlOut = [CefToPyString(cefNewUrl)]
        clientCallback = pyBrowser.GetClientCallback("OnResourceRedirect")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame, pyOldUrl, pyNewUrlOut)
            if pyNewUrlOut[0]:
                PyToCefString(pyNewUrlOut[0], cefNewUrl)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_GetAuthCredentials(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        cpp_bool cefIsProxy,
        const CefString& cefHost,
        int cefPort,
        const CefString& cefRealm,
        const CefString& cefScheme,
        CefRefPtr[CefAuthCallback] cefAuthCallback
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef py_bool pyIsProxy
    cdef str pyHost
    cdef int pyPort
    cdef str pyRealm
    cdef str pyScheme
    cdef PyAuthCallback pyAuthCallback
    cdef py_bool returnValue
    cdef list pyUsernameOut
    cdef list pyPasswordOut
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        pyIsProxy = bool(cefIsProxy)
        pyHost = CefToPyString(cefHost)
        pyPort = int(cefPort)
        pyRealm = CefToPyString(cefRealm)
        pyScheme = CefToPyString(cefScheme)
        pyAuthCallback = CreatePyAuthCallback(cefAuthCallback)
        pyUsernameOut = [""]
        pyPasswordOut = [""]
        clientCallback = pyBrowser.GetClientCallback("GetAuthCredentials")
        if clientCallback:
            returnValue = clientCallback(
                    pyBrowser, pyFrame,
                    pyIsProxy, pyHost, pyPort, pyRealm, pyScheme,
                    pyAuthCallback)
            return bool(returnValue)
        else:
            # TODO: port it from CEF 1, copy the cef1/http_authentication/.
            # --
            # Default implementation for Windows.
            # IF UNAME_SYSNAME == "Windows":
            #     returnValue = HttpAuthenticationDialog(
            #             pyBrowser,
            #             pyIsProxy, pyHost, pyPort, pyRealm, pyScheme,
            #             pyUsernameOut, pyPasswordOut)
            #     if returnValue:
            #         pyAuthCallback.Continue(pyUsernameOut[0], pyPasswordOut[0])
            #         return True
            #     return False
            # ELSE:
            #     return False
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnQuotaRequest(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefOriginUrl,
        int64 newSize,
        CefRefPtr[CefQuotaCallback] cefQuotaCallback
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyOriginUrl
    cdef py_bool returnValue
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyOriginUrl = CefToPyString(cefOriginUrl)
        clientCallback = pyBrowser.GetClientCallback("OnQuotaRequest")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyOriginUrl, long(newSize),
                    CreatePyQuotaCallback(cefQuotaCallback))
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefMainUrl
        ) except * with gil:
    # In CEF the GetCookieManager callback belongs to 
    # CefRequestContextHandler.
    # In an exceptional case the browser parameter may be None
    # due to limitation in CEF API. No workaround as of now.
    cdef PyBrowser pyBrowser
    cdef str pyMainUrl
    cdef object clientCallback
    cdef PyCookieManager returnValue
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyMainUrl = CefToPyString(cefMainUrl)
        if pyBrowser:
            # Browser may be empty.
            clientCallback = pyBrowser.GetClientCallback("GetCookieManager")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, pyMainUrl)
            if returnValue:
                if isinstance(returnValue, PyCookieManager):
                    return returnValue.cefCookieManager
                else:
                    raise Exception("Expected a CookieManager object")
            return <CefRefPtr[CefCookieManager]>NULL
        else:
            return <CefRefPtr[CefCookieManager]>NULL
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnProtocolExecution(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefUrl,
        cpp_bool& cefAllowOSExecution
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef str pyUrl
    cdef list pyAllowOSExecutionOut
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyUrl = CefToPyString(cefUrl)
        pyAllowOSExecutionOut = [bool(cefAllowOSExecution)]
        clientCallback = pyBrowser.GetClientCallback("OnProtocolExecution")
        if clientCallback:
            clientCallback(pyBrowser, pyUrl, pyAllowOSExecutionOut)
            # Since Cython 0.17.4 assigning a value to an argument
            # passed by reference will throw an error, the fix is to
            # to use "(&arg)[0] =" instead of "arg =", see this topic:
            # https://groups.google.com/forum/#!msg/cython-users/j58Sp3QMrD4/y9vJy9YBi_kJ
            # For CefRefPtr you should use swap() method instead.
            (&cefAllowOSExecution)[0] = 1
            #(&cefAllowOSExecution)[0] = <cpp_bool>bool(pyAllowOSExecutionOut[0])
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnBeforePluginLoad(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& cefUrl,
        const CefString& cefPolicyUrl,
        CefRefPtr[CefWebPluginInfo] cefInfo
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyWebPluginInfo pyInfo
    cdef py_bool returnValue
    cdef object clientCallback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyInfo = CreatePyWebPluginInfo(cefInfo)
        clientCallback = GetGlobalClientCallback("OnBeforePluginLoad")
        if clientCallback:
            returnValue = clientCallback(pyBrowser, CefToPyString(cefUrl),
                    CefToPyString(cefPolicyUrl), pyInfo)
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RequestHandler_OnCertificateError(
        int certError,
        const CefString& cefRequestUrl,
        CefRefPtr[CefAllowCertificateErrorCallback] cefCertCallback
        ) except * with gil:
    cdef py_bool returnValue
    cdef object clientCallback
    try:
        clientCallback = GetGlobalClientCallback("OnCertificateError")
        if clientCallback:
            returnValue = clientCallback(certError, 
                    CefToPyString(cefRequestUrl),
                    CreatePyAllowCertificateErrorCallback(cefCertCallback))
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnRendererProcessTerminated(
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

cdef public void RequestHandler_OnPluginCrashed(
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
