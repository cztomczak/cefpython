# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef object GetPyBrowserByCefBrowser(CefRefPtr[CefBrowser] cefBrowser):

	global __popupPyBrowsers
	cdef int innerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetWindowHandle()
	cdef int openerInnerWindowID # Popup is a separate window and separate browser, but we can get parent browser.

	if innerWindowID in __pyBrowsers:
		return __pyBrowsers[innerWindowID]
	else:
		# This might be a popup.
		openerInnerWindowID = <int>(<CefBrowser*>(cefBrowser.get())).GetOpenerWindowHandle()
		if openerInnerWindowID in __pyBrowsers:
			# This is a popup.
			if not (innerWindowID in __popupPyBrowsers):
				# Should we pass handlers from the parent? {} - empty right now.
				# Add a new parameter in CreateBrowser() called "popupsInheritHandlers"?
				# Or maybe just an another dict "popupHandlers"? User could pass the same
				# handlers dictionary to both parameters.
				__popupPyBrowsers[innerWindowID] = PyBrowser(-1, innerWindowID, {})
			return __popupPyBrowsers[innerWindowID]				
		else:
			raise Exception("Browser not found in __pyBrowsers, searched by innerWindowID = %s" % innerWindowID)

cdef object GetPyFrameByCefFrame(CefRefPtr[CefFrame] cefFrame):

	global __pyFrames
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

cdef object CefStringToPyString(CefString& cefString):

	cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
	cdef int charstr_size = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, NULL, 0, NULL, NULL)
	cdef char* charstr = <char*>malloc(charstr_size*sizeof(char))
	WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, charstr, charstr_size, NULL, NULL)
	pystring = "" + charstr # "" is required to make a copy of char* otherwise you will get a pointer that will be freed on next line.
	free(charstr)
	return pystring

def CheckInnerWindowID(innerWindowID):
	
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

cdef CefRefPtr[CefBrowser] GetCefBrowserByInnerWindowID(innerWindowID):
	
	# Map key exists: http://stackoverflow.com/questions/1939953/how-to-find-if-a-given-key-exists-in-a-c-stdmap
	if not innerWindowID:
		raise Exception("Browser was destroyed (innerWindowID empty)")
	if __cefBrowsers.find(<int>innerWindowID) == __cefBrowsers.end():
		raise Exception("Browser was destroyed (__cefBrowsers.find() failed)")
	if <CefBrowser*>((__cefBrowsers[<int>innerWindowID]).get()):
		return __cefBrowsers[<int>innerWindowID]
	else:
		raise Exception("Browser was destroyed (CefRefPtr.get() failed)")

cdef CefRefPtr[CefBrowser] GetCefBrowserByTopWindowID(windowID):
	
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