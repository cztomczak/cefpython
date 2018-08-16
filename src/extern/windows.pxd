# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libc.stddef cimport wchar_t

cdef extern from *:
    ctypedef char const_char "const char"
    # noinspection PyUnresolvedReferences
    ctypedef wchar_t const_wchar_t "const wchar_t"

cdef extern from "stdio.h" nogil:
    cdef int printf(const_char* TEMPLATE, ...)
    cdef int wprintf(const_wchar_t* TEMPLATE, ...)

cdef extern from "Windows.h" nogil:
    ctypedef void* HANDLE
    ctypedef HANDLE HWND
    ctypedef HANDLE HINSTANCE
    ctypedef HANDLE HICON
    ctypedef HANDLE HDC
    ctypedef HANDLE HBITMAP
    ctypedef HICON HCURSOR

    ctypedef unsigned int UINT
    ctypedef unsigned int UINT_PTR

    # noinspection PyUnresolvedReferences
    ctypedef wchar_t* LPCTSTR
    # noinspection PyUnresolvedReferences
    ctypedef wchar_t* LPTSTR
    ctypedef int BOOL
    ctypedef unsigned long DWORD
    ctypedef unsigned short WORD

    cdef HINSTANCE GetModuleHandle(LPCTSTR lpModuleName)

    ctypedef struct RECT:
        long left
        long top
        long right
        long bottom
    ctypedef RECT* LPRECT

    cdef UINT CP_UTF8
    cdef UINT CP_ACP
    cdef DWORD WC_COMPOSITECHECK
    cdef int WideCharToMultiByte(int, int, wchar_t*, int, char*, int, char*, int*)
    cdef DWORD MB_COMPOSITE
    cdef int MultiByteToWideChar(int, int, char*, int, wchar_t*, int)
    cdef size_t mbstowcs(wchar_t *wcstr, const_char *mbstr, size_t count)

    ctypedef void* HDWP

    cdef int SWP_NOZORDER
    cdef int SWP_NOACTIVATE
    cdef int SWP_FRAMECHANGED

    cdef HDWP BeginDeferWindowPos(int nNumWindows)
    cdef HDWP DeferWindowPos(
            HDWP hWinPosInfo, HWND hWnd, HWND hWndInsertAfter,
            int x, int y, int cx, int cy, UINT uFlags)
    cdef BOOL EndDeferWindowPos(HDWP hWinPosInfo)

    cdef BOOL GetClientRect(HWND hWnd, LPRECT lpRect)

    ctypedef unsigned int WPARAM
    ctypedef unsigned int LPARAM
    cdef UINT WM_SETFOCUS
    cdef BOOL PostMessage(
            HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)

    ctypedef struct TIMERPROC:
        pass
    cdef UINT_PTR SetTimer(
            HWND hwnd, UINT_PTR nIDEvent, UINT uElapse, TIMERPROC lpTimerFunc)
    cdef int USER_TIMER_MINIMUM

    # Detecting 64bit platform in an IF condition not required, see:
    # https://groups.google.com/d/msg/cython-users/qb6VAR4OUms/HcLGwKwkwCgJ
    ctypedef long LONG_PTR

    ctypedef LONG_PTR LRESULT
    ctypedef long LONG
    cdef BOOL IsZoomed(HWND hWnd)
    cdef LRESULT SendMessage(
            HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
    cdef UINT WM_SYSCOMMAND
    cdef UINT SC_RESTORE
    cdef UINT SC_MAXIMIZE
    cdef int GWL_STYLE
    cdef int GWL_EXSTYLE
    cdef LONG GetWindowLong(HWND hWnd, int nIndex)
    cdef LONG SetWindowLong(HWND hWnd, int nIndex, LONG dwNewLong)
    cdef BOOL GetWindowRect(HWND hWnd, LPRECT lpRect)
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
    cdef HMONITOR MonitorFromWindow(HWND hwnd, DWORD dwFlags)
    cdef BOOL GetMonitorInfo(HMONITOR hMonitor, LPMONITORINFO lpmi)
    cdef BOOL SetWindowPos(
            HWND hWnd, HWND hWndInsertAfter,
            int X, int Y, int cx, int cy, UINT uFlags)

    cdef DWORD GetLastError()
    cdef BOOL IsWindow(HWND hWnd)

    cdef LRESULT DefWindowProc(
            HWND hWnd,  UINT Msg, WPARAM wParam, LPARAM lParam)

    cdef int GetWindowTextW(HWND hWnd, wchar_t* lpString, int nMaxCount)
    cdef BOOL SetWindowTextW(HWND hWnd, wchar_t* lpString)

    cdef UINT WM_GETICON
    cdef UINT WM_SETICON
    cdef int ICON_BIG
    cdef int ICON_SMALL
    cdef HWND GetParent(HWND hwnd)

    cdef int MulDiv(int number, int numerator, int denominator)

