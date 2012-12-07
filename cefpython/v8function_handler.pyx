# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public c_bool V8FunctionHandler_Execute(
		CefRefPtr[CefV8Context] v8Context,
		int pythonCallbackID,
		CefString& cefFuncName,
		CefRefPtr[CefV8Value] cefObject, # receiver ('this' object) of the function.
		CefV8ValueList& v8Arguments,
		CefRefPtr[CefV8Value]& cefRetval,
		CefString& cefException) except * with gil:

	cdef PyBrowser pyBrowser
	cdef PyFrame pyFrame
	cdef JavascriptBindings javascriptBindings
	cdef c_vector[CefRefPtr[CefV8Value]].iterator iterator
	cdef CefRefPtr[CefV8Value] cefValue

	try:
		if pythonCallbackID:

			func = GetPythonCallback(pythonCallbackID)
			arguments = []
			iterator = v8Arguments.begin()
			while iterator != v8Arguments.end():
				cefValue = deref(iterator)
				# V8ValueToPyValue() creates V8Functionhandler().
				arguments.append(V8ValueToPyValue(cefValue, v8Context))
				preinc(iterator)

			retval = func(*arguments)
			cefRetval = PyValueToV8Value(retval, v8Context)

			return <c_bool>True

		else:

			# V8ContextHandler_OnContextCreated() creates V8Functionhandler() - JavascriptBindings.

			pyBrowser = GetPyBrowser(v8Context.get().GetBrowser())
			pyFrame = GetPyFrame(v8Context.get().GetFrame())
			funcName = ToPyString(cefFuncName)

			javascriptBindings = pyBrowser.GetJavascriptBindings()
			if not javascriptBindings:
				return <c_bool>False

			if funcName.find(".") == -1:
				func = javascriptBindings.GetFunction(funcName)
				if not func:
					return <c_bool>False
			else:
				method = funcName.split(".") # "myobject.someMethod"
				func = javascriptBindings.GetObjectMethod(method[0], method[1]) # "myobject", "someMethod"
				if not func:
					return <c_bool>False

			# This checks GetBindToFrames/GetBindToPopups must also be made in both:
			# V8FunctionHandler_Execute() and OnContextCreated(), so that calling 
			# a non-existent  property on window object throws an error.

			if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
				return <c_bool>False

			# This check is probably not needed, as GetPyBrowser() will already pass bindings=None,
			# if this is a popup window and bindToPopups is False.

			if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
				return <c_bool>False

			arguments = []
			iterator = v8Arguments.begin()
			while iterator != v8Arguments.end():
				cefValue = deref(iterator)
				arguments.append(V8ValueToPyValue(cefValue, v8Context))
				preinc(iterator)

			retval = func(*arguments)
			cefRetval = PyValueToV8Value(retval, v8Context)

			return <c_bool>True

	except:

		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)
