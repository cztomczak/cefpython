# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# TODO: temporarily removed weakref.WeakValueDictionary()
cdef object g_pyWebRequests = {}
cdef int g_webRequestMaxId = 0

# ------------------------------------------------------------------------------
# WebRequest
# ------------------------------------------------------------------------------

# Static methods are not allowed in cdef classes,
# that's why we need a wrapper for PyWebRequest.

class WebRequest:
    State = {
        "Unsent": cef_types.WUR_STATE_UNSENT,
        "Started": cef_types.WUR_STATE_STARTED,
        "HeadersReceived": cef_types.WUR_STATE_HEADERS_RECEIVED,
        "Loading": cef_types.WUR_STATE_LOADING,
        "Done": cef_types.WUR_STATE_DONE,
        "Error": cef_types.WUR_STATE_ERROR,
        "Abort": cef_types.WUR_STATE_ABORT,
    }
    
    def __init__(self):
        raise Exception("You cannot instantiate WebRequest directly, "
                "use WebRequest.CreateWebRequest() static method")

    @staticmethod
    def CreateWebRequest(request, webRequestClient):
        if not isinstance(request, PyRequest):
            raise Exception("Invalid request object")
        return CreatePyWebRequest(request, webRequestClient)

# ------------------------------------------------------------------------------
# PyWebRequest
# ------------------------------------------------------------------------------

cdef PyWebRequest CreatePyWebRequest(PyRequest request, 
        object webRequestClient):
    global g_pyWebRequests
    cdef PyWebRequest webRequest = PyWebRequest(request, webRequestClient)
    assert webRequest.webRequestId, "webRequest.webRequestId empty"
    g_pyWebRequests[webRequest.webRequestId] = webRequest
    return webRequest

cdef PyWebRequest GetPyWebRequest(int webRequestId):
    global g_pyWebRequests
    if webRequestId in g_pyWebRequests:
        return g_pyWebRequests[webRequestId]
    return None

cdef class PyWebRequest:
    #cdef object __weakref__ # see g_pyWebRequests
    cdef int webRequestId
    cdef PyRequest pyRequest
    cdef CefRefPtr[CefWebURLRequest] requester
    cdef CefRefPtr[WebRequestClient] cppWebRequestClient
    cdef object pyWebRequestClient

    def __init__(self, PyRequest pyRequest, object pyWebRequestClient):
        global g_webRequestMaxId
        g_webRequestMaxId += 1
        self.webRequestId = g_webRequestMaxId
        self.pyRequest = pyRequest
        self.cppWebRequestClient = (
                <CefRefPtr[WebRequestClient]?>new WebRequestClient(
                        self.webRequestId))
        self.pyWebRequestClient = pyWebRequestClient
        self.requester = <CefRefPtr[CefWebURLRequest]?>(
                cef_web_urlrequest_static.CreateWebURLRequest(
                        pyRequest.cefRequest, 
                        <CefRefPtr[CefWebURLRequestClient]?>(
                                self.cppWebRequestClient)))

    cdef object GetCallback(self, str funcName):
        if hasattr(self.pyWebRequestClient, funcName) and (
                callable(getattr(self.pyWebRequestClient, funcName))):
            return getattr(self.pyWebRequestClient, funcName)

    cpdef py_void Cancel(self):
        self.requester.get().Cancel()

    cpdef int GetState(self) except *:
        return <int>self.requester.get().GetState()

# ------------------------------------------------------------------------------
# WebRequestClient
# ------------------------------------------------------------------------------

cdef public void WebRequestClient_OnStateChange(
        int webRequestId, 
        CefRefPtr[CefWebURLRequest] requester,
        cef_types.cef_weburlrequest_state_t state
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnStateChange")
            if callback:
                callback(webRequest, <int>state)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnRedirect(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        CefRefPtr[CefRequest] request,
        CefRefPtr[CefResponse] response
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnRedirect")
            if callback:
                callback(webRequest, webRequest.pyRequest,
                        CreatePyResponse(response))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnHeadersReceived(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        CefRefPtr[CefResponse] response
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnHeadersReceived")
            if callback:
                callback(webRequest, CreatePyResponse(response))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnProgress(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        uint64_t bytesSent, 
        uint64_t totalBytesToBeSent
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnProgress")
            if callback:
                callback(webRequest, bytesSent, totalBytesToBeSent)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnData(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        void* data, 
        int dataLength
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnData")
            if callback:
                callback(webRequest, VoidPtrToStr(data, dataLength))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnError(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        int errorCode
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object callback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            callback = webRequest.GetCallback("OnError")
            if callback:
                callback(webRequest, errorCode)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
