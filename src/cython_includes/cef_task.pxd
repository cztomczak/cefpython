# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cpp_bool
cimport cef_types
from cef_ptr cimport CefRefPtr

cdef extern from "include/cef_task.h":
    ctypedef int CefThreadId
    ctypedef cef_types.cef_thread_id_t CefThreadId
    
    cdef cpp_bool CefCurrentlyOn(CefThreadId)
    cdef cpp_bool CefPostTask(CefThreadId threadId, CefRefPtr[CefTask] task)
    
    cdef cppclass CefTask:
        pass

