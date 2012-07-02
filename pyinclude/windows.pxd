# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from stddef cimport wchar_t

cdef extern from "Windows.h":
	
	ctypedef void* HWND
	ctypedef unsigned int UINT
	ctypedef char* LPCTSTR
	ctypedef int BOOL

	ctypedef struct RECT:
		long left
		long top
		long right
		long bottom
	ctypedef RECT* LPRECT
	
	cdef HWND FindWindowA(LPCTSTR, LPCTSTR)	
	
	cdef int CP_UTF8
	cdef int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)
	
	ctypedef void* HDWP
	cdef int SWP_NOZORDER
	cdef HDWP BeginDeferWindowPos(int nNumWindows)	
	cdef HDWP DeferWindowPos(HDWP hWinPosInfo, HWND hWnd, HWND hWndInsertAfter, int x, int y, int cx, int cy, UINT uFlags)
	cdef BOOL EndDeferWindowPos(HDWP hWinPosInfo)

	cdef BOOL GetClientRect(HWND hWnd, LPRECT lpRect)

