# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

cdef public c_bool LifeSpanHandler_DoClose(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LifeSpanHandler_DoClose() failed: pyBrowser is %s" % pyBrowser)
			return False
		handler = pyBrowser.GetClientHandler("DoClose")
		if handler:
			return bool(handler(pyBrowser))
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LifeSpanHandler_OnAfterCreated(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LifeSpanHandler_OnAfterCreated() failed: pyBrowser is %s" % pyBrowser)
			return
		
		# Popup windows has no mouse/keyboard focus (Issue 14).
		pyBrowser.SetFocus(True)

		handler = pyBrowser.GetClientHandler("OnAfterCreated")
		if handler:
			handler(pyBrowser)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void LifeSpanHandler_OnBeforeClose(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LifeSpanHandler_OnBeforeClose() failed: pyBrowser is %s" % pyBrowser)
			return
		handler = pyBrowser.GetClientHandler("OnBeforeClose")
		if handler:
			handler(pyBrowser)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool LifeSpanHandler_RunModal(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LifeSpanHandler_RunModal() failed: pyBrowser is %s" % pyBrowser)
			return False
		handler = pyBrowser.GetClientHandler("RunModal")
		if handler:
			return bool(handler(pyBrowser))
		return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

