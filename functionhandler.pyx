# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "v8utils.pyx"

cdef cbool FunctionHandler_Execute(
		CefRefPtr[CefV8Context] cefContext,
		CefString& cefFuncName,
		CefRefPtr[CefV8Value] cefObject, # receiver ('this' object) of the function.
		CefV8ValueList& cefArguments,
		CefRefPtr[CefV8Value]& cefRetval,
		CefString& cefException) with gil:

	cdef vector[CefRefPtr[CefV8Value]].iterator iterator
	cdef CefRefPtr[CefV8Value] cefValue

	try:
		pyBrowser = GetPyBrowserByCefBrowser((<CefV8Context*>(cefContext.get())).GetBrowser())
		pyFrame = GetPyFrameByCefFrame((<CefV8Context*>(cefContext.get())).GetFrame())
		funcName = CefStringToPyString(cefFuncName)

		javascriptBindings = pyBrowser.GetJavascriptBindings()
		if not javascriptBindings:
			return <cbool>False

		func = javascriptBindings.GetFunction(funcName)
		if not func:
			return <cbool>False

		# This checks GetBind..() must be also made in OnContextCreated(), so that calling
		# a non-existent property on window object throws an error.

		if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
			return <cbool>False

		# This check is probably not needed, as GetPyBrowserByCefBrowser() will already pass javascriptBindings=None,
		# if this is a popup window and bindToPopups is False.
		if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
			return <cbool>False

		arguments = []

		# cefArguments.
		iterator = cefArguments.begin()
		while iterator != cefArguments.end():
			cefValue = deref(iterator)
			arguments.append(V8ValueToPyValue(cefValue))
			preinc(iterator)

		retval = func(*arguments)
		cefRetval = PyValueToV8Value(retval)

		return <cbool>True

	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)
