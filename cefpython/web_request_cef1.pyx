# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# TODO: fix CefWebURLRequest memory corruption and restore weakrefs
# for PyWebRequest object. Right now getting memory corruption
# when CefRefPtr[CefWebURLRequest] is released after the request
# is completed. The memory corruption manifests itself with the
# "Segmentation Fault" error message or the strange "C function 
# name could not be determined in the current C stack frame".
# See this topic on cython-users group:
# https://groups.google.com/d/topic/cython-users/FJZwHhqaCSI/discussion
# After CefWebURLRequest memory corruption is fixed restore weakrefs:
# 1. cdef object g_pyWebRequests = weakref.WeakValueDictionary()
# 2. Add property "cdef object __weakref__" in PyWebRequest
# When using normal dictionary for g_pyWebRequest then the memory
# corruption doesn't occur, but the PyWebRequest and CefWebURLRequest
# objects are never released, thus you have memory leaks, for now 
# there is no other solution. See this topic on the CEF Forum:
# http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10710
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
    # cdef object __weakref__ # see g_pyWebRequests
    cdef int webRequestId
    cdef CefRefPtr[CefWebURLRequest] requester
    cdef object pyWebRequestClient

    def __init__(self, PyRequest pyRequest, object pyWebRequestClient):
        global g_webRequestMaxId
        g_webRequestMaxId += 1
        self.webRequestId = g_webRequestMaxId
        cdef CefRefPtr[WebRequestClient] cppWebRequestClient = (
                <CefRefPtr[WebRequestClient]?>new WebRequestClient(
                        self.webRequestId))
        self.pyWebRequestClient = pyWebRequestClient
        self.requester = <CefRefPtr[CefWebURLRequest]?>(
                cef_web_urlrequest_static.CreateWebURLRequest(
                        pyRequest.cefRequest, 
                        <CefRefPtr[CefWebURLRequestClient]?>(
                                cppWebRequestClient)))

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
                callback(webRequest, VoidPtrToString(data, dataLength))
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
