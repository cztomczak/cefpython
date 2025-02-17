# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"
from libc.stdint cimport int64_t
import weakref

cdef object g_pyWebRequests = weakref.WeakValueDictionary()
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
    cdef object __weakref__ # see g_pyWebRequests
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
        self.cefWebRequest = <CefRefPtr[CefURLRequest]?>(CefURLRequest_Create(
                pyRequest.cefRequest,
                <CefRefPtr[CefURLRequestClient]?>cppWebRequestClient,
                <CefRefPtr[CefRequestContext]?>nullptr))

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
        int64_t current,
        int64_t total
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnUploadProgress")
            if userCallback:
                userCallback(
                        web_request=webRequest,
                        current=current,
                        total=total)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace) 

cdef public void WebRequestClient_OnDownloadProgress(
        int webRequestId,
        CefRefPtr[CefURLRequest] cefWebRequest,
        int64_t current,
        int64_t total
        ) except * with gil:
    cdef PyWebRequest webRequest
    cdef object userCallback
    try:
        webRequest = GetPyWebRequest(webRequestId)
        if webRequest:
            userCallback = webRequest.GetCallback("OnDownloadProgress")
            if userCallback:
                userCallback(
                    web_request=webRequest,
                    current=current,
                    total=total)
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
                userCallback(
                        web_request=webRequest,
                        data=VoidPtrToBytes(data, dataLength))
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
                userCallback(web_request=webRequest)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
