# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

# Note: pywin32 does not send WM_CREATE message.

# WM_SETFOCUS and others must be in lower or camel case as we import
# declarations from windows.h and "already declared" errors appear.

def wm_SetFocus(windowID, msg, wparam, lparam):
	

	# Browser may already be closed hence the second parameter ignoreError=True,
	# this is happening because we called Browser.CloseBrowser() first and WM_DESTROY
	# to the window later, WM messages are still coming before we send WM_DESTROY.
	
	# Temporarily chaning ignoreError to False, as we call CefBrowser->CloseBrowser() 
	# in PyBrowser->CloseBrowser() and the outcome is that procedures in this file are not called anymore.

	# Problem solved by adding "return win32gui.DefWindowProc()" in CloseApplication().

	cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, False)
	if <void*>cefBrowser == NULL:
		return 0

	cdef HWND innerHwnd = (<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	# wparam,lparam from pywin32 seems to be always 0,0
	PostMessage(innerHwnd, WM_SETFOCUS, 0, 0)

	return 0	

def wm_Size(windowID, msg, wparam, lparam):

	global __debug
	if __debug: print("WM_SIZE")
	
	# Browser may already be closed hence the second parameter ignoreError=True,
	# this is happening because we called Browser.CloseBrowser() first and WM_DESTROY
	# to the window later, WM messages are still coming before we send WM_DESTROY.

	# Temporarily chaning ignoreError to False, as we call CefBrowser->CloseBrowser() 
	# in PyBrowser->CloseBrowser() and the outcome is that procedures in this file are not called anymore.

	# Problem solved by adding "return win32gui.DefWindowProc()" in CloseApplication().

	cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, False)
	if <void*>cefBrowser == NULL:
		return win32gui.DefWindowProc(windowID, msg, wparam, lparam)

	cdef HWND innerHwnd = (<CefBrowser*>(cefBrowser.get())).GetWindowHandle()

	cdef RECT rect2
	# A dangerous cast but this func is called from a trusted place.
	GetClientRect(<HWND><int>windowID, &rect2)

	if __debug: print("rect2: %d %d %d %d" % (rect2.left, rect2.top, rect2.right, rect2.bottom))
	
	cdef HDWP hdwp = BeginDeferWindowPos(<int>1)
	hdwp = DeferWindowPos(hdwp, innerHwnd, NULL, rect2.left, rect2.top, rect2.right - rect2.left, rect2.bottom - rect2.top, SWP_NOZORDER)
	EndDeferWindowPos(hdwp)

	if __debug: print("GetLastError(): %s" % GetLastError())

	return win32gui.DefWindowProc(windowID, msg, wparam, lparam)
	

def wm_EraseBkgnd(windowID, msg, wparam, lparam):
	
	# Browser may already be closed hence the second parameter ignoreError=True,
	# this is happening because we called Browser.CloseBrowser() first and WM_DESTROY
	# to the window later, WM messages are still coming before we send WM_DESTROY.

	# Temporarily chaning ignoreError to False, as we call CefBrowser->CloseBrowser() 
	# in PyBrowser->CloseBrowser() and the outcome is that procedures in this file are not called anymore.

	# Problem solved by adding "return win32gui.DefWindowProc()" in CloseApplication().

	cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, False)
	if <void*>cefBrowser == NULL:
		return win32gui.DefWindowProc(windowID, msg, wparam, lparam)

	cdef HWND innerHwnd = (<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	if innerHwnd:
		return 0 # Dont erase the background if the browser window has been loaded (this avoids flashing)

	return win32gui.DefWindowProc(windowID, msg, wparam, lparam)
