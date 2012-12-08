# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from stddef cimport wchar_t

cdef extern from "Windows.h":

    ctypedef void* HANDLE
    ctypedef HANDLE HWND
    ctypedef HANDLE HINSTANCE
    ctypedef unsigned int UINT
    ctypedef char* LPCTSTR
    ctypedef int BOOL
    ctypedef unsigned long DWORD

    HINSTANCE GetModuleHandle(LPCTSTR lpModuleName)

    ctypedef struct RECT:
        long left
        long top
        long right
        long bottom
    ctypedef RECT* LPRECT

    HWND FindWindowA(LPCTSTR, LPCTSTR)

    int CP_UTF8
    int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)
    int MultiByteToWideChar(int, int, char*, int, wchar_t*, int)

    ctypedef void* HDWP
    int SWP_NOZORDER
    HDWP BeginDeferWindowPos(int nNumWindows)
    HDWP DeferWindowPos(HDWP hWinPosInfo, HWND hWnd, HWND hWndInsertAfter, int x, int y, int cx, int cy, UINT uFlags)
    BOOL EndDeferWindowPos(HDWP hWinPosInfo)

    BOOL GetClientRect(HWND hWnd, LPRECT lpRect)

    ctypedef unsigned int WPARAM
    ctypedef unsigned int LPARAM
    int WM_SETFOCUS
    BOOL PostMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)

    ctypedef unsigned int UINT_PTR
    ctypedef unsigned int UINT
    ctypedef struct TIMERPROC:
        pass
    UINT_PTR SetTimer(HWND hwnd, UINT_PTR nIDEvent, UINT uElapse, TIMERPROC lpTimerFunc)
    int USER_TIMER_MINIMUM

    # Detecting 64bit platform in an IF condition not required, see:
    # https://groups.google.com/d/msg/cython-users/qb6VAR4OUms/HcLGwKwkwCgJ
    ctypedef long LONG_PTR

    ctypedef LONG_PTR LRESULT
    ctypedef long LONG
    BOOL IsZoomed(HWND hWnd)
    LRESULT SendMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
    UINT WM_SYSCOMMAND
    UINT SC_RESTORE
    UINT SC_MAXIMIZE
    int GWL_STYLE
    int GWL_EXSTYLE
    LONG GetWindowLong(HWND hWnd, int nIndex)
    LONG SetWindowLong(HWND hWnd, int nIndex, LONG dwNewLong)
    BOOL GetWindowRect(HWND hWnd, LPRECT lpRect)
    int WS_CAPTION
    int WS_THICKFRAME
    int WS_EX_DLGMODALFRAME
    int WS_EX_WINDOWEDGE
    int WS_EX_CLIENTEDGE
    int WS_EX_STATICEDGE
    int MONITOR_DEFAULTTONEAREST
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
    int SWP_NOZORDER
    int SWP_NOACTIVATE
    int SWP_FRAMECHANGED

    DWORD GetLastError()
    BOOL IsWindow(HWND hWnd)
