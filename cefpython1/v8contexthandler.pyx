# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "functionhandler.pyx"
include "v8utils.pyx"

def InitializeV8ContextHandler():

	# Callbacks - make sure event names are
	global __clientHandler
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnContextCreated(
		<OnContextCreated_type>V8ContextHandler_OnContextCreated)

cdef void V8ContextHandler_OnContextCreated(
			CefRefPtr[CefBrowser] cefBrowser,
			CefRefPtr[CefFrame] cefFrame,
			CefRefPtr[CefV8Context] v8Context) except * with gil:

	# This handler may also be called by JavascriptBindings.Rebind().
	# This handler may be called multiple times for the same frame - rebinding.

	cdef CefRefPtr[V8FunctionHandler] functionHandler
	cdef CefRefPtr[CefV8Handler] v8Handler
	cdef CefRefPtr[CefV8Value] window
	cdef CefRefPtr[CefV8Value] func
	cdef CefRefPtr[CefV8Value] v8Object
	cdef CefString cefFuncName
	cdef CefString cefPropertyName
	cdef CefString cefMethodName
	cdef CefString cefObjectName

	# See LoadHandler_OnLoadEnd() for the try..except explanation.
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyFrame = GetPyFrameByCefFrame(cefFrame)

		# bindings is a JavascriptBindings class.
		bindings = pyBrowser.GetJavascriptBindings()
		if not bindings:
			return

		if pyFrame.IsMain():
			bindings.AddFrame(pyBrowser, pyFrame)
		else:
			if bindings.GetBindToFrames():
				bindings.AddFrame(pyBrowser, pyFrame)

		# jsFunctions is a dict.
		jsFunctions = bindings.GetFunctions()
		jsProperties = bindings.GetProperties()
		jsObjects = bindings.GetObjects()

		if not jsFunctions and not jsProperties and not jsObjects:
			return

		# This checks GetBindToFrames/GetBindToPopups must also be made in both:
		# FunctionHandler_Execute() and OnContextCreated(), so that calling 
		# a non-existent  property on window object throws an error.

		if not pyFrame.IsMain() and not bindings.GetBindToFrames():
			return

		# This check is probably not needed, as GetPyBrowserByCefBrowser() will already pass bindings=None,
		# if this is a popup window and bindToPopups is False.

		if pyBrowser.IsPopup() and not bindings.GetBindToPopups():
			return

		window = (<CefV8Context*>(v8Context.get())).GetGlobal()

		if jsProperties:
			for key,val in jsProperties.items():
				key = str(key)
				PyStringToCefString(key, cefPropertyName)
				(<CefV8Value*>(window.get())).SetValue(cefPropertyName, PyValueToV8Value(val, v8Context), V8_PROPERTY_ATTRIBUTE_NONE)

		if jsFunctions or jsObjects:
			
			# CefRefPtr are smart pointers and should release memory automatically for V8FunctionHandler().
			functionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
			(<V8FunctionHandler*>(functionHandler.get())).SetContext(v8Context)
			(<V8FunctionHandler*>(functionHandler.get())).SetCallback_V8Execute(<V8Execute_type>FunctionHandler_Execute)
			v8Handler = <CefRefPtr[CefV8Handler]> <CefV8Handler*>(<V8FunctionHandler*>(functionHandler.get()))

		if jsFunctions:

			for funcName in jsFunctions:
				
				funcName = str(funcName)
				PyStringToCefString(funcName, cefFuncName)
				func = cef_v8_static.CreateFunction(cefFuncName, v8Handler)
				(<CefV8Value*>(window.get())).SetValue(cefFuncName, func, V8_PROPERTY_ATTRIBUTE_NONE)

		if jsObjects:

			for objectName in jsObjects:

				# Create V8Value object.
				v8Object = cef_v8_static.CreateObject(<CefRefPtr[CefV8Accessor]>NULL)

				# Bind that object to window.
				PyStringToCefString(objectName, cefObjectName)
				(<CefV8Value*>(window.get())).SetValue(cefObjectName, v8Object, V8_PROPERTY_ATTRIBUTE_NONE)

				for methodName in jsObjects[objectName]:
					
					# Bind methods to that V8 object.
					methodName = str(methodName) # methodName = "someMethod"
					
					PyStringToCefString(objectName+"."+methodName, cefMethodName) # cefMethodName = "myobject.someMethod"
					method = cef_v8_static.CreateFunction(cefMethodName, v8Handler)

					PyStringToCefString(methodName, cefMethodName) # cefMethodName = "someMethod"
					(<CefV8Value*>(v8Object.get())).SetValue(cefMethodName, method, V8_PROPERTY_ATTRIBUTE_NONE)

		# return void

	except:

		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

# enum cef_v8_propertyattribute_t.
V8_PROPERTY_ATTRIBUTE_NONE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_NONE
V8_PROPERTY_ATTRIBUTE_READONLY = <int>cef_types.V8_PROPERTY_ATTRIBUTE_READONLY
V8_PROPERTY_ATTRIBUTE_DONTENUM = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTENUM
V8_PROPERTY_ATTRIBUTE_DONTDELETE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTDELETE
