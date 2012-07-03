# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cbool
cimport cef_types

cdef extern from "include/cef_task.h":
	ctypedef int CefThreadId
	cdef cbool CefCurrentlyOn(CefThreadId)
	ctypedef cef_types.cef_thread_id_t CefThreadId
