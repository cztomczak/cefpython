# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
# noinspection PyUnresolvedReferences
from cef_task cimport CefTask
from cef_string cimport CefString
from cef_cookie cimport CefCookie, CefCookieManager
# noinspection PyUnresolvedReferences
from cef_cookie cimport CefSetCookieCallback, CefDeleteCookiesCallback
# noinspection PyUnresolvedReferences
from libcpp cimport bool as cpp_bool


cdef extern from "client_handler/task.h":

    void PostTaskWrapper(int threadId, int taskId) nogil

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
