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
cdef map[int, CefRefPtr[CefBrowser]] __cefBrowsers # windowID(int): browser 
__pyBrowsers = {}
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

def InitClientHandler():

	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnLoadEnd(<OnLoadEnd_Type>LoadHandler_OnLoadEnd)

def Initialize(appSettings):

	InitClientHandler()

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


def CreateBrowser(windowID, browserSettings, url):
	
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

	if url.find("/") == -1 and url.find("\\") == -1:
		url = "%s%s%s" % (os.getcwd(), os.sep, url)
	if __debug: print "url: %s" % url	
	if __debug: print "Creating cefURL: CefString().FromASCII(<char*>url)"
	cdef CefString cefURL
	cefURL.FromASCII(<char*>url)

	cdef CefRefPtr[CefBrowser] cefBrowser = CreateBrowserSync(info, <CefRefPtr[CefClient]?>__clientHandler, cefURL, cefBrowserSettings)

	if <void*>cefBrowser == NULL: 
		if __debug: print "CreateBrowserSync(): NULL"
		if __debug: print "GetLastError(): %s" % GetLastError()
		return None
	else: 
		if __debug: print "CreateBrowserSync(): OK"

	__cefBrowsers[<int>windowID] = cefBrowser
	__pyBrowsers[windowID] = Browser(windowID)

	return __pyBrowsers[windowID]

def CheckWindowID(windowID):
	
	# If an exception is raised in cdef function then there is no stack trace,
	# that's why you should call this func before calling GetCefBrowserByWindowID(),
	# if there is an error user will see backtrace in his application.
	if not windowID:
		raise Exception("Browser was destroyed (windowID empty)")
	if __cefBrowsers.find(windowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if not (<CefBrowser*>(__cefBrowsers[<int>windowID]).get()):
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")
	return windowID

cdef CefRefPtr[CefBrowser] GetCefBrowserByWindowID(windowID):
	
	# Map key exists: http://stackoverflow.com/questions/1939953/how-to-find-if-a-given-key-exists-in-a-c-stdmap
	if not windowID:
		raise Exception("Browser was destroyed (windowID empty)")
	if __cefBrowsers.find(windowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if <CefBrowser*>(__cefBrowsers[<int>windowID]).get():
		return __cefBrowsers[<int>windowID]
	else:
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")

def CheckFrameID(frameID):

	# If an exception is raised in cdef function then there is no stack trace,
	# that's why you should call this func before calling GetCefFrameByFrameID(),
	# if there is an error user will see backtrace in his application.
	if not frameID:
		raise Exception("Frame was destroyed (frameID empty)")
	if __cefFrames.find(<cef_types.int64>frameID) == __cefFrames.end():
		raise Exception("Frame was destroyed (__cefFrames.find() failed)")
	if not (<CefFrame*>(__cefFrames[<cef_types.int64>frameID]).get()):
		raise Exception("Frame was destroyed (CefRefPtr.get() failed)")
	return frameID

cdef CefRefPtr[CefFrame] GetCefFrameByFrameID(frameID):
	
	if not frameID:
		raise Exception("Frame was destroyed (frameID empty)")
	if __cefFrames.find(<cef_types.int64>frameID) == __cefFrames.end():
		raise Exception("Frame was destroyed (__cefFrames.find() failed)")
	if <CefFrame*>(__cefFrames[<cef_types.int64>frameID]).get():
		return __cefFrames[<cef_types.int64>frameID]
	else:
		raise Exception("Frame was destroyed (CefRefPtr.get() failed)")


def GetBrowserByWindowID(windowID):

	if windowID in __pyBrowsers:
		return __pyBrowsers[windowID]
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

# -------------------

cdef CefStringToPyString(CefString& cefString):

	cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
	cdef int charstr_size = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, NULL, 0, NULL, NULL)
	cdef char* charstr = <char*>malloc(charstr_size*sizeof(char))
	WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, charstr, charstr_size, NULL, NULL)
	pystring = "" + charstr # "" is required to make a copy of char* otherwise you will get a pointer that will be freed on next line.
	free(charstr)
	return pystring
