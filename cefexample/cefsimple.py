# Simple CEF Python application, 
# for more advanced features see "cefadvanced.py"

import cefpython
import cefwindow
import win32con
import win32gui

def QuitApplication(windowID, msg, wparam, lparam):
	
	cefpython.CloseBrowser(cefpython.GetBrowserByWindowID(windowID))
	cefwindow.DestroyWindow(windowID)
	win32gui.PostQuitMessage(0)

def CefSimple():

	cefpython.Initialize({"multi_threaded_message_loop": False})
	wndproc = {win32con.WM_CLOSE: QuitApplication, win32con.WM_SIZE: cefpython.WM_SIZE}
	windowID = cefwindow.CreateWindow("CefSimple", "cefsimple", 800, 600, None, None, "icon.ico", wndproc)
	browserID = cefpython.CreateBrowser(windowID, {}, "cefsimple.html")
	cefpython.MessageLoop()
	cefpython.Shutdown()

if __name__ == "__main__":
	
	CefSimple()
