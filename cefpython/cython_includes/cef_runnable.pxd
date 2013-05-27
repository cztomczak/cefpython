# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_task cimport CefTask
from cef_string cimport CefString
from cef_cookie cimport CefCookie, CefCookieManager
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_runnable.h":
    # Cython 0.19.1 does not allow template functions, only template
    # classes are supported, thus we need to wrap each type of call
    # to NewCefRunnableMethod(). There is a CefRunnableMethod template
    # class that could be wrapped, but it depends on MakeTuple() 
    # template function.

    # Wrapping NewCefRunnableMethod() for CefCookieManager.SetCookie().
    ctypedef cpp_bool (*SetCookie_type)(const CefString& url, 
            const CefCookie& cookie)
    cdef CefRefPtr[CefTask] NewCefRunnableMethod(
            CefCookieManager* obj, 
            SetCookie_type method,
            const CefString& url,
            const CefCookie& cookie)

    # Wrapping NewCefRunnableMethod() for CefCookieManager.DeleteCookies().
    ctypedef cpp_bool (*DeleteCookies_type)(const CefString& url,
            const CefString& cookie_name)
    cdef CefRefPtr[CefTask] NewCefRunnableMethod(
            CefCookieManager* obj,
            DeleteCookies_type method,
            const CefString& url,
            const CefString& cookie_name)
