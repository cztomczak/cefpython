# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "javascriptbindings.pyx"

# Global variables.

cdef map[int, CefRefPtr[CefBrowser]] __cefBrowsers # innerWindowID : browser # a pointer would be: new map[int, CefRefPtr[CefBrowser]]()
__pyBrowsers = {}

# This dictionary list of popup browsers is never cleaned, it may contain old inner
# window ID's as keys. Popup window might be created via window.open() and
# we have no control over it. This list of popup browsers is for GetPyBrowserByCefBrowser()
# so that we cache PyBrowser() objects, as there might a lot of LoadHandler events
# that call this function and instantiating a new class for each of these events is too much overhead.
__popupPyBrowsers = {} # Just a cache.

__browserInnerWindows = {} # topWindowID : innerWindowID (CefBrowser.GetWindowHandle)

# PyBrowser.

class PyBrowser:

	__topWindowID = 0
	__innerWindowID = 0
	__clientHandlers = {} # Dictionary.
	__javascriptBindings = None # JavascriptBindings class.
	
	def __init__(self, topWindowID, innerWindowID, clientHandlers={}, javascriptBindings=None):

		self.__topWindowID = topWindowID
		self.__innerWindowID = innerWindowID
		clientHandlers = clientHandlers if clientHandlers else {}
		javascriptBindings = javascriptBindings if javascriptBindings else None
		assert win32gui.IsWindow(innerWindowID), "Invalid window handle (innerWindowID)"

		cdef CefRefPtr[CefBrowser] cefBrowser
		if -1 != self.__topWindowID:
			# We do this check only for non-popup windows.
			
			# Functions in this class can be called only if topWindowID is set, as they call
			# GetCefBrowserByInnerWindowID() and this one uses __cefBrowsers[] which
			# are set only when creating Browser objects explicitily and topWindowID's are
			# provided.
			
			# Handlers are empty for popup windows, so LoadHandler() and others won't
			# call any of the functions in this object, they just need the object to check
			# whether handler exists for given event.

			# This object is instantiated because Handlers are binded to ClientHandler which
			# is a global object and is automatically inherited by implicitily created popup
			# browser windows.

			cefBrowser = GetCefBrowserByInnerWindowID(self.__innerWindowID)
			assert <void*>cefBrowser != NULL, "CefBrowser not found for this innerWindowID: %s" % self.__innerWindowID
		
		self.__checkClientHandlers(clientHandlers)
		self.__clientHandlers = clientHandlers

		self.__checkJavascriptBindings(javascriptBindings)
		self.__javascriptBindings = javascriptBindings

	def __checkJavascriptBindings(self, bindings):

		if not bindings:
			return
		if not isinstance(bindings, JavascriptBindings):
			raise Exception("Creating PyBrowser() failed: javascriptBindings is not a JavascriptBindings class.")

	def __checkClientHandlers(self, handlers):

		# handlers["OnLoadStart"] = StartFunc
		# handlers["OnLoadEnd"] = (EndFunc, None, EndFunc)
		# tuple[0] - the handler to call for the main frame.
		# tuple[1] - the handler to call for the inner frames.
		# tuple[2] - the handler to call for the popups.

		allowedHandlers = []
		
		# CefLoadHandler.
		allowedHandlers += ["OnLoadEnd", "OnLoadError", "OnLoadStart"]
		# CefKeyboardHandler.
		allowedHandlers += ["OnKeyEvent"]

		for key in handlers:
			handler = handlers[key]
			if type(handler) == tuple and len(handler) != 3:
				raise Exception("PyBrowser.__init__() failed: invalid client handler, tuple's length must be 3. Key=%s", key)
			if key not in allowedHandlers:
				raise Exception("Unknown handler: %s, mistyped?" % key)

	# Internal.
	def IsPopup(self):

		# TODO: implement LifeSpanHandler.OnBeforePopup() to detect popups.
		return self.__topWindowID == -1

	# Internal.
	def GetJavascriptBindings(self):

		return self.__javascriptBindings

	# Internal.
	def GetClientHandler(self, name):

		if name in self.__clientHandlers:
			return self.__clientHandlers[name]

	# Internal.
	def GetClientHandlers(self):

		return self.__clientHandlers

	# PUBLIC API.

	def CanGoBack(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef cbool canGoBack = (<CefBrowser*>(cefBrowser.get())).CanGoBack()
		return canGoBack

	def CanGoForward(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef cbool canGoForward = (<CefBrowser*>(cefBrowser.get())).CanGoForward()
		return canGoForward

	def ClearHistory(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ClearHistory()

	def CloseBrowser(self):

		global __cefBrowsers
		global __pyBrowsers
		global __browserInnerWindows

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		__cefBrowsers.erase(<int>self.__innerWindowID)
		del __pyBrowsers[self.__innerWindowID]
		
		# -1 == Popup, the window wasn't created by us, so we don't have the topWindowID.
		# See -1 value in GetPyBrowserByCefBrowser().
		if -1 != self.__topWindowID:
			del __browserInnerWindows[self.__topWindowID]

		self.__topWindowID = 0
		self.__innerWindowID = 0
		(<CefBrowser*>(cefBrowser.get())).ParentWindowWillClose()

		# This is probably not needed, turning it off, maybe it will fix memory read errors when closing app?
		#(<CefBrowser*>(cefBrowser.get())).CloseBrowser()

	def CloseDevTools(self):
		
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).CloseDevTools()

	def Find(self, searchID, searchText, forward, matchCase, findNext):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))

		cdef CefString cefSearchText
		PyStringToCefString(searchText, cefSearchText)

		(<CefBrowser*>(cefBrowser.get())).Find(
			<int>searchID, cefSearchText, <cbool>bool(forward), <cbool>bool(matchCase), <cbool>bool(findNext))

	def GetFocusedFrame(self):

		assert CurrentlyOn(TID_UI), "Browser.GetFocusedFrame() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFocusedFrame()
		
		return GetPyFrameByCefFrame(cefFrame)

	def GetFrame(self, name):

		assert CurrentlyOn(TID_UI), "Browser.GetFrame() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		
		cdef CefString cefName
		PyStringToCefString(name, cefName)
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFrame(cefName)
		
		return GetPyFrameByCefFrame(cefFrame) # may return None.

	def GetFrameNames(self):

		assert CurrentlyOn(TID_UI), "Browser.GetFrameNames() should only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))

		cdef vector[CefString] cefNames
		(<CefBrowser*>(cefBrowser.get())).GetFrameNames(cefNames)

		names = []
		cdef vector[CefString].iterator iterator = cefNames.begin()
		cdef CefString cefString
		while iterator != cefNames.end():
			cefString = deref(iterator)
			names.append(CefStringToPyString(cefString))
			preinc(iterator)

		return names

	def GetMainFrame(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetMainFrame()
		
		return GetPyFrameByCefFrame(cefFrame)

	def GetOpenerWindowID(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef HWND hwnd = (<CefBrowser*>(cefBrowser.get())).GetOpenerWindowHandle()
		openerID = <int>hwnd
		
		if openerID:
			assert win32gui.IsWindow(openerID), "CefBrowser.GetOpenerWindowHandle() returned invalid handle"
			return openerID
		
		return None

	def GetWindowID(self):

		# Call this function to see whether Browser object is still valid, if topWindowID == 0 then invalid.
		return self.__topWindowID

	def GetZoomLevel(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef double zoomLevel = (<CefBrowser*>(cefBrowser.get())).GetZoomLevel()
		return zoomLevel

	def GoBack(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).GoBack()

	def GoForward(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).GoForward()

	def HasDocument(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		return (<CefBrowser*>(cefBrowser.get())).HasDocument()


	def HidePopup(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).HidePopup()



	# ----------------------

	

	
	def SetZoomLevel(self, zoomLevel):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).SetZoomLevel(<double>float(zoomLevel))
	

	def ShowDevTools(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ShowDevTools()

	

	

	

	

	

	def Reload(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).Reload()

	def ReloadIgnoreCache(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ReloadIgnoreCache()

	def StopLoad(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).StopLoad()

	def IsPopup(self):

		pass


	