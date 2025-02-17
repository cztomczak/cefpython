# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport cef_string_t
from libcpp cimport bool as cpp_bool
from cef_time cimport cef_time_t
from libcpp.vector cimport vector as cpp_vector
from cef_string cimport CefString
from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_callback cimport CefCompletionCallback
from cef_time cimport cef_basetime_t

cdef extern from "include/internal/cef_types.h":
    ctypedef struct CefCookie:
        cef_string_t name
        cef_string_t value
        cef_string_t domain
        cef_string_t path
        cpp_bool secure
        cpp_bool httponly
        cef_basetime_t creation
        cef_basetime_t last_access
        cpp_bool has_expires
        cef_basetime_t expires


cdef extern from "include/cef_cookie.h":
    cdef CefRefPtr[CefCookieManager] CefCookieManager_GetGlobalManager \
            "CefCookieManager::GetGlobalManager"(
                CefRefPtr[CefCompletionCallback] callback)

    cdef cppclass CefCookieManager:
        cpp_bool VisitAllCookies(CefRefPtr[CefCookieVisitor] visitor)
        cpp_bool VisitUrlCookies(const CefString& url, 
                                 cpp_bool includeHttpOnly,
                                 CefRefPtr[CefCookieVisitor] visitor)
        cpp_bool SetCookie(const CefString& url, const CefCookie& cookie,
                           CefRefPtr[CefSetCookieCallback] callback)
        cpp_bool DeleteCookies(const CefString& url,
                               const CefString& cookie_name,
                               CefRefPtr[CefDeleteCookiesCallback] callback)
        cpp_bool FlushStore(CefRefPtr[CefCompletionCallback] callback)

    cdef cppclass CefCookieVisitor:
        pass

    cdef cppclass CefSetCookieCallback:
        pass

    cdef cppclass CefDeleteCookiesCallback:
        pass
