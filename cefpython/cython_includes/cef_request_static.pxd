# Copyright (c) 2012-2013 CEF Python Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_request cimport CefRequest, CefPostData, CefPostDataElement

cdef extern from "include/cef_request.h" namespace "CefRequest":
    cdef CefRefPtr[CefRequest] CreateRequest()

cdef extern from "include/cef_request.h" namespace "CefPostData":
    cdef CefRefPtr[CefPostData] CreatePostData()

cdef extern from "include/cef_request.h" namespace "CefPostDataElement":
    cdef CefRefPtr[CefPostDataElement] CreatePostDataElement()
