# Simple CEF Python application, 
# for more advanced features see "cefadvanced.py"

import cefpython
import cefwindow
import win32con
import win32gui
import sys

def CloseApplication(windowID, msg, wparam, lparam):
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	cefwindow.DestroyWindow(windowID)
	return 0

def QuitApplication(windowID, msg, wparam, lparam):
	win32gui.PostQuitMessage(0)
	return 0

def CefSimple():
	sys.excepthook = cefpython.ExceptHook
	cefpython.Initialize({"multi_threaded_message_loop": False})
	wndproc = {
		win32con.WM_CLOSE: CloseApplication, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow(title="CefSimple", className="cefsimple", width=800, height=600, icon="icon.ico", windowProc=wndproc)
	browser = cefpython.CreateBrowser(windowID, browserSettings={}, navigateURL="cefsimple.html")
	cefpython.MessageLoop()
	cefpython.Shutdown()

if __name__ == "__main__":
	CefSimple()
