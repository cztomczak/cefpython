# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"
include "../cookie.pyx"

# cef_termination_status_t
cimport cef_types
from libc.stdint cimport int64_t
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
# PyRequestCallback
# -----------------------------------------------------------------------------

cdef PyRequestCallback CreatePyRequestCallback(
        CefRefPtr[CefCallback] cefCallback):
    cdef PyRequestCallback pyCallback = PyRequestCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyRequestCallback:
    cdef CefRefPtr[CefCallback] cefCallback

    cpdef py_void Continue(self):
        self.cefCallback.get().Continue()

    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()


# -----------------------------------------------------------------------------
# RequestHandler
# -----------------------------------------------------------------------------

cdef public cpp_bool RequestHandler_OnBeforeBrowse(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefRequest] cefRequest,
        cpp_bool user_gesture,
        cpp_bool is_redirect
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef PyRequest pyRequest
    cdef object clientCallback
    cdef py_bool returnValue
    try:
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return False

        pyBrowser = GetPyBrowser(cefBrowser, "OnBeforeBrowse")
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        clientCallback = pyBrowser.GetClientCallback("OnBeforeBrowse")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    request=pyRequest,
                    user_gesture=user_gesture,
                    is_redirect=is_redirect)
            return bool(returnValue)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


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
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return False

        pyBrowser = GetPyBrowser(cefBrowser, "OnBeforeResourceLoad")
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        clientCallback = pyBrowser.GetClientCallback("OnBeforeResourceLoad")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    request=pyRequest)
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
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return <CefRefPtr[CefResourceHandler]>nullptr

        pyBrowser = GetPyBrowser(cefBrowser, "GetResourceHandler")
        pyFrame = GetPyFrame(cefFrame)
        pyRequest = CreatePyRequest(cefRequest)
        clientCallback = pyBrowser.GetClientCallback("GetResourceHandler")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    request=pyRequest)
            if returnValue:
                return CreateResourceHandler(returnValue)
            else:
                return <CefRefPtr[CefResourceHandler]>nullptr
        else:
            return <CefRefPtr[CefResourceHandler]>nullptr
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


cdef public void RequestHandler_OnResourceRedirect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        const CefString& cefOldUrl,
        CefString& cefNewUrl,
        CefRefPtr[CefRequest] cefRequest,
        CefRefPtr[CefResponse] cefResponse
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef str pyOldUrl
    cdef list pyNewUrlOut
    cdef PyRequest pyRequest
    cdef PyResponse pyResponse
    cdef object clientCallback
    try:
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return

        pyBrowser = GetPyBrowser(cefBrowser, "OnResourceRedirect")
        pyFrame = GetPyFrame(cefFrame)
        pyOldUrl = CefToPyString(cefOldUrl)
        pyNewUrlOut = [CefToPyString(cefNewUrl)]
        pyRequest = CreatePyRequest(cefRequest)
        pyResponse = CreatePyResponse(cefResponse)
        clientCallback = pyBrowser.GetClientCallback("OnResourceRedirect")
        if clientCallback:
            clientCallback(
                    browser=pyBrowser,
                    frame=pyFrame,
                    old_url=pyOldUrl,
                    new_url_out=pyNewUrlOut,
                    request=pyRequest,
                    response=pyResponse)
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
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return False

        pyBrowser = GetPyBrowser(cefBrowser, "GetAuthCredentials")
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
                    browser=pyBrowser,
                    frame=pyFrame,
                    is_proxy=pyIsProxy,
                    host=pyHost,
                    port=pyPort,
                    realm=pyRealm,
                    scheme=pyScheme,
                    callback=pyAuthCallback)
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
        int64_t newSize,
        CefRefPtr[CefCallback] cefCallback
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyOriginUrl
    cdef py_bool returnValue
    cdef object clientCallback
    try:
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return False

        pyBrowser = GetPyBrowser(cefBrowser, "OnQuotaRequest")
        pyOriginUrl = CefToPyString(cefOriginUrl)
        clientCallback = pyBrowser.GetClientCallback("OnQuotaRequest")
        if clientCallback:
            returnValue = clientCallback(
                    browser=pyBrowser,
                    origin_url=pyOriginUrl,
                    new_size=newSize,
                    callback=CreatePyRequestCallback(cefCallback))
            return bool(returnValue)
        else:
            return False
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
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return

        pyBrowser = GetPyBrowser(cefBrowser, "OnProtocolExecution")
        pyUrl = CefToPyString(cefUrl)
        pyAllowOSExecutionOut = [bool(cefAllowOSExecution)]
        clientCallback = pyBrowser.GetClientCallback("OnProtocolExecution")
        if clientCallback:
            clientCallback(
                    browser=pyBrowser,
                    url=pyUrl,
                    allow_execution_out=pyAllowOSExecutionOut)
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


cdef public cpp_bool RequestHandler_OnCertificateError(
        int certError,
        const CefString& cefRequestUrl,
        CefRefPtr[CefCallback] cefCertCallback
        ) except * with gil:
    cdef py_bool returnValue
    cdef object clientCallback
    try:
        clientCallback = GetGlobalClientCallback("OnCertificateError")
        if clientCallback:
            returnValue = clientCallback(
                    cert_error=certError,
                    request_url=CefToPyString(cefRequestUrl),
                    callback=CreatePyRequestCallback(cefCertCallback))
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
        # Issue #455: CefRequestHandler callbacks still executed after
        # browser was closed.
        if IsBrowserClosed(cefBrowser):
            return

        pyBrowser = GetPyBrowser(cefBrowser, "OnRendererProcessTerminated")
        clientCallback = pyBrowser.GetClientCallback(
                "OnRendererProcessTerminated")
        if clientCallback:
            clientCallback(browser=pyBrowser, status=cefStatus)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
