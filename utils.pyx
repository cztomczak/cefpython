# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# This file has nothing to do with util.h

include "imports.pyx"
include "browser.pyx"
include "frame.pyx"

def GetLastError():

	code = win32api.GetLastError()
	return "(%d) %s" % (code, win32api.FormatMessage(code))

TID_UI = cef_types.TID_UI
TID_IO = cef_types.TID_IO
TID_FILE = cef_types.TID_FILE

def CurrentlyOn(threadID):

	threadID = <int>int(threadID)
	return CefCurrentlyOn(<CefThreadId>threadID)

cdef object GetPyBrowserByCefBrowser(CefRefPtr[CefBrowser] cefBrowser):

	global __popupPyBrowsers
	global __pyBrowsers

	cdef int innerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	cdef int openerInnerWindowID # Popup is a separate window and separate browser, but we can get parent browser.

	if innerWindowID in __pyBrowsers:
		return __pyBrowsers[innerWindowID]
	else:

		# This might be a popup.

		# This will also be called for the Developer Tools popup window!

		openerInnerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetOpenerWindowHandle()

		if openerInnerWindowID in __pyBrowsers:
			parentPyBrowser = __pyBrowsers[openerInnerWindowID]
		elif openerInnerWindowID in __popupPyBrowsers:
			parentPyBrowser = __popupPyBrowsers[openerInnerWindowID]
		else:
			raise Exception("Browser not found in __pyBrowsers, searched by innerWindowID = %s" % innerWindowID)

		# TODO: this currently is never cleaned up, implement LifeSpanHandler.DoClose() and clean __cefBrowsers map.
		__cefBrowsers[innerWindowID] = cefBrowser

		if not (innerWindowID in __popupPyBrowsers):

			# Inheriting clientHandlers and javascriptBindings works only for 1 level of nesting.
			# handler[0] = whether to call for main frame
			# handler[1] = whether to call by inner frames
			# handler[2] = whether to call by popups

			# Client handlers.
			clientHandlers = parentPyBrowser.GetClientHandlers()
			newHandlers = {}
			for key in clientHandlers:
				handler = clientHandlers[key]
				if type(handler) == tuple and handler[2]:
					newHandler = (handler[2], None, handler[2])
					newHandlers[key] = newHandler

			# Javascript bindings.
			newBindings = None
			javascriptBindings = parentPyBrowser.GetJavascriptBindings()
			if javascriptBindings and javascriptBindings.GetBindToPopups():
				newBindings = javascriptBindings

			# Create new popup PyBrowser.
			__popupPyBrowsers[innerWindowID] = PyBrowser(-1, innerWindowID, newHandlers, newBindings)

		return __popupPyBrowsers[innerWindowID]

cdef object GetPyFrameByCefFrame(CefRefPtr[CefFrame] cefFrame):

	global __pyFrames
	global __cefFrames

	cdef long long frameID # cef_types.int64
	if <void*>cefFrame != NULL and <CefFrame*>(cefFrame.get()):
		frameID = (<CefFrame*>(cefFrame.get())).GetIdentifier()
		__cefFrames[frameID] = cefFrame
		pyFrameID = long(frameID)
		if pyFrameID in __pyFrames:
			return __pyFrames[pyFrameID]
		__pyFrames[pyFrameID] = PyFrame(pyFrameID)
		return __pyFrames[pyFrameID]
	else:
		return None

