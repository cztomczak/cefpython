# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cimport windows
cimport cef_ptr
cimport cef_win
cimport cef_string
cimport cef_client
cimport cef_type_wrappers
from libcpp cimport bool as cbool
from libcpp.vector cimport vector
cimport cef_frame

cdef extern from "include/cef_browser.h":
	
	cdef cppclass CefBrowser:
		
		void ParentWindowWillClose()
		void CloseBrowser()
		windows.HWND GetWindowHandle()
		windows.HWND GetOpenerWindowHandle()
		
		void ShowDevTools()
		void CloseDevTools()
		
		cbool CanGoBack()
		void GoBack()
		cbool CanGoForward()
		void GoForward()
		void Reload()
		void ReloadIgnoreCache()
		void StopLoad()

		cbool IsPopup()
		cbool HasDocument()
		cef_ptr.CefRefPtr[cef_frame.CefFrame] GetMainFrame()
		cef_ptr.CefRefPtr[cef_frame.CefFrame] GetFocusedFrame()
		cef_ptr.CefRefPtr[cef_frame.CefFrame] GetFrame(cef_string.CefString& name)
		void GetFrameNames(vector[cef_string.CefString]& names)


cdef extern from "include/cef_browser.h" namespace "CefBrowser":
	
	# Namespace is also a way to import a static method.	
	cdef cef_ptr.CefRefPtr[CefBrowser] CreateBrowserSync(
		cef_win.CefWindowInfo, 
		cef_ptr.CefRefPtr[cef_client.CefClient], 
		cef_string.CefString,
		cef_type_wrappers.CefBrowserSettings)
