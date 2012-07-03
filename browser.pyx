# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class Browser:
	
	windowID = 0
	
	def __init__(self, windowID):
		
		self.windowID = windowID
		assert win32gui.IsWindow(windowID), "Invalid window handle (windowID)"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(self.windowID)
		assert <void*>cefBrowser != NULL, "CefBrowser not found for this window handle (windowID)"

	def GetWindowID(self):

		# Call this function to see whether Browser object is still valid, if windowID == 0 then invalid.
		return self.windowID

	def CloseBrowser(self):

		assert self.windowID, "Browser was destroyed earlier"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(self.windowID)
		assert <void*>cefBrowser != NULL, "CefBrowser not found, destroyed?"

		if __debug: print "CefBrowser.ParentWindowWillClose()"
		(<CefBrowser*>(cefBrowser.get())).ParentWindowWillClose()
		
		if __debug: print "CefBrowser.CloseBrowser()"
		(<CefBrowser*>(cefBrowser.get())).CloseBrowser()
		
		__cefBrowsers.erase(<int>self.windowID)
		del __pyBrowsers[self.windowID]
		self.windowID = 0

	def ShowDevTools(self):

		assert self.windowID, "Browser was destroyed earlier"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(self.windowID)
		assert <void*>cefBrowser != NULL, "CefBrowser not found, destroyed?"
		
		(<CefBrowser*>(cefBrowser.get())).ShowDevTools()

	def CloseDevTools(self):
		
		assert self.windowID, "Browser was destroyed earlier"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(self.windowID)
		assert <void*>cefBrowser != NULL, "CefBrowser not found, destroyed?"

		(<CefBrowser*>(cefBrowser.get())).CloseDevTools()

