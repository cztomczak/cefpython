# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import cefpython # cefpython.pyd
import cefwindow
import win32con # pywin32 extension
import win32gui
import win32api
import sys

def CloseApplication(windowID, msg, wparam, lparam):
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	win32api.PostMessage(windowID, win32con.WM_DESTROY, 0, 0)	

def QuitApplication(windowID, msg, wparam, lparam):
	win32gui.PostQuitMessage(0)

def CefAdvanced():
	sys.excepthook = cefpython.ExceptHook # In case of exception display it, write to error.log, shutdown CEF and exit application.
	cefwindow.__debug = True # Whether to print debug output to console.
	cefpython.__debug = True

	appSettings = dict() # See: http://code.google.com/p/cefpython/wiki/AppSettings
	appSettings["multi_threaded_message_loop"] = False
	appSettings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE # LOGSEVERITY_DISABLE - will not create "debug.log" file.
	cefpython.Initialize(appSettings)

	wndproc = {
		win32con.WM_CLOSE: CloseApplication, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow("CefAdvanced", "cefadvanced", 800, 600, None, None, "icon.ico", wndproc)

	browserSettings = dict() # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
	browserSettings["history_disabled"] = False # Backspace key will act as "History back" action in browser.
	browserSettings["universal_access_from_file_urls_allowed"] = True
	browserSettings["file_access_from_file_urls_allowed"] = True
	
	handlers = dict()
	handlers["OnLoadStart"] = (None, None, OnLoadStart) # Document is ready. Developer tools window is also a popup, this handler may be called.
	handlers["OnLoadError"] = OnLoadError
	handlers["OnKeyEvent"] = (OnKeyEvent, None, OnKeyEvent)

	bindings = cefpython.JavascriptBindings(bindToFrames=False, bindToPopups=False)
	bindings.SetFunction("PyTest1", PyTest1)
	bindings.SetFunction("PyTest2", PyTest2)

	browser = cefpython.CreateBrowser(windowID, browserSettings, "cefadvanced.html", handlers, bindings)

	cefpython.MessageLoop()
	cefpython.Shutdown()

def PyTest1():
	print "PyTest1() called"

def PyTest2():
	print "PyTest2() called"

def OnLoadStart(browser, frame):
	print "OnLoadStart(): frame URL: %s" % frame.GetURL()
	#if frame.IsMain(): return
	#browser.GetMainFrame().ExecuteJavascript("window.open('about:blank', '', 'width=500,height=500')")
	#print "HidePopup(): %s" % browser.HidePopup()

def OnLoadError(browser, frame, errorCode, failedURL, errorText):
	print "OnLoadError() failedURL: %s, frame = %s" % (failedURL, frame)

def OnKeyEvent(browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript):
	# print "keyCode=%s, modifiers=%s, isSystemKey=%s" % (keyCode, modifiers, isSystemKey)
	# Let's bind developer tools to F12 key.
	if keyCode == cefpython.VK_F12 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
		browser.ShowDevTools()
		return True
	# Bind F5 to refresh browser window.
	if keyCode == cefpython.VK_F5 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
		browser.ReloadIgnoreCache()
		return True
	return False

def JavascriptBindings():
	# http://code.google.com/p/chromiumembedded/wiki/JavaScriptIntegration
	pass

def JavascriptCallbacks():
	pass

def PopupWindow():
	pass

def ModalWindow():
	pass

def ResizeWindow():
	#cefwindow.MoveWindow(windowID, width=500, height=500)
	pass

def MoveWindow():
	#cefwindow.MoveWindow(windowID, xpos=0, ypos=0)
	pass

def DeveloperTools():
	#browser.ShowDevTools()
	pass

def LoadContentFromZip():
	# Allow to pack html/css/images to a zip and run content from this file.
	# Optionally allow to password protect this zip file.
	pass

def LoadContentFromEncryptedZip():
	# This will be useful only if you protect your python sources by compiling them
	# to exe by using for example "pyinstaller", or even better you could compile sources
	# to a dll-like file called "pyd" by using cython extension, or you could combine them both.
	# See WBEA for implementation.
	pass

if __name__ == "__main__":
	CefAdvanced()
