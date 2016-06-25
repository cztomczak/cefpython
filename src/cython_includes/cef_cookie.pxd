# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport cef_string_t
from libcpp cimport bool as cpp_bool
from cef_time cimport cef_time_t
from libcpp.vector cimport vector as cpp_vector
from cef_string cimport CefString
from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_callback cimport CefCompletionCallback

cdef extern from "include/cef_cookie.h":
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

    cdef CefRefPtr[CefCookieManager] CefCookieManager_GetGlobalManager \
            "CefCookieManager::GetGlobalManager"(
                CefRefPtr[CefCompletionCallback] callback)
    cdef CefRefPtr[CefCookieManager] CefCookieManager_CreateManager \
            "CefCookieManager::CreateManager"(
                const CefString& path,
                cpp_bool persist_session_cookies,
                CefRefPtr[CefCompletionCallback] callback)
    cdef cppclass CefCookieManager:
        void SetSupportedSchemes(const cpp_vector[CefString]& schemes,
                                 CefRefPtr[CefCompletionCallback] callback)
        cpp_bool VisitAllCookies(CefRefPtr[CefCookieVisitor] visitor)
        cpp_bool VisitUrlCookies(const CefString& url, 
                                 cpp_bool includeHttpOnly,
                                 CefRefPtr[CefCookieVisitor] visitor)
        cpp_bool SetCookie(const CefString& url, const CefCookie& cookie,
                           CefRefPtr[CefSetCookieCallback] callback)
        cpp_bool DeleteCookies(const CefString& url,
                               const CefString& cookie_name,
                               CefRefPtr[CefDeleteCookiesCallback] callback)
        cpp_bool SetStoragePath(const CefString& path,
                                cpp_bool persist_session_cookies,
                                CefRefPtr[CefCompletionCallback] callback)
        # cpp_bool FlushStore(CefRefPtr[CefCompletionCallback] handler)

    cdef cppclass CefCookieVisitor:
        pass

    cdef cppclass CefSetCookieCallback:
        pass

    cdef cppclass CefDeleteCookiesCallback:
        pass
