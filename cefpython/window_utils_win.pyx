# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class WindowUtils:

	@staticmethod
	def OnSetFocus(int windowHandle, long msg, long wparam, long lparam):

		cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
		if not pyBrowser:
			return 0
		pyBrowser.SetFocus(True)		
		return 0	

	@staticmethod
	def OnSize(int windowHandle, long msg, long wparam, long lparam):

		cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
		if not pyBrowser:
			return win32gui.DefWindowProc(windowHandle, msg, wparam, lparam)

		cdef HWND innerHwnd = <HWND><int>int(pyBrowser.GetWindowHandle())
		cdef RECT rect2
		GetClientRect(<HWND><int>windowHandle, &rect2)

		cdef HDWP hdwp = BeginDeferWindowPos(1)
		hdwp = DeferWindowPos(hdwp, innerHwnd, NULL, rect2.left, rect2.top,
				rect2.right - rect2.left, rect2.bottom - rect2.top, SWP_NOZORDER)
		EndDeferWindowPos(hdwp)

		return win32gui.DefWindowProc(windowHandle, msg, wparam, lparam)
	
	@staticmethod
	def OnEraseBackground(int windowHandle, long msg, long wparam, long lparam):
		
		cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
		if not pyBrowser:
			return win32gui.DefWindowProc(windowHandle, msg, wparam, lparam)

		# Dont erase the background if the browser window has been loaded (this avoids flashing)
		if pyBrowser.GetWindowHandle():
			return 0 

		return win32gui.DefWindowProc(windowHandle, msg, wparam, lparam)

	@staticmethod
	def SetTitle(PyBrowser pyBrowser, py_string pyTitle):

		# Each browser window should have a title (Issue 3).	
		# When popup is created, the window that sits in taskbar has no title.

		if not pyTitle:
			return

		if pyBrowser.GetUserData("__outerWindowHandle"):
			windowHandle = pyBrowser.GetUserData("__outerWindowHandle")
		else:
			windowHandle = pyBrowser.GetWindowHandle()

		assert windowHandle, "WindowUtils.SetTitle() failed: windowHandle is empty"

		currentTitle = win32gui.GetWindowText(windowHandle)
		if pyBrowser.GetUserData("__outerWindowHandle"):
			if not currentTitle:
				win32gui.SetWindowText(windowHandle, pyTitle)
		else:
			# For independent popups we always change title to what page is displayed currently.
			win32gui.SetWindowText(windowHandle, pyTitle)
	
	@staticmethod
	def SetIcon(PyBrowser pyBrowser, py_string icon="inherit"):

		# `icon` parameter is not implemented.
		# Popup window inherits icon from the main window.

		if pyBrowser.GetUserData("__outerWindowHandle"):
			return None
		
		windowHandle = pyBrowser.GetWindowHandle()
		assert windowHandle, "WindowUtils.SetIcon() failed: windowHandle is empty"

		iconBig = win32api.SendMessage(windowHandle, win32con.WM_GETICON, win32con.ICON_BIG, 0)
		iconSmall = win32api.SendMessage(windowHandle, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

		if not iconBig and not iconSmall:

			parentWindowHandle = pyBrowser.GetOpenerWindowHandle()

			parentIconBig = win32api.SendMessage(parentWindowHandle, win32con.WM_GETICON, win32con.ICON_BIG, 0)
			parentIconSmall = win32api.SendMessage(parentWindowHandle, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

			# If parent is main application window, then GetOpenerWindowHandle() returned
			# innerWindowHandle of the parent window, try again.

			if not parentIconBig and not parentIconSmall:
				parentWindowHandle = win32gui.GetParent(parentWindowHandle)

			Debug("WindowUtils.SetIcon(): popup inherits icon from parent window: %s" % parentWindowHandle)

			parentIconBig = win32api.SendMessage(parentWindowHandle, win32con.WM_GETICON, win32con.ICON_BIG, 0)
			parentIconSmall = win32api.SendMessage(parentWindowHandle, win32con.WM_GETICON, win32con.ICON_SMALL, 0)

			if parentIconBig:
				win32api.SendMessage(windowHandle, win32con.WM_SETICON, win32con.ICON_BIG, parentIconBig)
			if parentIconSmall:
				win32api.SendMessage(windowHandle, win32con.WM_SETICON, win32con.ICON_SMALL, parentIconSmall)

