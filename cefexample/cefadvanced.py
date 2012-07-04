# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import cefpython # cefpython.pyd
import cefwindow
import win32con # pywin32 extension
import win32gui
import os
import sys
import traceback
import time
import threading


def QuitApplication(windowID, msg, wparam, lparam):
	
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	cefwindow.DestroyWindow(windowID)
	win32gui.PostQuitMessage(0)


def CefAdvanced():

	# Programming API:
	# http://code.google.com/p/cefpython/wiki/API

	sys.excepthook = cefpython.ExceptHook # In case of exception display it, write to error.log, shutdown CEF and exit application.
	cefwindow.__debug = True # Whether to print debug output to console.
	cefpython.__debug = True

	appSettings = {} # See: http://code.google.com/p/cefpython/wiki/AppSettings
	appSettings["multi_threaded_message_loop"] = False
	appSettings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE # LOGSEVERITY_DISABLE - will not create "debug.log" file.
	cefpython.Initialize(appSettings)

	wndproc = {
		win32con.WM_CLOSE: QuitApplication, 
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow("CefAdvanced", "cefadvanced", 800, 600, None, None, "icon.ico", wndproc)

	browserSettings = {} # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
	browserSettings["history_disabled"] = False
	browserSettings["universal_access_from_file_urls_allowed"] = True
	browserSettings["file_access_from_file_urls_allowed"] = True
	browser = cefpython.CreateBrowser(windowID, browserSettings, "cefadvanced.html")

	#browser.GetMainFrame().ExecuteJavascript("alert(1)")

	cefpython.MessageLoop()
	cefpython.Shutdown()

def DocumentReady(browser):

	browser.GetFocusedFrame().ExecuteJavascript("alert(1)")
	print "focused frame: %s" % browser.GetFocusedFrame()
	print "frame names: %s" % browser.GetFrameNames()


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
	# main window, popup and modal
	pass


def MoveWindow():
	# main window, popup and modal
	pass


def DeveloperTools():
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
