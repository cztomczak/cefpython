# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cbool

cdef extern from "include/cef_task.h":
	ctypedef int CefThreadId
	cdef cbool CefCurrentlyOn(CefThreadId)
