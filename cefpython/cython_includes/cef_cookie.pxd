# Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport cef_string_t
from libcpp cimport bool as cpp_bool
from cef_time cimport cef_time_t

cdef extern from "include/cef_cookie.h":
    cdef cppclass CefCookieManager:
        pass

    ctypedef struct CefCookie:
        cef_string_t name
        cef_string_t value
        cef_string_t domain
        cef_string_t path
        cpp_bool secure
        cpp_bool httponly
        cef_time_t creation
        cef_time_t last_access
        cpp_bool has_expires
        cef_time_t expires
