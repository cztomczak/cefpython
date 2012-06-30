# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import win32gui
import win32con
import win32api
import time
import math

__debug = False

# We need to keep track of windows classname as when creating browser we need
# to get real HWND and win32gui does not provide a way to get this, so we're using
# FindWindowA(classname) to fetch HWND.

__windows = {} # windowID(int): classname


def CreateWindow(title, classname, width, height, xpos=None, ypos=None, wndproc=None):	

	for key in __windows:
		if __windows[key] == classname:
			raise Exception("There was already created a window with that classname: %s."
				"Each created window must have an unique classname." % classname)			

	if not wndproc:
		wndproc = {win32con.WM_CLOSE: WM_CLOSE}

	wndclass = win32gui.WNDCLASS()
	wndclass.hInstance = win32api.GetModuleHandle(None)
	wndclass.lpszClassName = classname
	wndclass.style = win32con.CS_GLOBALCLASS | win32con.CS_VREDRAW | win32con.CS_HREDRAW
	wndclass.hbrBackground = win32con.COLOR_WINDOW
	wndclass.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
	wndclass.lpfnWndProc = wndproc

	atomclass = win32gui.RegisterClass(wndclass)

	if __debug:
		print "win32gui.RegisterClass(wndclass)"
		print "GetLastError(): %s" % GetLastError()

	if xpos is None or ypos is None:
		# Center window on the screen.
		if __debug:
			print "Centering window on the screen."
		screenx = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
		screeny = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)
		xpos = int(math.floor((screenx - width) / 2))
		ypos = int(math.floor((screeny - height) / 2))
		if xpos < 0: xpos = 0
		if ypos < 0: ypos = 0

	windowID = win32gui.CreateWindow(classname, title,
			win32con.WS_OVERLAPPEDWINDOW | win32con.WS_CLIPCHILDREN | win32con.WS_VISIBLE,
			xpos, ypos, width, height, # xpos, ypos, width, height
			0, 0, wndclass.hInstance, None)
	__windows[windowID] = classname
	
	if __debug:
		print "windowID=%s" % windowID

	return windowID


def DestroyWindow(windowID):

	win32gui.DestroyWindow(windowID)
	classname = GetWindowClassname(windowID)
	win32gui.UnregisterClass(classname, None)
	del __windows[windowID] # Let window with this classname be created again.


def GetWindowClassname(windowID):

	for key in __windows:
		if key == windowID:
			return __windows[key]


def WM_CLOSE(windowID, msg, wparam, lparam):
	
	DestroyWindow(windowID)
	win32gui.PostQuitMessage(0)


def GetLastError():
	
	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))


def MessageLoop(classname):
	
	while win32gui.PumpWaitingMessages() == 0:
		time.sleep(0.001)


if __name__ == "__main__":
	
	__debug = True
	hwnd = CreateWindow("Test window", "testwindow", 800, 600)
	MessageLoop("testwindow")