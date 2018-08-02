# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
from cef_string cimport CefString
from cef_cookie cimport CefCookie
# noinspection PyUnresolvedReferences
from cef_cookie cimport CefSetCookieCallback, CefDeleteCookiesCallback
from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_callback cimport CefCompletionCallback

# We need to pass C++ class methods by reference to a function,
# it is not possible with such syntax:
# | &CefCookieManager.SetCookie
# We had to create this addional pxd file so we can pass it like this:
# | &cef_cookie_manager_namespace.SetCookie
# In cookie.pyx > PyCookieManager.SetCookie().
# See this topic:
# https://groups.google.com/d/topic/cython-users/G-vEdIkmNNY/discussion

cdef extern from "include/cef_cookie.h" namespace "CefCookieManager":

    cpp_bool SetCookie(const CefString& url, const CefCookie& cookie,
                       CefRefPtr[CefSetCookieCallback] callback)

    cpp_bool DeleteCookies(const CefString& url,
                           const CefString& cookie_name,
                           CefRefPtr[CefDeleteCookiesCallback] callback)

    cpp_bool FlushStore(CefRefPtr[CefCompletionCallback] callback)
