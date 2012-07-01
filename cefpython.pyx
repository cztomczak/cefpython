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
import os


from libcpp cimport bool as cbool
from libc.stdlib cimport malloc, free
from libcpp.map cimport map


__debug = False


from cef cimport *
cimport cef_types
cimport cef_types_win


LOGSEVERITY_VERBOSE = int(<int>cef_types.LOGSEVERITY_VERBOSE)
LOGSEVERITY_INFO = int(<int>cef_types.LOGSEVERITY_INFO)
LOGSEVERITY_WARNING = int(<int>cef_types.LOGSEVERITY_WARNING)
LOGSEVERITY_ERROR = int(<int>cef_types.LOGSEVERITY_ERROR)
LOGSEVERITY_ERROR_REPORT = int(<int>cef_types.LOGSEVERITY_ERROR_REPORT)
LOGSEVERITY_DISABLE = int(<int>cef_types.LOGSEVERITY_DISABLE)


ANGLE_IN_PROCESS = int(<int>cef_types_win.ANGLE_IN_PROCESS)
ANGLE_IN_PROCESS_COMMAND_BUFFER = int(<int>cef_types_win.ANGLE_IN_PROCESS_COMMAND_BUFFER)
DESKTOP_IN_PROCESS = int(<int>cef_types_win.DESKTOP_IN_PROCESS)
DESKTOP_IN_PROCESS_COMMAND_BUFFER = int(<int>cef_types_win.DESKTOP_IN_PROCESS_COMMAND_BUFFER)


cdef map[int, cefrefptr_cefbrowser_t] __browsers # windowID(int): browser 


def GetLastError():
	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))


