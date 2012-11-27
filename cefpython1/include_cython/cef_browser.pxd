# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "platform.pxi"

from cef_ptr cimport CefRefPtr
IF UNAME_SYSNAME == "Windows":
	from cef_win cimport CefWindowHandle, CefWindowInfo
from cef_string cimport CefString
from cef_client cimport CefClient
from cef_types_wrappers cimport CefSettings, CefBrowserSettings
from libcpp cimport bool as c_bool
from libcpp.vector cimport vector as c_vector
from cef_frame cimport CefFrame

cdef extern from "include/cef_browser.h":
	
	cdef cppclass CefBrowser:

		c_bool CanGoBack()
		c_bool CanGoForward()
		void ClearHistory()
		void CloseBrowser()
		void CloseDevTools()
		void Find(int identifier, CefString& searchText, c_bool forward, c_bool matchCase, c_bool findNext)
		CefRefPtr[CefFrame] GetFocusedFrame()
		CefRefPtr[CefFrame] GetFrame(CefString& name)
		void GetFrameNames(c_vector[CefString]& names)
		CefRefPtr[CefFrame] GetMainFrame()
		CefWindowHandle GetOpenerWindowHandle()
		CefWindowHandle GetWindowHandle()
		double GetZoomLevel()
		void GoBack()
		void GoForward()
		c_bool HasDocument()
		void HidePopup()
		c_bool IsPopup()
		void ParentWindowWillClose()
		void Reload()
		void ReloadIgnoreCache()
		void SetFocus(c_bool enable)
		void SetZoomLevel(double zoomLevel)
		void ShowDevTools()		
		void StopLoad()
		void StopFinding(c_bool clearSelection)
		c_bool IsWindowRenderingDisabled()
		c_bool IsPopupVisible()

cdef extern from "include/cef_browser.h" namespace "CefBrowser":
	
	# Namespace is also a way to import a static method.	
	cdef CefRefPtr[CefBrowser] CreateBrowserSync(
		CefWindowInfo, 
		CefRefPtr[CefClient], 
		CefString,
		CefBrowserSettings)
