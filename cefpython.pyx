# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import os
import sys
import win32con
import win32gui
import win32api
import cython
import traceback
import time

from libcpp cimport bool as cbool
from libcpp.map cimport map
from libcpp.vector cimport vector
from cython.operator cimport preincrement as preinc, dereference as deref # must be "as" otherwise not seen.
from libc.stdlib cimport malloc, free

# When pyx file cimports * from a pxd file and that cimports * from another pxd
# then these another names will be visible in pyx file.

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *", this
# is important to know in pxd files.

# <CefRefPtr[ClientHandler]?>new ClientHandler() # <...?> means to throw an error if the cast is not allowed

from windows cimport *
from cef_string cimport *
from cef_type_wrappers cimport *
from cef_task cimport *
from cef_win cimport *
from cef_ptr cimport *
from cef_app cimport *
from cef_browser cimport *
from cef_client cimport *
from clienthandler cimport *
from cef_frame cimport *
cimport cef_types

# Global variables.

__debug = False


# Client handler.
cdef CefRefPtr[ClientHandler] __clientHandler = <CefRefPtr[ClientHandler]?>new ClientHandler()


def ExceptHook(type, value, traceobject):
	
	error = "\n".join(traceback.format_exception(type, value, traceobject))
	if hasattr(sys, "frozen"): path = os.path.dirname(sys.executable)
	elif "__file__" in locals(): path = os.path.dirname(os.path.realpath(__file__))
	else: path = os.getcwd()
	with open(path+"/error.log", "a") as file: 
		file.write("\n[%s] %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), error))
	print "\n"+error+"\n"
	CefQuitMessageLoop()
	CefShutdown()
	os._exit(1) # so that "finally" does not execute


def GetLastError():
	
	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))

def __InitializeClientHandler():

	InitializeLoadHandler()

def Initialize(appSettings):

	__InitializeClientHandler()

	if __debug:
		print "\n%s" % ("--------" * 8)
		print "Welcome to CEF Python bindings!"
		print "%s\n" % ("--------" * 8)	

	cdef CefSettings cefAppSettings
	cdef CefRefPtr[CefApp] cefApp
	cdef CefString *cefString

	SetAppSettings(appSettings, &cefAppSettings)

	if __debug:
		print "CefInitialize(cefAppSettings, cefApp)"

	cdef cbool ret = CefInitialize(cefAppSettings, cefApp)

	if __debug:
		if ret: print "OK"
		else: print "ERROR"
		print "GetLastError(): %s" % GetLastError()	


def CreateBrowser(windowID, browserSettings, navigateURL, handlers=None):
	
	if not handlers:
		handlers = {}

	if __debug: print "cefpython.CreateBrowser()"

	# Later in the code we do a dangerous cast: <HWND><int>windowID,
	# so let's make sure that this is a valid window.
	if not win32gui.IsWindow(windowID):
		raise Exception("CreateBrowser() failed: invalid windowID")

	cdef CefWindowInfo info
	cdef CefBrowserSettings cefBrowserSettings
	cdef CefString *cefString

	SetBrowserSettings(browserSettings, &cefBrowserSettings)	

	if __debug: print "win32gui.GetClientRect(windowID)"
	rect1 = win32gui.GetClientRect(windowID)
	if __debug: print "GetLastError(): %s" % GetLastError()

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	if __debug: print "CefWindowInfo.SetAsChild(<HWND><int>windowID, rect2)"
	info.SetAsChild(<HWND><int>windowID, rect2)	
	if __debug: print "GetLastError(): %s" % GetLastError()

	if navigateURL.find("/") == -1 and navigateURL.find("\\") == -1:
		navigateURL = "%s%s%s" % (os.getcwd(), os.sep, navigateURL)
	if __debug: print "navigateURL: %s" % navigateURL	
	if __debug: print "Creating cefNavigateURL: CefString().FromASCII(<char*>navigateURL)"
	cdef CefString cefNavigateURL
	cefNavigateURL.FromASCII(<char*>navigateURL)

	cdef CefRefPtr[CefBrowser] cefBrowser = CreateBrowserSync(info, <CefRefPtr[CefClient]?>__clientHandler, cefNavigateURL, cefBrowserSettings)

	if <void*>cefBrowser == NULL: 
		if __debug: print "CreateBrowserSync(): NULL"
		if __debug: print "GetLastError(): %s" % GetLastError()
		return None
	else: 
		if __debug: print "CreateBrowserSync(): OK"

	cdef int innerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	__cefBrowsers[innerWindowID] = cefBrowser
	__pyBrowsers[innerWindowID] = PyBrowser(windowID, innerWindowID, handlers)	
	__browserInnerWindows[windowID] = innerWindowID

	return __pyBrowsers[innerWindowID]


def GetBrowserByWindowID(windowID):

	# This is: ByTopWindowID.
	if windowID in __browserInnerWindows:
		innerWindowID = __browserInnerWindows[windowID]
		if innerWindowID in __pyBrowsers:
			return __pyBrowsers[innerWindowID]
		else:
			return None
	else:
		return None


def MessageLoop():
	
	if __debug: print "CefRunMessageLoop()\n"
	CefRunMessageLoop()


def QuitMessageLoop():

	if __debug: print "QuitMessageLoop()"
	CefQuitMessageLoop()


def Shutdown():
	
	if __debug: print "CefShutdown()"
	CefShutdown()
	if __debug: print "GetLastError(): %s" % GetLastError()	


# ------------------

cimport cef_types

TID_UI = cef_types.TID_UI
TID_IO = cef_types.TID_IO
TID_FILE = cef_types.TID_FILE

def CurrentlyOn(threadID):

	threadID = <int>int(threadID)
	return CefCurrentlyOn(<CefThreadId>threadID)

