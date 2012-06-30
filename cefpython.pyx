# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import os
import sys
import cefwindow
import win32con
import win32gui
import win32api
import cython

from libcpp cimport bool
from libc.stdlib cimport malloc, free
from libcpp.map cimport map

__debug = False

# browserID == windowID
cdef map[int, cefrefptr_cefbrowser_t] __browsers = {} # windowID(int): browser


def GetLastError():
	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))


def Initialize(settings):

	if __debug:
		print "\n%s" % ("--------" * 8)
		print "Welcome to CEF Python bindings!"
		print "%s\n" % ("--------" * 8)	

	cdef CefSettings cefsettings
	cdef CefRefPtr[CefApp] cefapp

	for key in settings:
		# Setting string: CefString(&browserDefaults.default_encoding).FromASCII("UTF-8");		
		if type(settings[key]) is int or type(settings[key]) is long:
			cefsettings[key] = <int>settings[key]
		elif type(settings[key]) is bool:
			cefsettings[key] = <bool>settings[key]
		elif type(settings[key]) is string:
			cdef CefString cefstring = new CefString(cefsettings[key][0])
			cefstring.FromASCII(<char*>settings[key])
		else:
			raise Exception("Invalid type in settings dict, key: %s" % key)

	if __debug:
		print "CefInitialize(settings, app)"

	cdef bool ret = CefInitialize(cefsettings, cefapp)

	if __debug:
		if ret: print "OK"
		else: print "ERROR"
		print "GetLastError(): %s" % GetLastError()	

	if ret: return True
	else: return False


def CreateBrowser(windowID, browserSettings, url):
	
	if __debug: print "cefpython.CreateBrowser()"
	classname = cefwindow.GetWindowClassname(windowID)
	cdef HWND hwnd = FindWindowA(classname, NULL)
	if __debug:
		if hwnd == NULL: print "hwnd: NULL"
		else: print "hwnd: OK"
		print "GetLastError(): %s" % GetLastError()

	cdef CefWindowInfo info
	cdef CefBrowserSettings browserSettings

	if __debug: print "win32gui.GetClientRect(windowID)"
	rect1 = win32gui.GetClientRect(windowID)
	if __debug: print "GetLastError(): %s" % GetLastError()

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	if __debug: print "CefWindowInfo.SetAsChild(hwnd, rect2)"
	info.SetAsChild(hwnd2, rect2)
	if __debug: print "GetLastError(): %s" % GetLastError()

	if __debug:
		print "CefWindowInfo:"
		print "m_x(left): %s" % info.m_x
		print "m_y(top): %s" % info.m_y
		print "m_nWidth: %s" % info.m_nWidth
		print "m_nHeight: %s" % info.m_nHeight
		print ""

	if __debug: print "Creating cefurl: CefString().FromASCII(<char*>url)"
	cdef CefString *cefurl = new CefString()
	cefurl.FromASCII(<char*>url)

	if __debug:
		print "Converting back cefurl to ascii:"
		cdef wchar_t* urlwide = <wchar_t*> cefurl.c_str()
		cdef int urlascii_size = WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, NULL, 0, NULL, NULL)
		print "urlascii_size: %s" % urlascii_size
		cdef char* urlascii = <char*>malloc(urlascii_size*sizeof(char))
		WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, urlascii, urlascii_size, NULL, NULL)
		print "urlascii: %s" % urlascii
		free(urlascii)
		print "GetLastError(): %s" % GetLastError()

	if __debug:
		print ""
		print "CefCurrentlyOn(UI=0): %s" % <bool>CefCurrentlyOn(<CefThreadId>0)
		print "CefCurrentlyOn(IO=1): %s" % <bool>CefCurrentlyOn(<CefThreadId>1)
		print "CefCurrentlyOn(FILE=2): %s" % <bool>CefCurrentlyOn(<CefThreadId>2)
		print ""

	# <...?> means to throw an error if the cast is not allowed
	cdef CefRefPtr[CefClient2] cefclient2 = <cefrefptr_cefclient2_t?>new CefClient2()
	if __debug: print "CefClient2 instantiated"

	# Async createbrowser:
	# print "CreateBrowser: %s" % <bool>CreateBrowser(info, <cefrefptr_cefclient_t>cefclient2, cefurl, browserSettings)

	cdef CefRefPtr[CefBrowser] browser = CreateBrowserSync(info, <cefrefptr_cefclient_t?>cefclient2, cefurl[0], browserSettings)

	if <void*>browser == NULL: 
		if __debug: print "CreateBrowserSync(): NULL"
		if __debug: print "GetLastError(): %s" % GetLastError()
		return None
	else: 
		if __debug: print "CreateBrowserSync(): OK"

	browserID = windowID
	__browsers[<int>browserID] = browser

	return browserID


def CloseBrowser(browserID):
	
	cdef CefRefPtr[CefBrowser] browser = __browsers[<int>browserID]
	if <void*>browser != NULL:
		if __debug: print "CloseBrowser(): browser != NULL"
		if __debug: print "CefBrowser.ParentWindowWillClose()"		
		(<CefBrowser*>(browser.get())).ParentWindowWillClose()
		if __debug: print "CefBrowser.CloseBrowser()"
		(<CefBrowser*>(browser.get())).CloseBrowser()	


def MessageLoop():
	
	if __debug: print "CefRunMessageLoop()\n"
	CefRunMessageLoop()
	if __debug: print "GetLastError(): %s" % GetLastError()


def Shutdown():
	
	if __debug: print "CefShutdown()"
	CefShutdown()
	if __debug: print "GetLastError(): %s" % GetLastError()


# Note: pywin32 does not send WM_CREATE message.

def WM_PAINT(hwnd, msg, wparam, lparam):
	pass


def WM_SETFOCUS(hwnd, msg, wparam, lparam):
	pass


def WM_SIZE(hwnd, msg, wparam, lparam):
	pass


def WM_ERASEBKGND(hwnd, msg, wparam, lparam):
	pass

