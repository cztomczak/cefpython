# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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
