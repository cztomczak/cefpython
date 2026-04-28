# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libc.stddef cimport size_t
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
    ctypedef enum cef_cookie_priority_t:
        CEF_COOKIE_PRIORITY_LOW = -1
        CEF_COOKIE_PRIORITY_MEDIUM = 0
        CEF_COOKIE_PRIORITY_HIGH = 1

    ctypedef enum cef_cookie_same_site_t:
        CEF_COOKIE_SAME_SITE_UNSPECIFIED
        CEF_COOKIE_SAME_SITE_NO_RESTRICTION
        CEF_COOKIE_SAME_SITE_LAX_MODE
        CEF_COOKIE_SAME_SITE_STRICT_MODE
        CEF_COOKIE_SAME_SITE_NUM_VALUES

    ctypedef struct CefCookie:
        size_t size
        cef_string_t name
        cef_string_t value
        cef_string_t domain
        cef_string_t path
        int secure
        int httponly
        cef_basetime_t creation
        cef_basetime_t last_access
        int has_expires
        cef_basetime_t expires
        cef_cookie_same_site_t same_site
        cef_cookie_priority_t priority


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