def Initialize(appSettings):

	if __debug:
		print "\n%s" % ("--------" * 8)
		print "Welcome to CEF Python bindings!"
		print "%s\n" % ("--------" * 8)	

	cdef CefSettings cefAppSettings
	cdef CefRefPtr[CefApp] cefApp
	cdef CefString *cefString

	for key in appSettings:
		
		# Setting string: CefString(&browserDefaults.default_encoding).FromASCII("UTF-8");		
		# cefString = CefString(&cefSettings.user_agent)
		# cefString.FromASCII(<char*>settings[key])

		# <cbool> is not enogh, we need <cbool>bool otherwise warning appears:
		# >cefpython.cpp(1140) : warning C4800: 'int' : forcing value to bool 'true' or 'false' (performance warning)	
		
		if key == "multi_threaded_message_loop":
			cefAppSettings.multi_threaded_message_loop = <cbool>bool(appSettings[key])
		elif key == "cache_path":
			cefString = new CefString(&cefAppSettings.cache_path)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "user_agent":
			cefString = new CefString(&cefAppSettings.user_agent)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "product_version":
			cefString = new CefString(&cefAppSettings.product_version)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "log_file":
			cefString = new CefString(&cefAppSettings.log_file)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "locale":
			cefString = new CefString(&cefAppSettings.locale)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "log_severity":
			cefAppSettings.log_severity = <cef_types.cef_log_severity_t><int>int(appSettings[key])
		elif key == "graphics_implementation":
			cefAppSettings.graphics_implementation = <cef_types_win.cef_graphics_implementation_t><int>int(appSettings[key])
		elif key == "local_storage_quota":
			cefAppSettings.local_storage_quota = <int>int(appSettings[key])
		elif key == "session_storage_quota":
			cefAppSettings.session_storage_quota = <int>int(appSettings[key])
		elif key == "javascript_flags":
			cefString = new CefString(&cefAppSettings.javascript_flags)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "pack_file_path":
			cefString = new CefString(&cefAppSettings.pack_file_path)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		elif key == "locales_dir_path":
			cefString = new CefString(&cefAppSettings.locales_dir_path)
			cefString.FromASCII(<char*>appSettings[key])
			del cefString
		else:
			raise Exception("Invalid appSettings key: %s" % key)

	if __debug:
		print "CefInitialize(cefAppSettings, cefApp)"

	cdef cbool ret = CefInitialize(cefAppSettings, cefApp)

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
	cdef CefBrowserSettings cefBrowserSettings
	cdef CefString *cefString

	for key in browserSettings:
		
		if key == "drag_drop_disabled":
			cefBrowserSettings.drag_drop_disabled = <cbool>bool(browserSettings[key])
		elif key == "load_drops_disabled":
			cefBrowserSettings.load_drops_disabled = <cbool>bool(browserSettings[key])
		elif key == "history_disabled":
			cefBrowserSettings.history_disabled = <cbool>bool(browserSettings[key])
		elif key == "standard_font_family":
			cefString = new CefString(&cefBrowserSettings.standard_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "fixed_font_family":
			cefString = new CefString(&cefBrowserSettings.fixed_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "serif_font_family":
			cefString = new CefString(&cefBrowserSettings.serif_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "sans_serif_font_family":
			cefString = new CefString(&cefBrowserSettings.sans_serif_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "cursive_font_family":
			cefString = new CefString(&cefBrowserSettings.cursive_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "fantasy_font_family":
			cefString = new CefString(&cefBrowserSettings.fantasy_font_family)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "default_font_size":
			cefBrowserSettings.default_font_size = <int>int(browserSettings[key])
		elif key == "default_fixed_font_size":
			cefBrowserSettings.default_fixed_font_size = <int>int(browserSettings[key])
		elif key == "minimum_font_size":
			cefBrowserSettings.minimum_font_size = <int>int(browserSettings[key])
		elif key == "minimum_logical_font_size":
			cefBrowserSettings.minimum_logical_font_size = <int>int(browserSettings[key])
		elif key == "remote_fonts_disabled":
			cefBrowserSettings.remote_fonts_disabled = <cbool>bool(browserSettings[key])
		elif key == "default_encoding":
			cefString = new CefString(&cefBrowserSettings.default_encoding)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "encoding_detector_enabled":
			cefBrowserSettings.encoding_detector_enabled = <cbool>bool(browserSettings[key])
		elif key == "javascript_disabled":
			cefBrowserSettings.javascript_disabled = <cbool>bool(browserSettings[key])
		elif key == "javascript_open_windows_disallowed":
			cefBrowserSettings.javascript_open_windows_disallowed = <cbool>bool(browserSettings[key])
		elif key == "javascript_close_windows_disallowed":
			cefBrowserSettings.javascript_close_windows_disallowed = <cbool>bool(browserSettings[key])
		elif key == "javascript_access_clipboard_disallowed":
			cefBrowserSettings.javascript_access_clipboard_disallowed = <cbool>bool(browserSettings[key])
		elif key == "dom_paste_disabled":
			cefBrowserSettings.dom_paste_disabled = <cbool>bool(browserSettings[key])
		elif key == "caret_browsing_enabled":
			cefBrowserSettings.caret_browsing_enabled = <cbool>bool(browserSettings[key])
		elif key == "java_disabled":
			cefBrowserSettings.java_disabled = <cbool>bool(browserSettings[key])
		elif key == "plugins_disabled":
			cefBrowserSettings.plugins_disabled = <cbool>bool(browserSettings[key])
		elif key == "universal_access_from_file_urls_allowed":
			cefBrowserSettings.universal_access_from_file_urls_allowed = <cbool>bool(browserSettings[key])
		elif key == "file_access_from_file_urls_allowed":
			cefBrowserSettings.file_access_from_file_urls_allowed = <cbool>bool(browserSettings[key])
		elif key == "web_security_disabled":
			cefBrowserSettings.web_security_disabled = <cbool>bool(browserSettings[key])
		elif key == "xss_auditor_enabled":
			cefBrowserSettings.xss_auditor_enabled = <cbool>bool(browserSettings[key])
		elif key == "image_load_disabled":
			cefBrowserSettings.image_load_disabled = <cbool>bool(browserSettings[key])
		elif key == "shrink_standalone_images_to_fit":
			cefBrowserSettings.shrink_standalone_images_to_fit = <cbool>bool(browserSettings[key])
		elif key == "site_specific_quirks_disabled":
			cefBrowserSettings.site_specific_quirks_disabled = <cbool>bool(browserSettings[key])
		elif key == "text_area_resize_disabled":
			cefBrowserSettings.text_area_resize_disabled = <cbool>bool(browserSettings[key])
		elif key == "page_cache_disabled":
			cefBrowserSettings.page_cache_disabled = <cbool>bool(browserSettings[key])
		elif key == "tab_to_links_disabled":
			cefBrowserSettings.tab_to_links_disabled = <cbool>bool(browserSettings[key])
		elif key == "hyperlink_auditing_disabled":
			cefBrowserSettings.hyperlink_auditing_disabled = <cbool>bool(browserSettings[key])
		elif key == "user_style_sheet_enabled":
			cefBrowserSettings.user_style_sheet_enabled = <cbool>bool(browserSettings[key])
		elif key == "user_style_sheet_location":
			cefString = new CefString(&cefBrowserSettings.user_style_sheet_location)
			cefString.FromASCII(<char*>browserSettings[key])
			del cefString
		elif key == "author_and_user_styles_disabled":
			cefBrowserSettings.author_and_user_styles_disabled = <cbool>bool(browserSettings[key])
		elif key == "local_storage_disabled":
			cefBrowserSettings.local_storage_disabled = <cbool>bool(browserSettings[key])
		elif key == "databases_disabled":
			cefBrowserSettings.databases_disabled = <cbool>bool(browserSettings[key])
		elif key == "application_cache_disabled":
			cefBrowserSettings.application_cache_disabled = <cbool>bool(browserSettings[key])
		elif key == "webgl_disabled":
			cefBrowserSettings.webgl_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_compositing_enabled":
			cefBrowserSettings.accelerated_compositing_enabled = <cbool>bool(browserSettings[key])
		elif key == "threaded_compositing_enabled":
			cefBrowserSettings.threaded_compositing_enabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_layers_disabled":
			cefBrowserSettings.accelerated_layers_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_video_disabled":
			cefBrowserSettings.accelerated_video_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_2d_canvas_disabled":
			cefBrowserSettings.accelerated_2d_canvas_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_painting_disabled":
			cefBrowserSettings.accelerated_painting_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_filters_disabled":
			cefBrowserSettings.accelerated_filters_disabled = <cbool>bool(browserSettings[key])
		elif key == "accelerated_plugins_disabled":
			cefBrowserSettings.accelerated_plugins_disabled = <cbool>bool(browserSettings[key])
		elif key == "developer_tools_disabled":
			cefBrowserSettings.developer_tools_disabled = <cbool>bool(browserSettings[key])
		elif key == "fullscreen_enabled":
			cefBrowserSettings.fullscreen_enabled = <cbool>bool(browserSettings[key])
		else:
			raise Exception("Invalid browserSettings key: %s" % key)

	if __debug: print "win32gui.GetClientRect(windowID)"
	rect1 = win32gui.GetClientRect(windowID)
	if __debug: print "GetLastError(): %s" % GetLastError()

	cdef RECT rect2
	rect2.left = <int>rect1[0]
	rect2.top = <int>rect1[1]
	rect2.right = <int>rect1[2]
	rect2.bottom = <int>rect1[3]

	if __debug: print "CefWindowInfo.SetAsChild(hwnd, rect2)"
	info.SetAsChild(hwnd, rect2)
	if __debug: print "GetLastError(): %s" % GetLastError()

	if __debug:
		print "CefWindowInfo:"
		print "m_x(left): %s" % info.m_x
		print "m_y(top): %s" % info.m_y
		print "m_nWidth: %s" % info.m_nWidth
		print "m_nHeight: %s" % info.m_nHeight
		print ""

	if url.find("/") == -1 and url.find("\\") == -1:
		url = "%s%s%s" % (os.getcwd(), os.sep, url)
	if __debug: print "url: %s" % url	
	if __debug: print "Creating cefUrl: CefString().FromASCII(<char*>url)"
	cdef CefString *cefUrl = new CefString()
	cefUrl.FromASCII(<char*>url)

	"""
	print "Converting back cefUrl to ascii:"
	cdef wchar_t* urlwide = <wchar_t*> cefUrl.c_str()
	cdef int urlascii_size = WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, NULL, 0, NULL, NULL)
	print "urlascii_size: %s" % urlascii_size
	cdef char* urlascii = <char*>malloc(urlascii_size*sizeof(char))
	WideCharToMultiByte(CP_UTF8, 0, urlwide, -1, urlascii, urlascii_size, NULL, NULL)
	print "urlascii: %s" % urlascii
	free(urlascii)
	print "GetLastError(): %s" % GetLastError()
	"""

	if __debug:
		print ""
		print "CefCurrentlyOn(UI=0): %s" % <cbool>CefCurrentlyOn(<CefThreadId>0)
		print "CefCurrentlyOn(IO=1): %s" % <cbool>CefCurrentlyOn(<CefThreadId>1)
		print "CefCurrentlyOn(FILE=2): %s" % <cbool>CefCurrentlyOn(<CefThreadId>2)
		print ""

	# <...?> means to throw an error if the cast is not allowed
	cdef CefRefPtr[CefClient2] cefclient2 = <cefrefptr_cefclient2_t?>new CefClient2()
	if __debug: print "CefClient2 instantiated"

	# Async createbrowser:
	# print "CreateBrowser: %s" % <cbool>CreateBrowser(info, <cefrefptr_cefclient_t>cefclient2, cefUrl, cefBrowserSettings)

	cdef CefRefPtr[CefBrowser] browser = CreateBrowserSync(info, <cefrefptr_cefclient_t?>cefclient2, cefUrl[0], cefBrowserSettings)

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
	__browsers.erase(<int>browserID)


def GetBrowserByWindowID(windowID):

	# browserID is the same as windowID (int) that was passed to cefpython.CreateBrowser().
	return windowID


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


# Note: pywin32 does not send WM_CREATE message.

def WM_PAINT(hwnd, msg, wparam, lparam):
	pass


def WM_SETFOCUS(hwnd, msg, wparam, lparam):
	pass


def WM_SIZE(hwnd, msg, wparam, lparam):
	pass


def WM_ERASEBKGND(hwnd, msg, wparam, lparam):
	pass

