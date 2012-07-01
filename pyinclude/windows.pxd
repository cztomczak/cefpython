# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from stddef cimport wchar_t

cdef extern from "windows.h":
	ctypedef void *HWND
	ctypedef struct RECT:
		long left
		long top
		long right
		long bottom
	ctypedef char* LPCTSTR
	cdef HWND FindWindowA(LPCTSTR, LPCTSTR)
	cdef int CP_UTF8
	cdef int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)
