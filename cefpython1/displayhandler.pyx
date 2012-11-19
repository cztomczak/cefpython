# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

STATUSTYPE_TEXT = <int>cef_types.STATUSTYPE_TEXT
STATUSTYPE_MOUSEOVER_URL = <int>cef_types.STATUSTYPE_MOUSEOVER_URL
STATUSTYPE_KEYBOARD_FOCUS_URL = <int>cef_types.STATUSTYPE_KEYBOARD_FOCUS_URL

cdef public void DisplayHandler_OnAddressChange(CefRefPtr[CefBrowser] cefBrowser,
                               CefRefPtr[CefFrame] cefFrame,
                               CefString& cefURL) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		pyURL = CefStringToPyString(cefURL)
		handler = pyBrowser.GetClientHandler("OnAddressChange")
		if handler:
			handler(pyBrowser, pyFrame, pyURL)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cbool DisplayHandler_OnConsoleMessage(CefRefPtr[CefBrowser] cefBrowser,
                                CefString& cefMessage,
                                CefString& cefSource,
                                int line) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyMessage = CefStringToPyString(cefMessage)
		pySource = CefStringToPyString(cefSource)
		handler = pyBrowser.GetClientHandler("OnConsoleMessage")
		if handler:
			return <cbool>bool(handler(pyBrowser, pyMessage, pySource, line))
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnContentsSizeChange(CefRefPtr[CefBrowser] cefBrowser,
                                    CefRefPtr[CefFrame] cefFrame,
                                    int width,
                                    int height) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True) # 2nd param = ignoreError
		# This is while first browser is being created, PyBrowser() has not yet been created.
		if not pyBrowser:
			return
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		handler = pyBrowser.GetClientHandler("OnContentsSizeChange")
		if handler:
			handler(pyBrowser, pyFrame, width, height)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnNavStateChange(CefRefPtr[CefBrowser] cefBrowser,
                                cbool canGoBack,
                                cbool canGoForward) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)	
		handler = pyBrowser.GetClientHandler("OnNavStateChange")
		if handler:
			handler(pyBrowser, canGoBack, canGoForward)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnStatusMessage(CefRefPtr[CefBrowser] cefBrowser,
                               CefString& cefText,
                               cef_types.cef_handler_statustype_t statusType) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)	
		pyText = CefStringToPyString(cefText)
		handler = pyBrowser.GetClientHandler("OnStatusMessage")
		if handler:
			handler(pyBrowser, pyText, statusType)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnTitleChange(CefRefPtr[CefBrowser] cefBrowser,
                             CefString& cefTitle) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)	
		pyTitle = CefStringToPyString(cefTitle)
		handler = pyBrowser.GetClientHandler("OnTitleChange")
		if handler:
			handler(pyBrowser, pyTitle)
			return
		else:
			EnforceWindowTitle(pyBrowser, pyTitle)		
			EnforceWindowIcon(pyBrowser)
			return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

def EnforceWindowTitle(pyBrowser, pyTitle):

	# Each browser window should have a title (Issue 3).	
	# When popup is created, the window that sits in taskbar has no title.

	if not pyTitle:
		return

	if pyBrowser.IsPopup():
		windowID = pyBrowser.GetInnerWindowID()
	else:
		windowID = pyBrowser.GetWindowID()

	assert windowID and windowID != -1

	currentTitle = win32gui.GetWindowText(windowID)
	if pyBrowser.IsPopup():
		# For popups we always change title to what page is displayed currently.
		win32gui.SetWindowText(windowID, pyTitle)
	else:
		# For main window we probably don't want to do that - as this is main application
		# window that displays application's name. Let's do it only when there is no title set.
		if not currentTitle:
			win32gui.SetWindowText(windowID, pyTitle)

def EnforceWindowIcon(pyBrowser):

	# Each popup window should inherit icon from the main window.

	if pyBrowser.IsPopup():
		windowID = pyBrowser.GetInnerWindowID()
	else:
		return

	assert windowID and windowID != -1

	iconBig = win32api.SendMessage(windowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
	iconSmall = win32api.SendMessage(windowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

	if not iconBig and not iconSmall:

		if g_debug:
			print("EnforceWindowIcon(): setting icon for a popup, inheriting icon from parent")

		parentWindowID = pyBrowser.GetOpenerWindowID()

		parentIconBig = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
		parentIconSmall = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

		# If parent is main application window, then GetOpenerWindowID() returned
		# innerWindowID of the parent window, try again.

		if not parentIconBig and not parentIconSmall:
			parentWindowID = win32gui.GetParent(parentWindowID)

		parentIconBig = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
		parentIconSmall = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

		if parentIconBig:
			win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_BIG, parentIconBig)
		if parentIconSmall:
			win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_SMALL, parentIconSmall)


cdef public cbool DisplayHandler_OnTooltip(CefRefPtr[CefBrowser] cefBrowser,
                         CefString& cefText) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)	
		pyText = [CefStringToPyString(cefText)] # In/Out
		handler = pyBrowser.GetClientHandler("OnTooltip")
		if handler:
			ret = handler(pyBrowser, pyText)
			PyStringToCefString(pyText[0], cefText);
			return <cbool>bool(ret)
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)