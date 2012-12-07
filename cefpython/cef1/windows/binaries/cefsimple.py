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
		win32con.WM_CLOSE: CloseWindow, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.WindowUtils.OnSize,
		win32con.WM_SETFOCUS: cefpython.WindowUtils.OnSetFocus,
		win32con.WM_ERASEBKGND: cefpython.WindowUtils.OnEraseBackground
	}
	windowHandle = cefwindow.CreateWindow(title="CefSimple", className="cefsimple", 
					width=800, height=600, icon="icon.ico", windowProc=wndproc)
	windowInfo = cefpython.WindowInfo()
	windowInfo.SetAsChild(windowHandle)
	browser = cefpython.CreateBrowserSync(windowInfo, browserSettings={}, navigateURL="cefsimple.html")
	cefpython.MessageLoop()
	cefpython.Shutdown()

def CloseWindow(windowHandle, message, wparam, lparam):
	browser = cefpython.GetBrowserByWindowHandle(windowHandle)
	browser.CloseBrowser()
	return win32gui.DefWindowProc(windowHandle, message, wparam, lparam)

def QuitApplication(windowHandle, message, wparam, lparam):
	win32gui.PostQuitMessage(0)
	return 0

if __name__ == "__main__":
	CefSimple()
