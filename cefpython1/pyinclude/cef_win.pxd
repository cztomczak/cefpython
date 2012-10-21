# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from windows cimport HWND, RECT
from Cython.Shadow import void

cdef extern from "include/internal/cef_win.h":
	ctypedef void* CefWindowHandle
	cdef cppclass CefWindowInfo:
		void SetAsChild(HWND, RECT)
		void SetAsOffScreen(HWND)
		HWND m_hWndParent
		HWND m_hWnd
		int m_x
		int m_y
		int m_nWidth
		int m_nHeight
