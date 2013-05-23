# Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_web_urlrequest cimport CefWebURLRequest, CefWebURLRequestClient
from cef_request cimport CefRequest

cdef extern from "include/cef_web_urlrequest.h" namespace "CefWebURLRequest":
    cdef CefRefPtr[CefWebURLRequest] CreateWebURLRequest(
            CefRefPtr[CefRequest] request,
            CefRefPtr[CefWebURLRequestClient] client)
