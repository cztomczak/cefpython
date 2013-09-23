# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# (The comments below were from CEF 1 usage, the problems described
#  might not be an issue in CEF 3 anymore, test it TODO)
#
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

# -----------------------------------------------------------------------------
# WebRequest
# -----------------------------------------------------------------------------

# Static methods are not allowed in cdef classes,
# that's why we need a wrapper for PyWebRequest.

class WebRequest:
    Status = {
        "Unknown": cef_types.UR_UNKNOWN,
        "Success": cef_types.UR_SUCCESS,
        "Pending": cef_types.UR_IO_PENDING,
        "Canceled": cef_types.UR_CANCELED,
        "Failed": cef_types.UR_FAILED,
    }
    
    def __init__(self):
        raise Exception("You cannot instantiate WebRequest directly, "
                "use WebRequest.CreateWebRequest() static method")

    @staticmethod
    def ValidateClient(webRequestClient):
        cdef list methods = ["OnRequestComplete", "OnUploadProgress",
            "OnDownloadProgress", "OnDownloadData"]
        for method in methods:
            if webRequestClient and hasattr(webRequestClient, method) \
                    and callable(getattr(webRequestClient, method)):
                # Okay.
                continue
            else:
                raise Exception("WebRequestClient object is missing method: " \
                        "%s" % method)

    @staticmethod
    def Create(request, webRequestClient):
        if not isinstance(request, PyRequest):
            raise Exception("Invalid request object")
        WebRequest.ValidateClient(webRequestClient)
        return CreatePyWebRequest(request, webRequestClient)

# -----------------------------------------------------------------------------
# PyWebRequest
# -----------------------------------------------------------------------------

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
    cdef CefRefPtr[CefURLRequest] cefWebRequest
    cdef object pyWebRequestClient

    def __init__(self, PyRequest pyRequest, object pyWebRequestClient):
        global g_webRequestMaxId
        g_webRequestMaxId += 1
        self.webRequestId = g_webRequestMaxId
        cdef CefRefPtr[WebRequestClient] cppWebRequestClient = (
                <CefRefPtr[WebRequestClient]?>new WebRequestClient(
                        self.webRequestId))
        self.pyWebRequestClient = pyWebRequestClient
        self.cefWebRequest = <CefRefPtr[CefURLRequest]?>(CefURLRequest_Create(\
                pyRequest.cefRequest, \
                <CefRefPtr[CefURLRequestClient]?>(cppWebRequestClient)))

    cdef object GetCallback(self, str funcName):
        if hasattr(self.pyWebRequestClient, funcName) and (
                callable(getattr(self.pyWebRequestClient, funcName))):
            return getattr(self.pyWebRequestClient, funcName)

    cpdef PyRequest GetRequest(self):
        cdef CefRefPtr[CefRequest] cefRequest = \
                self.cefWebRequest.get().GetRequest()
        cdef PyRequest pyRequest = CreatePyRequest(cefRequest)
        return pyRequest

    cpdef int GetRequestStatus(self) except *:
        return self.cefWebRequest.get().GetRequestStatus()

    cpdef int GetRequestError(self) except *:
        return self.cefWebRequest.get().GetRequestError()

    cpdef PyResponse GetResponse(self):
        cdef CefRefPtr[CefResponse] cefResponse = \
                self.cefWebRequest.get().GetResponse()
        cdef PyResponse pyResponse
        # CefResponse may be NULL.
        if cefResponse.get():
            pyResponse = CreatePyResponse(cefResponse)
            return pyResponse
        return None

    cpdef py_void Cancel(self):
        self.cefWebRequest.get().Cancel()

# -----------------------------------------------------------------------------
# WebRequestClient
# -----------------------------------------------------------------------------

cdef public void WebRequestClient_OnUploadProgress(
        int webRequestId,
        CefRefPtr[CefURLRequest] cefWebRequest,
        cef_types.uint64 current,
        cef_types.uint64 total
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnUploadProgress")
            if userCallback:
                userCallback(webRequest, current, total)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace) 

cdef public void WebRequestClient_OnDownloadProgress(
        int webRequestId,
        CefRefPtr[CefURLRequest] cefWebRequest,
        cef_types.uint64 current,
        cef_types.uint64 total
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnDownloadProgress")
            if userCallback:
                userCallback(webRequest, current, total)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace) 

cdef public void WebRequestClient_OnDownloadData(
        int webRequestId,
        CefRefPtr[CefURLRequest] cefWebRequest,
        const void* data,
        size_t dataLength
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnDownloadData")
            if userCallback:
                userCallback(webRequest, VoidPtrToString(data, dataLength))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void WebRequestClient_OnRequestComplete(
        int webRequestId,
        CefRefPtr[CefURLRequest] cefWebRequest
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnRequestComplete")
            if userCallback:
                userCallback(webRequest)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
