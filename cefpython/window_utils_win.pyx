# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class WindowUtils:

	@staticmethod
	def OnSetFocus(windowID, msg, wparam, lparam):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, True) # 2nd param = ignoreError
		if <void*>cefBrowser == NULL:
			return 0

		cdef HWND innerHwnd
		IF CEF_VERSION == 1:
			innerHwnd = cefBrowser.get().GetWindowHandle()
		ELIF CEF_VERSION == 3:
			innerHwnd = GetCefBrowserHost(cefBrowser).get().GetWindowHandle()

		# wparam,lparam from pywin32 seems to be always 0,0
		PostMessage(innerHwnd, WM_SETFOCUS, 0, 0)

		return 0	

	@staticmethod
	def OnSize(windowID, msg, wparam, lparam):

		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, True) # 2nd param = ignoreError
		if <void*>cefBrowser == NULL:
			return win32gui.DefWindowProc(windowID, msg, wparam, lparam)

		cdef HWND innerHwnd
		IF CEF_VERSION == 1:
			innerHwnd = cefBrowser.get().GetWindowHandle()
		ELIF CEF_VERSION == 3:
			innerHwnd = GetCefBrowserHost(cefBrowser).get().GetWindowHandle()

		cdef RECT rect2
		GetClientRect(<HWND><int>windowID, &rect2)

		cdef HDWP hdwp = BeginDeferWindowPos(<int>1)
		hdwp = DeferWindowPos(hdwp, innerHwnd, NULL, rect2.left, rect2.top, rect2.right - rect2.left, rect2.bottom - rect2.top, SWP_NOZORDER)
		EndDeferWindowPos(hdwp)

		return win32gui.DefWindowProc(windowID, msg, wparam, lparam)
	
	@staticmethod
	def OnEraseBackground(windowID, msg, wparam, lparam):
		
		cdef CefRefPtr[CefBrowser] cefBrowser = GetCefBrowserByTopWindowID(windowID, True) # 2nd param = ignoreError
		if <void*>cefBrowser == NULL:
			return win32gui.DefWindowProc(windowID, msg, wparam, lparam)

		cdef HWND innerHwnd
		IF CEF_VERSION == 1:
			innerHwnd = cefBrowser.get().GetWindowHandle()
		ELIF CEF_VERSION == 3:
			innerHwnd = GetCefBrowserHost(cefBrowser).get().GetWindowHandle()

		if innerHwnd:
			return 0 # Dont erase the background if the browser window has been loaded (this avoids flashing)

		return win32gui.DefWindowProc(windowID, msg, wparam, lparam)

	@staticmethod
	def SetTitle(pyBrowser, pyTitle):

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
	
	@staticmethod
	def SetIcon(pyBrowser, icon="inherit"):

		# `icon` parameter is not implemented.
		# Popup window inherits icon from the main window.

		if pyBrowser.IsPopup():
			windowID = pyBrowser.GetInnerWindowID()
		else:
			return

		assert windowID and windowID != -1

		iconBig = win32api.SendMessage(windowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
		iconSmall = win32api.SendMessage(windowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

		if not iconBig and not iconSmall:

			parentWindowID = pyBrowser.GetOpenerWindowID()

			parentIconBig = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
			parentIconSmall = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

			# If parent is main application window, then GetOpenerWindowID() returned
			# innerWindowID of the parent window, try again.

			if not parentIconBig and not parentIconSmall:
				parentWindowID = win32gui.GetParent(parentWindowID)

			Debug("WindowUtils.SetIcon(): popup inherits icon from parent window: %s" % parentWindowID)

			parentIconBig = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_BIG, 0)
			parentIconSmall = win32api.SendMessage(parentWindowID, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

			if parentIconBig:
				win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_BIG, parentIconBig)
			if parentIconSmall:
				win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_SMALL, parentIconSmall)