def CheckInnerWindowID(innerWindowID):

	global __cefBrowsers

	# If an exception is raised in cdef function then there is no stack trace,
	# that's why you should call this func before calling GetCefBrowserByWindowID(),
	# if there is an error user will see backtrace in his application.
	if not innerWindowID:
		raise Exception("Browser was destroyed (innerWindowID empty)")
	if __cefBrowsers.find(<int>innerWindowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if not (<CefBrowser*>(__cefBrowsers[<int>innerWindowID]).get()):
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")
	return innerWindowID

cdef CefRefPtr[CefBrowser] GetCefBrowserByInnerWindowID(innerWindowID) except *:

	global __cefBrowsers

	# Map key exists: http://stackoverflow.com/questions/1939953/how-to-find-if-a-given-key-exists-in-a-c-stdmap
	if not innerWindowID:
		raise Exception("Browser was destroyed (innerWindowID empty)")
	if __cefBrowsers.find(<int>innerWindowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if <CefBrowser*>((__cefBrowsers[<int>innerWindowID]).get()):
		return __cefBrowsers[<int>innerWindowID]
	else:
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")

cdef CefRefPtr[CefBrowser] GetCefBrowserByTopWindowID(windowID) except *:

	global __browserInnerWindows
	global __cefBrowsers

	if not windowID:
		raise Exception("Browser was destroyed (windowID empty)")
	if not (windowID in __browserInnerWindows):
		raise Exception("windowID not found in __browserInnerWindows, windowID = %s" % windowID)
	innerWindowID = __browserInnerWindows[windowID]
	if __cefBrowsers.find(<int>innerWindowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if <CefBrowser*>((__cefBrowsers[<int>innerWindowID]).get()):
		return __cefBrowsers[<int>innerWindowID]
	else:
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")

def CheckFrameID(frameID):

	global __cefFrames

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

cdef CefRefPtr[CefFrame] GetCefFrameByFrameID(frameID) except *:

	global __cefFrames

	if not frameID:
		raise Exception("Frame was destroyed (frameID empty)")
	if __cefFrames.find(<cef_types.int64>frameID) == __cefFrames.end():
		raise Exception("Frame was destroyed (__cefFrames.find() failed)")
	if <CefFrame*>(__cefFrames[<cef_types.int64>frameID]).get():
		return __cefFrames[<cef_types.int64>frameID]
	else:
		raise Exception("Frame was destroyed (CefRefPtr.get() failed)")

#noinspection CefStringToPyString
cdef object CefStringToPyString(CefString& cefString):

	# This & in "CefString& cefString" is very important, otherwise you get memory
	# errors and win32 exception. Pycharm suggests that "statement has no effect",
	# but he is so wrong.
	cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
	cdef int charstr_size = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, NULL, 0, NULL, NULL)
	cdef char* charstr = <char*>malloc(charstr_size*sizeof(char))
	WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, charstr, charstr_size, NULL, NULL)
	# "" is required to make a copy of char* otherwise you will get a pointer that will be freed on next line.
	# Python 3 requires bytes from/to char*
	if bytes == str:
		pystring = "" + charstr # Python 2.7
	else:
		# In python 3 bytes and str are different types.
		pystring = (b"" + charstr).decode("utf-8", "ignore") # Python 3
		"""
		try:
			pystring = (b"" + charstr).decode("utf-8") # Python 3
		except:
			# Must be "ignore". In OnLoadError() errorText may contain trash data,
			# as it is an out string used only if you return true in function, c++
			# does not fill strings with zero for performance reasons, so they may contain trash.
			pystring = (b"" + charstr).decode("utf-8", "replace")
			pystring = pystring.replace("\ufffd", "?")
			print("Decoding failed: %s" % pystring)
		"""
	free(charstr)
	return pystring

cdef void PyStringToCefString(pyString, CefString& cefString) except *:
	
	if bytes == str:
		cefString.FromASCII(<char*>pyString) # Python 2.7
	else:
		# In python 3 bytes and str are different types.
		bytesString = pyString.encode("utf-8") # Python 3 requires bytes before converting to char*
		cefString.FromASCII(<char*>bytesString)

cdef void PyStringToCefStringPtr(pyString, CefString* cefString) except *:
	
	if bytes == str:
		cefString.FromASCII(<char*>pyString) # Python 2.7
	else:
		# In python 3 bytes and str are different types.
		bytesString = pyString.encode("utf-8") # Python 3 requires bytes before converting to char*
		cefString.FromASCII(<char*>bytesString)
