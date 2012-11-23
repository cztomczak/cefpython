# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

cdef public cbool LifeSpanHandler_DoClose(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
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
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		
		# Called when first browser has not yet been created.
		# ignoreError=True in GetPyBrowser.. is probably not required.
		if not pyBrowser:
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
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		
		# Called when last browser was destroyed.
		# ignoreError=True in GetPyBrowser.. is probably not required.
		if not pyBrowser:
			return

		handler = pyBrowser.GetClientHandler("OnBeforeClose")
		if handler:
			handler(pyBrowser)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cbool LifeSpanHandler_RunModal(
		CefRefPtr[CefBrowser] cefBrowser
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		handler = pyBrowser.GetClientHandler("RunModal")
		if handler:
			return bool(handler(pyBrowser))
		return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

