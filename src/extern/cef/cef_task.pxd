# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libcpp cimport bool as cpp_bool
from libc.stdint cimport int64_t
# noinspection PyUnresolvedReferences
cimport cef_types
from cef_ptr cimport CefRefPtr

cdef extern from "include/cef_task.h":
    ctypedef cef_types.cef_thread_id_t CefThreadId
    
    cdef cpp_bool CefCurrentlyOn(CefThreadId)
    cdef cpp_bool CefPostTask(CefThreadId threadId,
                              CefRefPtr[CefTask] task)
    cdef cpp_bool CefPostDelayedTask(CefThreadId threadId,
                                     CefRefPtr[CefTask] task,
                                     int64_t delay_ms)
    
    cdef cppclass CefTask:
        pass

