# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cpp_bool
cimport cef_types

cdef extern from "include/cef_task.h":
    ctypedef int CefThreadId
    cdef cpp_bool CefCurrentlyOn(CefThreadId)
    ctypedef cef_types.cef_thread_id_t CefThreadId
