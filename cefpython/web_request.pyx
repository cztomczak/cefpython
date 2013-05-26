# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# PyWebRequests are kept int a C++ map and not in a Python Dict,
# as we do not want to increase references for them, the
# deallocation will happen in PyRequest.__dealloc__(). We must
# keep callbacks (OnStateChange and others) and they must be 
# callable from C++ code, thus we need to keep PyWebRequests
# objects in some global scope, if we put PyWebRequests in a
# Python Dict then we would never know of when PyWebRequest 
# global reference can be released, thus the memory for these
# objects would live forever.
# - using uintptr_t instead of void* as it resulted in compiler 
#   crash
# - Casting void* to python object example (see PyWebRequest.__dealloc__):
#   cdef void* a
#   cdef PyWebRequest b = <PyWebRequest>a
# - todo: instead of the C++ map and __dealloc__, try using 
#   WeakValueDictionary and cdef object __weakref__ on PyWebRequest,
#   see weak referencing:
#   http://docs.cython.org/src/reference/extension_types.html#weak-referencing
#cdef cpp_map[int, PyObject*] g_pyWebRequests
cdef object g_pyWebRequests = weakref.WeakValueDictionary()
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
        # Debug("GetPyWebRequest(): found webRequestId = %s" % webRequestId)
        return g_pyWebRequests[webRequestId]
    # Debug("GetPyWebRequest(): not found webRequestId = %s" % webRequestId)
    return None

cdef class PyWebRequest:
    cdef object __weakref__ # see g_pyWebRequests
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
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnStateChange")
        if callback:
            callback(webRequest, <int>state)

cdef public void WebRequestClient_OnRedirect(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        CefRefPtr[CefRequest] request,
        CefRefPtr[CefResponse] response
        ) except * with gil:
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnRedirect")
        if callback:
            callback(webRequest, webRequest.pyRequest,
                    CreatePyResponse(response))

cdef public void WebRequestClient_OnHeadersReceived(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        CefRefPtr[CefResponse] response
        ) except * with gil:
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnHeadersReceived")
        if callback:
            callback(webRequest, CreatePyResponse(response))

cdef public void WebRequestClient_OnProgress(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        uint64_t bytesSent, 
        uint64_t totalBytesToBeSent
        ) except * with gil:
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnProgress")
        if callback:
            callback(webRequest, bytesSent, totalBytesToBeSent)

cdef public void WebRequestClient_OnData(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        void* data, 
        int dataLength
        ) except * with gil:
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnData")
        if callback:
            callback(webRequest, VoidPtrToStr(data, dataLength))

cdef public void WebRequestClient_OnError(
        int webRequestId,
        CefRefPtr[CefWebURLRequest] requester,
        int errorCode
        ) except * with gil:
    cdef PyWebRequest webRequest = GetPyWebRequest(webRequestId)
    cdef object callback
    if webRequest:
        callback = webRequest.GetCallback("OnError")
        if callback:
            callback(webRequest, errorCode)
