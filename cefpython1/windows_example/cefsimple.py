# Simple CEF Python application, 
# for more advanced features see "cefadvanced.py"

import platform
if platform.architecture()[0] != "32bit":
	raise Exception("Architecture not supported: %s" % platform.architecture()[0])

import sys
if sys.hexversion >= 0x02070000 and sys.hexversion < 0x03000000:
	import cefpython_py27 as cefpython
elif sys.hexversion >= 0x03000000 and sys.hexversion < 0x04000000:
	import cefpython_py32 as cefpython
else:
	raise Exception("Unsupported python version: %s" % sys.version)

import cefwindow
import win32con
import win32gui

def CefSimple():
	sys.excepthook = cefpython.ExceptHook
	cefpython.Initialize()
	wndproc = {
		win32con.WM_CLOSE: CloseApplication, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow(title="CefSimple", className="cefsimple", 
					width=800, height=600, icon="icon.ico", windowProc=wndproc)
	browser = cefpython.CreateBrowser(windowID, browserSettings={}, navigateURL="cefsimple.html")
	cefpython.MessageLoop()
	cefpython.Shutdown()

def CloseApplication(windowID, message, wparam, lparam):
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	return win32gui.DefWindowProc(windowID, message, wparam, lparam)

def QuitApplication(windowID, message, wparam, lparam):
	win32gui.PostQuitMessage(0)
	return 0

if __name__ == "__main__":
	CefSimple()
