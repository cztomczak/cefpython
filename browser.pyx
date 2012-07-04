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

	def GetOpenerWindowID(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		cdef HWND hwnd = (<CefBrowser*>(cefBrowser.get())).GetOpenerWindowHandle()
		openerID = <int>hwnd
		
		if openerID:
			assert win32gui.IsWindow(openerID), "CefBrowser.GetOpenerWindowHandle() returned invalid handle"
			return openerID
		
		return None

	def CloseBrowser(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).ParentWindowWillClose()
		(<CefBrowser*>(cefBrowser.get())).CloseBrowser()
		__cefBrowsers.erase(<int>self.windowID)
		del __pyBrowsers[self.windowID]
		self.windowID = 0

	def ShowDevTools(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).ShowDevTools()

	def CloseDevTools(self):
		
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).CloseDevTools()

	def CanGoBack(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		cdef cbool canGoBack = (<CefBrowser*>(cefBrowser.get())).CanGoBack()
		return canGoBack

	def GoBack(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).GoBack()

	def CanGoForward(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		cdef cbool canGoForward = (<CefBrowser*>(cefBrowser.get())).CanGoForward()
		return canGoForward

	def GoForward(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).GoForward()

	def Reload(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).Reload()

	def ReloadIgnoreCache(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).ReloadIgnoreCache()

	def StopLoad(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		(<CefBrowser*>(cefBrowser.get())).StopLoad()

	def IsPopup(self):

		pass

	def HasDocument(self):

		pass

	def GetMainFrame(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetMainFrame()

		global __pyFrames
		cdef long long frameID
		if <void*>cefFrame != NULL and <CefFrame*>(cefFrame.get()):
			frameID = (<CefFrame*>(cefFrame.get())).GetIdentifier()
			__cefFrames[frameID] = cefFrame
			pyFrameID = long(frameID)
			print "pyFrameID: %s" % pyFrameID
			if pyFrameID in __pyFrames:
				return __pyFrames[pyFrameID]
			__pyFrames[pyFrameID] = Frame(pyFrameID)
			return __pyFrames[pyFrameID]
	
	def GetFocusedFrame(self):

		assert CurrentlyOn(TID_UI), "Browser.GetFocusedFrame() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFocusedFrame()

		global __pyFrames
		cdef cef_types.int64 frameID
		if <void*>cefFrame != NULL and <CefFrame*>(cefFrame.get()):
			frameID = (<CefFrame*>(cefFrame.get())).GetIdentifier()
			__cefFrames[frameID] = cefFrame
			pyFrameID = long(frameID)
			print "pyFrameID: %s" % pyFrameID
			if pyFrameID in __pyFrames:
				return __pyFrames[pyFrameID]
			__pyFrames[pyFrameID] = Frame(pyFrameID)
			return __pyFrames[pyFrameID]
		
	def GetFrame(self, name):

		assert CurrentlyOn(TID_UI), "Browser.GetFocusedFrame() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))
		
		cdef CefString cefName
		cefName.FromASCII(<char*>name)
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFrame(cefName)

		global __pyFrames
		cdef cef_types.int64 frameID
		if <void*>cefFrame != NULL and <CefFrame*>(cefFrame.get()):
			frameID = (<CefFrame*>(cefFrame.get())).GetIdentifier()
			__cefFrames[frameID] = cefFrame
			pyFrameID = long(frameID)
			if pyFrameID in __pyFrames:
				return __pyFrames[pyFrameID]
			__pyFrames[pyFrameID] = Frame(pyFrameID)
			return __pyFrames[pyFrameID]

	def GetFrameNames(self):

		# Seems not to work! cefNames.size() is always 0
		# Tried on iframe and frameset.

		assert CurrentlyOn(TID_UI), "Browser.GetFrameNames() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByWindowID(CheckWindowID(self.windowID))

		cdef vector[CefString] cefNames
		(<CefBrowser*>(cefBrowser.get())).GetFrameNames(cefNames)
		if __debug: print "GetFrameNames() vector size: %s" % cefNames.size()

		names = []
		cdef vector[CefString].iterator iterator = cefNames.begin()
		cdef CefString cefString
		while iterator != cefNames.end():
			cefString = deref(iterator)
			names.push(CefStringToPyString(cefString))
			preinc(iterator)

		return names

cdef GetPyFrame():
	pass