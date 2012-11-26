# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from stddef cimport wchar_t

cdef extern from "Windows.h":

	ctypedef void* HANDLE
	ctypedef HANDLE HWND
	ctypedef unsigned int UINT
	ctypedef char* LPCTSTR
	ctypedef int BOOL
	ctypedef unsigned long DWORD

	ctypedef struct RECT:
		long left
		long top
		long right
		long bottom
	ctypedef RECT* LPRECT
	
	cdef HWND FindWindowA(LPCTSTR, LPCTSTR)	
	
	cdef int CP_UTF8
	cdef int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)
	cdef int MultiByteToWideChar(int, int, char*, int, wchar_t*, int)
	
	ctypedef void* HDWP
	cdef int SWP_NOZORDER
	cdef HDWP BeginDeferWindowPos(int nNumWindows)	
	cdef HDWP DeferWindowPos(HDWP hWinPosInfo, HWND hWnd, HWND hWndInsertAfter, int x, int y, int cx, int cy, UINT uFlags)
	cdef BOOL EndDeferWindowPos(HDWP hWinPosInfo)

	cdef BOOL GetClientRect(HWND hWnd, LPRECT lpRect)

	ctypedef unsigned int WPARAM
	ctypedef unsigned int LPARAM
	cdef int WM_SETFOCUS
	cdef BOOL PostMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)

	ctypedef unsigned int UINT_PTR
	ctypedef unsigned int UINT
	ctypedef struct TIMERPROC:
		pass
	cdef UINT_PTR SetTimer(HWND hwnd, UINT_PTR nIDEvent, UINT uElapse, TIMERPROC lpTimerFunc)
	cdef int USER_TIMER_MINIMUM

	# Detecting 64bit platform in an IF condition not required, see:
	# https://groups.google.com/d/msg/cython-users/qb6VAR4OUms/HcLGwKwkwCgJ
	ctypedef long LONG_PTR 
	
	ctypedef LONG_PTR LRESULT	
	ctypedef long LONG
	cdef BOOL IsZoomed(HWND hWnd)
	cdef LRESULT SendMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
	cdef UINT WM_SYSCOMMAND
	cdef UINT SC_RESTORE
	cdef UINT SC_MAXIMIZE
	cdef int GWL_STYLE
	cdef int GWL_EXSTYLE
	LONG GetWindowLong(HWND hWnd, int nIndex)
	LONG SetWindowLong(HWND hWnd, int nIndex, LONG dwNewLong)
	BOOL GetWindowRect(HWND hWnd, LPRECT lpRect)
	cdef int WS_CAPTION
	cdef int WS_THICKFRAME
	cdef int WS_EX_DLGMODALFRAME
	cdef int WS_EX_WINDOWEDGE
	cdef int WS_EX_CLIENTEDGE
	cdef int WS_EX_STATICEDGE
	cdef int MONITOR_DEFAULTTONEAREST
	ctypedef HANDLE HMONITOR
	ctypedef struct MONITORINFO:
		DWORD cbSize
		RECT  rcMonitor
		RECT  rcWork
		DWORD dwFlags
	ctypedef MONITORINFO* LPMONITORINFO
	HMONITOR MonitorFromWindow(HWND hwnd, DWORD dwFlags)
	BOOL GetMonitorInfo(HMONITOR hMonitor, LPMONITORINFO lpmi)
	BOOL SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int X, int Y, int cx, int cy, UINT uFlags)
	cdef int SWP_NOZORDER
	cdef int SWP_NOACTIVATE
	cdef int SWP_FRAMECHANGED