# Simple CEF Python application, 
# for more advanced features see "cefadvanced.py"

import cefpython
import cefwindow
import win32con
import win32gui
import win32api
import sys
import os

import test

def CloseApplication(windowID, message, wparam, lparam):
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	win32api.PostMessage(windowID, win32con.WM_DESTROY, 0, 0)	

def QuitApplication(windowID, message, wparam, lparam):
	win32gui.PostQuitMessage(0)

def CefSimple():
	cefpython.__debug = True
	sys.excepthook = cefpython.ExceptHook
	cefpython.Initialize()
	wndproc = {
		win32con.WM_CLOSE: CloseApplication, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow(title="Test", className="test", 
					width=200, height=150, icon="icon.ico", windowProc=wndproc)
					
					
	browserSettings = dict() # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
	browserSettings["history_disabled"] = False # Backspace key will act as "History back" action in browser.
	browserSettings["universal_access_from_file_urls_allowed"] = True
	browserSettings["file_access_from_file_urls_allowed"] = True
	browserSettings["page_cache_disabled"] = True
	browserSettings["application_cache_disabled"] = True

	handlers = dict()
	handlers["OnKeyEvent"] = (OnKeyEvent, None, OnKeyEvent)

	bindings = cefpython.JavascriptBindings(bindToFrames=False, bindToPopups=False)
	do_bindings(bindings)

	global __browser
	start_page = "test_noreload.html"
	__browser = cefpython.CreateBrowser(windowID, browserSettings, start_page, handlers, bindings)

	cefpython.MessageLoop()
	cefpython.Shutdown()
	os.kill(os.getpid(), 9)

def do_bindings(bindings):
	bindings.SetFunction("test", test.test)

def open_tools():
	print "open_tools()"
	__browser.ShowDevTools()

def OnKeyEvent(browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript):
	
	# print "keyCode=%s, modifiers=%s, isSystemKey=%s" % (keyCode, modifiers, isSystemKey)
	
	# Let's bind developer tools to F12 key.
	if keyCode == cefpython.VK_F12 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
		browser.ShowDevTools()
		return True
	
	# Bind F5 to refresh browser window.
	if keyCode == cefpython.VK_F5 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
		
		reload(test)
		print "reload"
		
		do_bindings(__browser.GetJavascriptBindings())
		__browser.GetJavascriptBindings().Rebind()
		
		browser.ReloadIgnoreCache() # call this after rebinding as it executes asynchronously.

		return True
	
	# Bind F4 to close app.
	if keyCode == cefpython.VK_F4 and eventType == cefpython.KEYEVENT_RAWKEYDOWN and modifiers == 1024 and not isSystemKey:
		cefpython.QuitMessageLoop()
		return True		
	return False
	
if __name__ == "__main__":
	CefSimple()
