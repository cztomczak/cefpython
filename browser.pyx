# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class Browser:
	
	windowID = 0
	
	# This is required for weakref.ref() to work.
	__slots__ = ["GetWindowID", "CloseBrowser"]
	
	def __init__(self, inWindowID):
		
		self.windowID = inWindowID

	def GetWindowID(self):

		# Call this function to see whether Browser object is still valid, if windowID == 0 then invalid.
		return self.windowID

	def CloseBrowser(self):

		# weakref.proxy() or checks like this in every method?
		if not self.windowID:
			raise Exception("Browser.CloseBrowser(): browser is already closed")

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(self.windowID)
		if <void*>cefBrowser == NULL:
			return

		if __debug: print "CefBrowser.ParentWindowWillClose()"
		(<CefBrowser*>(cefBrowser.get())).ParentWindowWillClose()
		
		if __debug: print "CefBrowser.CloseBrowser()"
		(<CefBrowser*>(cefBrowser.get())).CloseBrowser()
		
		__cefBrowsers.erase(<int>self.windowID)
		del __pyBrowsers[self.windowID]
		self.windowID = 0
