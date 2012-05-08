# CURRENTLY there is NO REAL API, just a single main() function exposed.

import os
import sys
import cefwindow
import win32con
import win32gui
import cython

from libcpp cimport bool
from libc.stdlib cimport malloc, free

cdef CefRefPtr[CefBrowser] browser

def main():
	print "\n%s" % ("--------" * 8)
	print "Welcome to CEF python bindings!"
	print "%s\n" % ("--------" * 8)

	print "CefInitialize(settings, app)"

	cdef CefSettings settings
	cdef CefRefPtr[CefApp] app

	cdef bool ret = CefInitialize(settings, app)

	if ret:	print "OK"
	else: print "ERROR"
	print "lasterror: %s" % cefwindow.lasterror()

	wndproc = {
		# pywin32 does not send WM_CREATE message
		# win32con.WM_CREATE: wm_create, -- we are calling wm_create() manually after window creation

		#win32con.WM_PAINT: wm_paint, -- is it really needed?

		win32con.WM_SETFOCUS: wm_setfocus,
		win32con.WM_SIZE: wm_size,
		win32con.WM_ERASEBKGND: wm_erasebkgnd,
		win32con.WM_CLOSE: wm_close
	}

	hwnd = cefwindow.createwindow("Test", "testclass", wndproc)
	print "lasterror: %s" % cefwindow.lasterror()

	#print "ShowWindow, UpdateWindow"
	#WS_VISIBLE in cefwindow.createwindow does the same, so commenting out.
	#win32gui.ShowWindow(hwnd, win32con.SW_SHOWDEFAULT)
	#win32gui.UpdateWindow(hwnd)
	#print "lasterror: %s" % cefwindow.lasterror()

	wm_create(hwnd)

	print "CefRunMessageLoop()\n"
	CefRunMessageLoop()
	print "lasterror: %s" % cefwindow.lasterror()

	print "CefShutdown()"
	CefShutdown()

	print "lasterror: %s" % cefwindow.lasterror()

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

def wm_setfocus(hwnd, msg, wparam, lparam):
	#print "wm_setfocus"
	# @TODO
	pass

def wm_size(hwnd, msg, wparam, lparam):
	#print "wm_size"
	# @TODO
	pass

def wm_erasebkgnd(hwnd, msg, wparam, lparam):
	#print "wm_erasebkgnd"
	# @TODO
	pass

def wm_close(hwnd, msg, wparam, lparam):
	global browser
	if <void*>browser != NULL:
		print "wm_close: browser != NULL"
		print "browser.ParentWindowWillClose()"
		(<CefBrowser*>(browser.get())).ParentWindowWillClose()
		(<CefBrowser*>(browser.get())).CloseBrowser()
	win32gui.PostQuitMessage(0)
	return 0

