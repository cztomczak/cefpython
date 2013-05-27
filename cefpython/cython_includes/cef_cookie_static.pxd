# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_cookie cimport CefCookieManager
from cef_string cimport CefString

cdef extern from "include/cef_cookie.h" namespace "CefCookieManager":
    CefRefPtr[CefCookieManager] GetGlobalManager()
    CefRefPtr[CefCookieManager] CreateManager(const CefString& path)
