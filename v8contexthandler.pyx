# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "functionhandler.pyx"

def InitializeV8ContextHandler():
	# Callbacks - make sure event names are
	global __clientHandler
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnContextCreated(
		<OnContextCreated_type>V8ContextHandler_OnContextCreated)

cdef void V8ContextHandler_OnContextCreated(
			CefRefPtr[CefBrowser] cefBrowser,
			CefRefPtr[CefFrame] cefFrame,
			CefRefPtr[CefV8Context] cefContext) with gil:

	cdef CefRefPtr[V8FunctionHandler] functionHandler
	cdef CefRefPtr[CefV8Handler] v8Handler
	cdef CefRefPtr[CefV8Value] window
	cdef CefRefPtr[CefV8Value] func
	cdef CefString cefFuncName

	# See LoadHandler_OnLoadEnd() for the try..except explanation.
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyFrame = GetPyFrameByCefFrame(cefFrame)

		# javascriptBindings is a JavascriptBindings class.
		javascriptBindings = pyBrowser.GetJavascriptBindings()
		if not javascriptBindings:
			return

		# jsBindings is a dict.
		jsBindings = javascriptBindings.GetFunctions()
		if not jsBindings:
			return

		# This checks GetBind..() must be also made in OnContextCreated(), so that calling
		# a non-existent property on window object throws an error.

		if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
			return

		# This check is probably not needed, as GetPyBrowserByCefBrowser() will already pass javascriptBindings=None,
		# if this is a popup window and bindToPopups is False.
		if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
			return

		print "V8ContextHandler_OnContextCreated()"

		# CefRefPtr are smart pointers and should release memory automatically for V8FunctionHandler().
		functionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
		(<V8FunctionHandler*>(functionHandler.get())).SetContext(cefContext)
		(<V8FunctionHandler*>(functionHandler.get())).SetCallback_V8Execute(<V8Execute_type>FunctionHandler_Execute)
		v8Handler = <CefRefPtr[CefV8Handler]> <CefV8Handler*>(<V8FunctionHandler*>(functionHandler.get()))
		window = (<CefV8Context*>(cefContext.get())).GetGlobal()

		for funcName in jsBindings:
			cefFuncName = CefString()
			cefFuncName.FromASCII(<char*>funcName)
			func = cef_v8_static.CreateFunction(cefFuncName, v8Handler)
			(<CefV8Value*>(window.get())).SetValue(cefFuncName, func, V8_PROPERTY_ATTRIBUTE_NONE)

		# return void

	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

# enum cef_v8_propertyattribute_t.
V8_PROPERTY_ATTRIBUTE_NONE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_NONE
V8_PROPERTY_ATTRIBUTE_READONLY = <int>cef_types.V8_PROPERTY_ATTRIBUTE_READONLY
V8_PROPERTY_ATTRIBUTE_DONTENUM = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTENUM
V8_PROPERTY_ATTRIBUTE_DONTDELETE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTDELETE
