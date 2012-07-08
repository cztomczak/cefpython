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


def CloseApplication(windowID, msg, wparam, lparam):
	
	browser = cefpython.GetBrowserByWindowID(windowID)
	browser.CloseBrowser()
	cefwindow.DestroyWindow(windowID)
	return 0 # If an application processes this message, it should return zero.

def QuitApplication(windowID, msg, wparam, lparam):

	# If you put PostQuitMessage() in WM_CLOSE event (CloseApplication) 
	# you will get memory errors when closing application.
	win32gui.PostQuitMessage(0)
	return 0


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
		win32con.WM_CLOSE: CloseApplication, 
		win32con.WM_DESTROY: QuitApplication,
		win32con.WM_SIZE: cefpython.wm_Size,
		win32con.WM_SETFOCUS: cefpython.wm_SetFocus,
		win32con.WM_ERASEBKGND: cefpython.wm_EraseBkgnd
	}
	windowID = cefwindow.CreateWindow("CefAdvanced", "cefadvanced", 800, 600, None, None, "icon.ico", wndproc)

	browserSettings = {} # See: http://code.google.com/p/cefpython/wiki/BrowserSettings
	browserSettings["history_disabled"] = False
	browserSettings["universal_access_from_file_urls_allowed"] = True
	browserSettings["file_access_from_file_urls_allowed"] = True
	
	handlers = {}
	handlers["OnLoadStart"] = DocumentReady
	handlers["OnLoadError"] = OnLoadError

	browser = cefpython.CreateBrowser(windowID, browserSettings, "cefadvanced.html", handlers)

	cefpython.MessageLoop()
	cefpython.Shutdown()


def DocumentReady(browser, frame):
	
	print "OnLoadStart(): frame URL: %s" % frame.GetURL()
	#browser.GetMainFrame().ExecuteJavascript("window.open('about:blank', '', 'width=500,height=500')")
	if frame.IsMain():
		return
	#print "HidePopup(): %s" % browser.HidePopup()

def OnLoadError(browser, frame, errorCode, failedURL, errorText):

	print "OnLoadError() failedURL: %s, frame = %s" % (failedURL, frame)


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
	cefwindow.MoveWindow(windowID, width=500, height=500)
	pass


def MoveWindow():
	cefwindow.MoveWindow(windowID, xpos=0, ypos=0)
	pass


def DeveloperTools():
	browser.ShowDevTools()
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
