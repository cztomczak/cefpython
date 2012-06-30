# CURRENTLY there is NO REAL API, just a single main() function exposed.

import os
import sys
import cefwindow
import win32con
import win32gui
import win32api
import cython

from libcpp cimport bool
from libc.stdlib cimport malloc, free

cdef CefRefPtr[CefBrowser] browser
__debug = False


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
		# strings: CefString(&browserDefaults.default_encoding).FromASCII("UTF-8");		
		if type(settings[key]) is int or type(settings[key]) is long:
			cefsettings[key] = <int>settings[key]
		elif type(settings[key]) is bool:
			cefsettings[key] = <bool>settings[key]
		elif type(settings[key]) is string:
			cdef CefString cefstring = new CefString(&cefsettings[key])
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


def CreateBrowser(windowID, browserSettings):
	
	pass


def MessageLoop():
	
	if __debug: print "CefRunMessageLoop()\n"
	CefRunMessageLoop()
	if __debug: print "GetLastError(): %s" % GetLastError()


def Shutdown():
	
	if __debug: print "CefShutdown()"
	CefShutdown()
	if __debug: print "GetLastError(): %s" % GetLastError()


def wm_create(hwnd):

	print "wm_create\n"

	# real HWND, "hwnd" passed to wm_create() is an "int"
	cdef HWND hwnd2 = FindWindowA("testclass", NULL)

	if hwnd2 == NULL: print "hwnd2: NULL"
	else: print "hwnd2: OK"
	print "lasterror: %s" % cefwindow.lasterror()

	cdef CefWindowInfo info
	cdef CefBrowserSettings browserSettings

	print "win32gui.GetClientRect"
	rect1 = win32gui.GetClientRect(hwnd)
	print "lasterror: %s" % cefwindow.lasterror()

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	print "CefWindowInfo.SetAsChild(hwnd2, rect2)"
	info.SetAsChild(hwnd2, rect2)
	print "lasterror: %s" % cefwindow.lasterror()

	print "CefWindowInfo:"
	print "m_x(left): %s" % info.m_x
	print "m_y(top): %s" % info.m_y
	print "m_nWidth: %s" % info.m_nWidth
	print "m_nHeight: %s" % info.m_nHeight
	print ""

	print "Creating url3 - CefString().FromASCII"
	cdef CefString *url3 = new CefString()
	htmlfile = "%s/example.html" % os.getcwd()
	url3.FromASCII(<char*>htmlfile)

	print "Converting back url3(CefString) to ascii:"
	cdef wchar_t* urlwide = <wchar_t*> url3.c_str()
	print "converted to: urlwide"
	cdef int urlascii_size = WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, NULL, 0, NULL, NULL)
	print "urlascii_size: %s" % urlascii_size
	cdef char* urlascii = <char*>malloc(urlascii_size*sizeof(char))
	WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, urlascii, urlascii_size, NULL, NULL)
	print "urlascii: %s" % urlascii
	#free(urlascii)
	print "lasterror: %s" % cefwindow.lasterror()

	print ""
	print "CefCurrentlyOn(UI): %s" % <bool>CefCurrentlyOn(<CefThreadId>0)
	print "CefCurrentlyOn(IO): %s" % <bool>CefCurrentlyOn(<CefThreadId>1)
	print "CefCurrentlyOn(FILE): %s" % <bool>CefCurrentlyOn(<CefThreadId>2)
	print ""

	cdef CefRefPtr[CefClient2] cefclient2 = <cefrefptr_cefclient2_t?>new CefClient2() # <...?> means to throw an error if the cast is not allowed
	print "CefClient2 instantiated"

	#print "CreateBrowser: %s" % <bool>CreateBrowser(info, <cefrefptr_cefclient_t>cefclient2, url3, browserSettings)

	global browser
	browser = CreateBrowserSync(info, <cefrefptr_cefclient_t?>cefclient2, url3[0], browserSettings)

	if <void*>browser == NULL: print "CreateBrowserSync: NULL"
	else: print "CreateBrowserSync: OK"
	print "lasterror: %s" % cefwindow.lasterror()

	return 0


def CloseBrowser():
	pass


# Note: pywin32 does not send WM_CREATE message.

def WM_CLOSE(hwnd, msg, wparam, lparam):
	global browser
	if <void*>browser != NULL:
		print "wm_close: browser != NULL"
		print "browser.ParentWindowWillClose()"
		(<CefBrowser*>(browser.get())).ParentWindowWillClose()
		(<CefBrowser*>(browser.get())).CloseBrowser()
	win32gui.PostQuitMessage(0)
	return 0


def WM_PAINT(hwnd, msg, wparam, lparam):
	pass

def WM_SETFOCUS(hwnd, msg, wparam, lparam):
	pass

def WM_SIZE(hwnd, msg, wparam, lparam):
	pass

def WM_ERASEBKGND(hwnd, msg, wparam, lparam):
	pass

