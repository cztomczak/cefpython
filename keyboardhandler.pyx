# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

KEYEVENT_RAWKEYDOWN = <int>cef_types.KEYEVENT_RAWKEYDOWN
KEYEVENT_KEYDOWN = <int>cef_types.KEYEVENT_KEYDOWN
KEYEVENT_KEYUP = <int>cef_types.KEYEVENT_KEYUP
KEYEVENT_CHAR = <int>cef_types.KEYEVENT_CHAR

KEY_SHIFT = <int>cef_types.KEY_SHIFT
KEY_CTRL = <int>cef_types.KEY_CTRL
KEY_ALT = <int>cef_types.KEY_ALT
KEY_META  = <int>cef_types.KEY_META
KEY_KEYPAD = <int>cef_types.KEY_KEYPAD

def InitializeKeyboardHandler():

	# Callbacks - make sure event names are proper - hard to detect error.
	# Call it in cefpython.pyx > __InitializeClientHandler().
	global __clientHandler
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnKeyEvent(<OnKeyEvent_type>KeyboardHandler_OnKeyEvent)

cdef cbool KeyboardHandler_OnKeyEvent(
		CefRefPtr[CefBrowser] cefBrowser,
		cef_types.cef_handler_keyevent_type_t eventType,
		int code,
		int modifiers,
		cbool isSystemKey,
		cbool isAfterJavascript) except * with gil:

	# See LoadHandler_OnLoadEnd() for the try..except explanation.
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		handler = pyBrowser.GetClientHandler("OnKeyEvent")
		if type(handler) is tuple:
			# Not handler[2], because in popups handler[2] is already assigned to handler[0] in GetPyBrowserByCefBrowser()
			handler = handler[0]
		if handler:
			return <cbool>bool(handler(pyBrowser, <int>eventType, code, modifiers, isSystemKey, isAfterJavascript))
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

