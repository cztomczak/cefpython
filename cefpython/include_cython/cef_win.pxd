# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from windows cimport HWND, RECT, HINSTANCE
from Cython.Shadow import void
from cef_types_wrappers cimport CefStructBase

cdef extern from "include/internal/cef_win.h":
	
	ctypedef HWND CefWindowHandle
	
	cdef cppclass CefWindowInfo:
		void SetAsChild(HWND, RECT)
		void SetAsOffScreen(HWND)
		HWND m_hWndParent
		HWND m_hWnd
		int m_x
		int m_y
		int m_nWidth
		int m_nHeight

	IF CEF_VERSION == 3:
		cdef cppclass CefMainArgs(CefStructBase):
			CefMainArgs()
			CefMainArgs(HINSTANCE hInstance)
