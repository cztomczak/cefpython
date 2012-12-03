# CEF Python 3 example application.

# Checking whether python architecture and version are valid, otherwise an obfuscated error
# will be thrown when trying to load cefpython.pyd with a message "DLL load failed".
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
import time

DEBUG = True

def CefAdvanced():
	
	sys.excepthook = cefpython.ExceptHook
	
	if DEBUG:
		cefpython.g_debug = True
		cefwindow.g_debug = True
	
	appSettings = dict()
	appSettings["log_file"] = cefpython.GetRealPath("debug.log")
	appSettings["log_severity"] = cefpython.LOGSEVERITY_INFO # LOGSEVERITY_DISABLE - will not create "debug.log" file.
	appSettings["release_dcheck_enabled"] = True # Enable only when debugging, otherwise performance might hurt.
	appSettings["browser_subprocess_path"] = "subprocess"
	cefpython.Initialize(appSettings)

	wndproc = {
		win32con.WM_CLOSE: CloseWindow, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.WindowUtils.OnSize,
		win32con.WM_SETFOCUS: cefpython.WindowUtils.OnSetFocus,
		win32con.WM_ERASEBKGND: cefpython.WindowUtils.OnEraseBackground
	}

	browserSettings = dict() 
	browserSettings["universal_access_from_file_urls_allowed"] = True
	browserSettings["file_access_from_file_urls_allowed"] = True

	windowID = cefwindow.CreateWindow(title="CEF Python 3 Example", className="cefpython3_example", 
					width=1024, height=768, icon="icon.ico", windowProc=wndproc)
	browser = cefpython.CreateBrowser(windowID, browserSettings, navigateURL="example.html")
	cefpython.MessageLoop()
	cefpython.Shutdown()

def CloseWindow(windowID, message, wparam, lparam):
	
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	return win32gui.DefWindowProc(windowID, message, wparam, lparam)

def QuitApplication(windowID, message, wparam, lparam):
	
	win32gui.PostQuitMessage(0)
	return 0

if __name__ == "__main__":
	CefAdvanced()
