# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_task cimport CefTask
from cef_string cimport CefString
from cef_cookie cimport CefCookie, CefCookieManager
# noinspection PyUnresolvedReferences
from cef_cookie cimport CefSetCookieCallback, CefDeleteCookiesCallback
# noinspection PyUnresolvedReferences
from libcpp cimport bool as cpp_bool
from libc.stdint cimport int64_t


cdef extern from "client_handler/task.h":

    void PostTaskWrapper(int threadId, int taskId) nogil
    void PostDelayedTaskWrapper(int threadId, int64_t delay_ms, int taskId) nogil

    cdef CefRefPtr[CefTask] CreateTask_SetCookie(
            CefCookieManager* obj,
            const CefString& url,
            const CefCookie& cookie,
            CefRefPtr[CefSetCookieCallback] callback)

    cdef CefRefPtr[CefTask] CreateTask_DeleteCookies(
            CefCookieManager* obj,
            const CefString& url,
            const CefString& cookie_name,
            CefRefPtr[CefDeleteCookiesCallback] callback)
