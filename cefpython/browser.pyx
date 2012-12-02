# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "javascript_bindings.pyx"

# Global variables.

cdef c_map[int, CefRefPtr[CefBrowser]] g_cefBrowsers # innerWindowID : browser # a pointer would be: new map[int, CefRefPtr[CefBrowser]]()
g_pyBrowsers = {}

# This dictionary list of popup browsers is never cleaned, it may contain old inner
# window ID's as keys. Popup window might be created via window.open() and
# we have no control over it. This list of popup browsers is for GetPyBrowserByCefBrowser()
# so that we cache PyBrowser() objects, as there might a lot of LoadHandler events
# that call this function and instantiating a new class for each of these events is too much overhead.
g_popupPyBrowsers = {} # Just a cache.

g_browserInnerWindows = {} # topWindowID : innerWindowID (CefBrowser.GetWindowHandle)

'''
No need for global variables, code below works.

cdef class MyBrowser:
	
	cdef CefRefPtr[CefBrowser] cefBrowser
	
	def __cinit__(self):
		pass

	def SetCefBrowser(self):
		pass

cdef MyBrowser m = MyBrowser()
m.cefBrowser = g_cefBrowsers[1]

'''

# PyBrowser.

class PyBrowser:

	__topWindowID = 0
	__innerWindowID = 0
	__clientHandlers = {} # Dictionary.
	__javascriptBindings = None # JavascriptBindings class.
	__userData = {}
	
	# Properties used by ToggleFullscreen().
	__isFullscreen = False
	__gwlStyle = 0
	__gwlExStyle = 0
	__windowRect = None
	
	def __init__(self, topWindowID, innerWindowID, clientHandlers=None, javascriptBindings=None):

		self.__topWindowID = topWindowID
		self.__innerWindowID = innerWindowID
		clientHandlers = clientHandlers if clientHandlers else {}
		javascriptBindings = javascriptBindings if javascriptBindings else None
		assert IsWindowHandle(innerWindowID), "Invalid window handle (innerWindowID)"

		cdef CefRefPtr[CefBrowser] cefBrowser
		if -1 != self.__topWindowID:
			# We do this check only for non-popup windows.
			
			# Functions in this class can be called only if topWindowID is set, as they call
			# GetCefBrowserByInnerWindowID() and this one uses g_cefBrowsers[] which
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

		# CefV8ContextHandler.
		allowedHandlers += ["OnUncaughtException"]
		
		# CefRequestHandler.
		allowedHandlers += ["OnBeforeBrowse", "OnBeforeResourceLoad", "OnResourceRedirect", "OnResourceResponse",
						"OnProtocolExecution", "GetDownloadHandler", "GetAuthCredentials", "GetCookieManager"]

		# CefDisplayHandler.
		allowedHandlers += ["OnAddressChange", "OnConsoleMessage", "OnContentsSizeChange", "OnNavStateChange",
						"OnStatusMessage", "OnTitleChange", "OnTooltip"]

		# LifespanHandler.
		allowedHandlers += ["DoClose", "OnAfterCreated", "OnBeforeClose", "RunModal"]

		for key in handlers:
			handler = handlers[key]
			if type(handler) == tuple and len(handler) != 3:
				raise Exception("PyBrowser.__init__() failed: invalid client handler, tuple's length must be 3. Key=%s", key)
			if key not in allowedHandlers:
				raise Exception("Unknown handler: %s, mistyped?" % key)

	# Helper functions, also public:	

	def GetJavascriptBindings(self):

		return self.__javascriptBindings

	def GetClientHandler(self, name):

		if name in self.__clientHandlers:
			return self.__clientHandlers[name]

	def GetClientHandlers(self):

		return self.__clientHandlers

	# --------------
	# PUBLIC API.
	# --------------

	def GetUserData(self, key):

		if key in self.__userData:
			return self.__userData[key]
		return None

	def SetUserData(self, key, value):

		self.__userData[key] = value

	def CanGoBack(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef c_bool canGoBack = (<CefBrowser*>(cefBrowser.get())).CanGoBack()
		return canGoBack

	def CanGoForward(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef c_bool canGoForward = (<CefBrowser*>(cefBrowser.get())).CanGoForward()
		return canGoForward

	def ClearHistory(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ClearHistory()

	def CloseBrowser(self):

		global g_cefBrowsers
		global g_pyBrowsers
		global g_browserInnerWindows

		Debug("Browser.CloseBrowser() called: topWindowID=%s, innerWindowID=%s"
		      % (self.__topWindowID, self.__innerWindowID))

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		g_cefBrowsers.erase(<int>self.__innerWindowID)
		del g_pyBrowsers[self.__innerWindowID]
		
		# -1 == Popup, the window wasn't created by us, so we don't have the topWindowID.
		# See -1 value in GetPyBrowserByCefBrowser().
		if -1 != self.__topWindowID:
			del g_browserInnerWindows[self.__topWindowID]

		self.__topWindowID = 0
		self.__innerWindowID = 0

		# You do not need to call both, call ParentWindowWillClose for the main application window,
		# and CloseBrowser() for popup windows created by CEF. In cefclient/cefclient_win.cpp there
		# is only ParentWindowWillClose() called. CloseBrowser() is called only for popups.

		(<CefBrowser*>(cefBrowser.get())).ParentWindowWillClose() # only for main window that was created explicitily
		# (<CefBrowser*>(cefBrowser.get())).CloseBrowser() # call this only for popups.

	def CloseDevTools(self):
		
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).CloseDevTools()

	def Find(self, searchID, searchText, forward, matchCase, findNext):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))

		cdef CefString cefSearchText
		PyStringToCefString(searchText, cefSearchText)

		(<CefBrowser*>(cefBrowser.get())).Find(
			<int>searchID, cefSearchText, <c_bool>bool(forward), <c_bool>bool(matchCase), <c_bool>bool(findNext))

	def GetFocusedFrame(self):

		assert IsCurrentThread(TID_UI), "Browser.GetFocusedFrame() may only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFocusedFrame()
		
		return GetPyFrameByCefFrame(cefFrame)

	def GetFrame(self, name):

		assert IsCurrentThread(TID_UI), "Browser.GetFrame() may only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		
		cdef CefString cefName
		PyStringToCefString(name, cefName)
		cdef CefRefPtr[CefFrame] cefFrame = (<CefBrowser*>(cefBrowser.get())).GetFrame(cefName)
		
		return GetPyFrameByCefFrame(cefFrame) # may return None.

	def GetFrameNames(self):

		assert IsCurrentThread(TID_UI), "Browser.GetFrameNames() may only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))

		cdef c_vector[CefString] cefNames
		(<CefBrowser*>(cefBrowser.get())).GetFrameNames(cefNames)

		names = []
		cdef c_vector[CefString].iterator iterator = cefNames.begin()
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
			assert IsWindowHandle(openerID), "CefBrowser.GetOpenerWindowHandle() returned invalid handle"
			return openerID
		
		return None

	def GetWindowID(self):

		# TODO: This function may be removed or modified in the future as its acting is confusing at the moment.

		# Returns `windowID` that was passed to [cefpython].`CreateBrowser()`. 
		# Call this method to see whether Browser object still exists, if windowID == 0 
		# then browser was closed. If this is a popup browser the returned value may be 0 or -1.		

		# Call this function to see whether Browser object is still valid, if topWindowID == 0 then invalid.

		return self.__topWindowID

	def GetInnerWindowID(self):

		# TODO: This function may be removed or modified in the future as its acting is confusing at the moment.

		# Returns internal CEF window handle. For a popup this is an outer window.
		# For main window this an inner window contained in top window that you can get by calling !GetWindowID().		

		return self.__innerWindowID

	def GetZoomLevel(self):

		assert IsCurrentThread(TID_UI), "Browser.GetZoomLevel() may only be called on the UI thread"
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

	def IsFullscreen(self):

		return self.__isFullscreen

	def IsPopup(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		return (<CefBrowser*>(cefBrowser.get())).IsPopup()

	def IsPopupVisible(self):

		assert IsCurrentThread(TID_UI), "Browser.IsPopupVisible() may only be called on the UI thread"
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		return (<CefBrowser*>(cefBrowser.get())).IsPopupVisible()

	def IsWindowRenderingDisabled(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		return (<CefBrowser*>(cefBrowser.get())).IsWindowRenderingDisabled()

	def Reload(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).Reload()

	def ReloadIgnoreCache(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ReloadIgnoreCache()

	def SetFocus(self, enable):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).SetFocus(<c_bool>bool(enable))

	def SetZoomLevel(self, zoomLevel):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).SetZoomLevel(<double>float(zoomLevel))
	

	def ShowDevTools(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).ShowDevTools()

	def StopLoad(self):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).StopLoad()

	def StopFinding(self, clearSelection):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByInnerWindowID(CheckInnerWindowID(self.__innerWindowID))
		(<CefBrowser*>(cefBrowser.get())).StopFinding(<c_bool>bool(clearSelection))

	def ToggleFullscreen(self):

		IF UNAME_SYSNAME == "Windows":
			cdef HWND hwnd = <HWND><int>self.GetWindowID()
			cdef RECT rect
			cdef HMONITOR monitor
			cdef MONITORINFO monitorInfo
			monitorInfo.cbSize = sizeof(monitorInfo)

			# Logic copied from chromium > fullscreen_handler.cc > FullscreenHandler::SetFullscreenImpl:
			# http://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc
			for_metro = False
			if not self.__isFullscreen:
				self.__maximized = IsZoomed(hwnd)
				if self.__maximized:
					SendMessage(hwnd, WM_SYSCOMMAND, SC_RESTORE, 0)
				self.__gwlStyle = GetWindowLong(hwnd, GWL_STYLE)
				self.__gwlExStyle = GetWindowLong(hwnd, GWL_EXSTYLE)
				GetWindowRect(hwnd, &rect)
				self.__windowRect = (rect.left, rect.top, rect.right, rect.bottom)
				
			if not self.__isFullscreen:
				remove_style = WS_CAPTION | WS_THICKFRAME
				remove_exstyle = WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE
				SetWindowLong(hwnd, GWL_STYLE, self.__gwlStyle & ~(remove_style))
				SetWindowLong(hwnd, GWL_EXSTYLE, self.__gwlExStyle & ~(remove_exstyle))
				if not for_metro:
					# MONITOR_DEFAULTTONULL, MONITOR_DEFAULTTOPRIMARY, MONITOR_DEFAULTTONEAREST
					monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST)
					GetMonitorInfo(monitor, &monitorInfo)
					left = monitorInfo.rcMonitor.left
					top = monitorInfo.rcMonitor.top
					right = monitorInfo.rcMonitor.right
					bottom = monitorInfo.rcMonitor.bottom
					SetWindowPos(hwnd, NULL, left, top, right-left, bottom-top,
							SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
			else:
				SetWindowLong(hwnd, GWL_STYLE, int(self.__gwlStyle))
				SetWindowLong(hwnd, GWL_EXSTYLE, int(self.__gwlExStyle))
				if not for_metro:
					(left, top, right, bottom) = self.__windowRect
					SetWindowPos(hwnd, NULL, int(left), int(top), int(right-left), int(bottom-top),
							SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
				if self.__maximized:
					SendMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0)

			self.__isFullscreen = not self.__isFullscreen

