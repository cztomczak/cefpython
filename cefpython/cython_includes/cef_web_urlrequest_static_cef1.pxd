# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_web_urlrequest cimport CefWebURLRequest, CefWebURLRequestClient
from cef_request_cef1 cimport CefRequest

cdef extern from "include/cef_web_urlrequest.h" namespace "CefWebURLRequest":
    cdef CefRefPtr[CefWebURLRequest] CreateWebURLRequest(
            CefRefPtr[CefRequest] request,
            CefRefPtr[CefWebURLRequestClient] client)
