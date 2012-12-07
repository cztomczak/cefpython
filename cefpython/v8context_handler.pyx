# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# enum cef_v8_propertyattribute_t.
V8_PROPERTY_ATTRIBUTE_NONE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_NONE
V8_PROPERTY_ATTRIBUTE_READONLY = <int>cef_types.V8_PROPERTY_ATTRIBUTE_READONLY
V8_PROPERTY_ATTRIBUTE_DONTENUM = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTENUM
V8_PROPERTY_ATTRIBUTE_DONTDELETE = <int>cef_types.V8_PROPERTY_ATTRIBUTE_DONTDELETE

cdef public void V8ContextHandler_OnContextCreated(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefV8Context] cefContext
		) except * with gil:

	# This handler may also be called by JavascriptBindings.Rebind().
	# This handler may be called multiple times for the same frame - rebinding.

	cdef PyBrowser pyBrowser
	cdef PyFrame pyFrame
	cdef JavascriptBindings javascriptBindings

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
		# No need for second param ignoreError=True.
		pyBrowser = GetPyBrowser(cefBrowser)
		pyFrame = GetPyFrame(cefFrame)

		javascriptBindings = pyBrowser.GetJavascriptBindings()
		if not javascriptBindings:
			return

		if pyFrame.IsMain():
			javascriptBindings.AddFrame(pyBrowser, pyFrame)
		else:
			if javascriptBindings.GetBindToFrames():
				javascriptBindings.AddFrame(pyBrowser, pyFrame)

		# jsFunctions is a dict.
		jsFunctions = javascriptBindings.GetFunctions()
		jsProperties = javascriptBindings.GetProperties()
		jsObjects = javascriptBindings.GetObjects()

		if not jsFunctions and not jsProperties and not jsObjects:
			return

		# This checks GetBindToFrames/GetBindToPopups must also be made in both:
		# FunctionHandler_Execute() and OnContextCreated(), so that calling 
		# a non-existent  property on window object throws an error.

		if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
			return

		# This check is probably not needed, as GetPyBrowser() will already pass bindings=None,
		# if this is a popup window and bindToPopups is False.

		if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
			return

		window = cefContext.get().GetGlobal()

		if jsProperties:
			for key,val in jsProperties.items():
				key = str(key)
				ToCefString(key, cefPropertyName)
				window.get().SetValue(cefPropertyName, PyValueToV8Value(val, cefContext), V8_PROPERTY_ATTRIBUTE_NONE)

		if jsFunctions or jsObjects:
			
			# CefRefPtr are smart pointers and should release memory automatically for V8FunctionHandler().
			functionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
			functionHandler.get().SetContext(cefContext)
			v8Handler = <CefRefPtr[CefV8Handler]><CefV8Handler*>functionHandler.get()

		if jsFunctions:

			for funcName in jsFunctions:
				
				funcName = str(funcName)
				ToCefString(funcName, cefFuncName)
				func = cef_v8_static.CreateFunction(cefFuncName, v8Handler)
				window.get().SetValue(cefFuncName, func, V8_PROPERTY_ATTRIBUTE_NONE)

		if jsObjects:

			for objectName in jsObjects:

				# Create V8Value object.
				v8Object = cef_v8_static.CreateObject(<CefRefPtr[CefV8Accessor]>NULL)

				# Bind that object to window.
				ToCefString(objectName, cefObjectName)
				window.get().SetValue(cefObjectName, v8Object, V8_PROPERTY_ATTRIBUTE_NONE)

				for methodName in jsObjects[objectName]:
					
					# Bind methods to that V8 object.
					methodName = str(methodName) # methodName = "someMethod"
					
					ToCefString(objectName+"."+methodName, cefMethodName) # cefMethodName = "myobject.someMethod"
					method = cef_v8_static.CreateFunction(cefMethodName, v8Handler)

					ToCefString(methodName, cefMethodName) # cefMethodName = "someMethod"
					v8Object.get().SetValue(cefMethodName, method, V8_PROPERTY_ATTRIBUTE_NONE)

		# return void

	except:

		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnContextReleased(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefV8Context] cefContext
		) except * with gil:
	
	cdef PyBrowser pyBrowser
	cdef PyFrame pyFrame
	cdef JavascriptBindings javascriptBindings
	try:
		# If this is the main frame, PyBrowser might be already destroyed.
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("V8ContextHandler_OnContextReleased() failed: pyBrowser is %s" % pyBrowser)
			return
		pyFrame = GetPyFrame(cefFrame)
		isMainFrame = pyFrame.IsMain()
		
		Debug("V8ContextHandler_OnContextReleased(): frameID = %s" % pyFrame.GetIdentifier())
		
		javascriptBindings = pyBrowser.GetJavascriptBindings()
		if javascriptBindings:
			javascriptBindings.RemoveFrame(pyBrowser, pyFrame)
		
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnUncaughtException(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefV8Context] cefContext,
		CefRefPtr[CefV8Exception] cefException,
		CefRefPtr[CefV8StackTrace] cefStackTrace) except * with gil:

	cdef PyBrowser pyBrowser
	cdef PyFrame pyFrame
	cdef CefRefPtr[CefV8Exception] v8Exception
	cdef CefV8Exception* v8ExceptionPtr

	try:
		# No need for second param ignoreError=True.
		pyBrowser = GetPyBrowser(cefBrowser)
		pyFrame = GetPyFrame(cefFrame)
		
		v8ExceptionPtr = cefException.get()
		pyException = {}
		pyException["lineNumber"] = v8ExceptionPtr.GetLineNumber()
		pyException["message"] = ToPyString(v8ExceptionPtr.GetMessage())
		pyException["scriptResourceName"] = ToPyString(v8ExceptionPtr.GetScriptResourceName())
		pyException["sourceLine"] = ToPyString(v8ExceptionPtr.GetSourceLine())
		
		pyStackTrace = CefV8StackTraceToPython(cefStackTrace)
		
		callback = pyBrowser.GetClientCallback("OnUncaughtException")
		if callback:
			callback(pyBrowser, pyFrame, pyException, pyStackTrace)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

