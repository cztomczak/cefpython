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

cdef extern from "include/cef_browser.h":
	
	cdef cppclass CefBrowser:
		
		void ParentWindowWillClose()
		void CloseBrowser()
		windows.HWND GetWindowHandle()
		
		void ShowDevTools()
		void CloseDevTools()


cdef extern from "include/cef_browser.h" namespace "CefBrowser":
	
	# Namespace is also a way to import a static method.	
	cdef cef_ptr.CefRefPtr[CefBrowser] CreateBrowserSync(
		cef_win.CefWindowInfo, 
		cef_ptr.CefRefPtr[cef_client.CefClient], 
		cef_string.CefString,
		cef_type_wrappers.CefBrowserSettings)
