# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

STATUSTYPE_TEXT = <int>cef_types.STATUSTYPE_TEXT
STATUSTYPE_MOUSEOVER_URL = <int>cef_types.STATUSTYPE_MOUSEOVER_URL
STATUSTYPE_KEYBOARD_FOCUS_URL = <int>cef_types.STATUSTYPE_KEYBOARD_FOCUS_URL

cdef public void DisplayHandler_OnAddressChange(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefString& cefURL
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnAddressChange() failed: pyBrowser is %s" % pyBrowser)
			return
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		pyURL = CefStringToPyString(cefURL)
		handler = pyBrowser.GetClientHandler("OnAddressChange")
		if handler:
			handler(pyBrowser, pyFrame, pyURL)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool DisplayHandler_OnConsoleMessage(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefMessage,
		CefString& cefSource,
		int line
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnConsoleMessage() failed: pyBrowser is %s" % pyBrowser)
			return False
		pyMessage = CefStringToPyString(cefMessage)
		pySource = CefStringToPyString(cefSource)
		handler = pyBrowser.GetClientHandler("OnConsoleMessage")
		if handler:
			return bool(handler(pyBrowser, pyMessage, pySource, line))
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnContentsSizeChange(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		int width,
		int height
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnContentsSizeChange() failed: pyBrowser is %s" % pyBrowser)
			return
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		handler = pyBrowser.GetClientHandler("OnContentsSizeChange")
		if handler:
			handler(pyBrowser, pyFrame, width, height)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnNavStateChange(
		CefRefPtr[CefBrowser] cefBrowser,
		c_bool canGoBack,
		c_bool canGoForward
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnNavStateChange() failed: pyBrowser is %s" % pyBrowser)
			return
		handler = pyBrowser.GetClientHandler("OnNavStateChange")
		if handler:
			handler(pyBrowser, canGoBack, canGoForward)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnStatusMessage(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefText,
		cef_types.cef_handler_statustype_t statusType
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnStatusMessage() failed: pyBrowser is %s" % pyBrowser)
			return
		pyText = CefStringToPyString(cefText)
		handler = pyBrowser.GetClientHandler("OnStatusMessage")
		if handler:
			handler(pyBrowser, pyText, statusType)
		return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DisplayHandler_OnTitleChange(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefTitle
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)	
		if not pyBrowser:
			Debug("DisplayHandler_OnTitleChange() failed: pyBrowser is %s" % pyBrowser)
			return
		pyTitle = CefStringToPyString(cefTitle)
		handler = pyBrowser.GetClientHandler("OnTitleChange")
		if handler:
			ret = bool(handler(pyBrowser, pyTitle))
			IF UNAME_SYSNAME == "Windows":
				if ret:
					WindowUtils.SetTitle(pyBrowser, pyTitle)
					WindowUtils.SetIcon(pyBrowser, "inherit")
			return
		else:
			IF UNAME_SYSNAME == "Windows":
				WindowUtils.SetTitle(pyBrowser, pyTitle)
				WindowUtils.SetIcon(pyBrowser, "inherit")
			return
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool DisplayHandler_OnTooltip(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefText
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("DisplayHandler_OnTooltip() failed: pyBrowser is %s" % pyBrowser)
			return False
		pyText = [CefStringToPyString(cefText)] # In/Out
		handler = pyBrowser.GetClientHandler("OnTooltip")
		if handler:
			ret = handler(pyBrowser, pyText)
			PyStringToCefString(pyText[0], cefText);
			return bool(ret)
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

