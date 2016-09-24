# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
cimport cef_types
from cef_request cimport CefRequest
from cef_response cimport CefResponse
# noinspection PyUnresolvedReferences
from cef_request_context cimport CefRequestContext

cdef extern from "include/cef_urlrequest.h":
    cdef CefRefPtr[CefURLRequest] CefURLRequest_Create \
            "CefURLRequest::Create"(
                    CefRefPtr[CefRequest] request,
                    CefRefPtr[CefURLRequestClient] client,
                    CefRefPtr[CefRequestContext])

    cdef cppclass CefURLRequest:
        CefRefPtr[CefRequest] GetRequest()
        CefRefPtr[CefURLRequestClient] GetClient()
        cef_types.cef_urlrequest_status_t GetRequestStatus()
        cef_types.cef_errorcode_t GetRequestError()
        CefRefPtr[CefResponse] GetResponse()
        void Cancel()

    cdef cppclass CefURLRequestClient:
        pass
