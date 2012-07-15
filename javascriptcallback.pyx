# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "v8utils.pyx"

cdef map[int, CefRefPtr[CefV8Value]] __v8JavascriptCallbacks
cdef map[int, CefRefPtr[CefV8Context]] __v8JavascriptCallbackContexts
cdef int __v8JavascriptCallbackCount = 0 # next callbackID

cdef int PutV8JavascriptCallback(CefRefPtr[CefV8Value] v8Value, CefRefPtr[CefV8Context] v8Context) except *:
	global __v8JavascriptCallbacks
	global __v8JavascriptCallbackContexts
	global __v8JavascriptCallbackCount
	__v8JavascriptCallbackCount = __v8JavascriptCallbackCount + 1
	cdef int callbackID = __v8JavascriptCallbackCount
	__v8JavascriptCallbacks[callbackID] = v8Value
	__v8JavascriptCallbackContexts[callbackID] = v8Context
	return callbackID

cdef CefRefPtr[CefV8Value] GetV8JavascriptCallback(int callbackID) except *:
	global __v8JavascriptCallbacks
	if __v8JavascriptCallbacks.find(callbackID) == __v8JavascriptCallbacks.end():
		raise Exception("GetV8JavascriptCallback() failed: invalid callbackID: %s" % callbackID)
	return __v8JavascriptCallbacks[callbackID]

cdef CefRefPtr[CefV8Context] GetV8JavascriptCallbackContext(int callbackID) except *:
	global __v8JavascriptCallbackContexts
	if __v8JavascriptCallbackContexts.find(callbackID) == __v8JavascriptCallbackContexts.end():
		raise Exception("GetV8JavascriptCallbackContext() failed: invalid callbackID: %s" % callbackID)
	return __v8JavascriptCallbackContexts[callbackID]

cdef void DelV8JavascriptCallback(int callbackID) except *:
	global __v8JavascriptCallbacks
	global __v8JavascriptCallbackContexts
	__v8JavascriptCallbacks.erase(callbackID)
	__v8JavascriptCallbackContexts.erase(callbackID)

class JavascriptCallback:

	__callbackID = None # an int

	def __init__(self, callbackID):
		assert callbackID, "JavascriptCallback.__init__() failed: callbackID is empty"
		self.__callbackID = callbackID

	def __del__(self):
		DelV8JavascriptCallback(self.__callbackID)

	def Call(self, *args):
		cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.__callbackID)
		cdef CefRefPtr[CefV8Context] v8Context = GetV8JavascriptCallbackContext(self.__callbackID)
		cdef CefV8ValueList v8Arguments
		cdef CefRefPtr[CefV8Value] v8Retval
		cdef CefRefPtr[CefV8Exception] v8Exception

		for i in range(0, len(args)):
			v8Arguments.push_back(PyValueToV8Value(args[i], v8Context))

		cdef cbool success = (<CefV8Value*>(v8Value.get())).ExecuteFunctionWithContext(v8Context, <CefRefPtr[CefV8Value]>NULL,
				v8Arguments, v8Retval, v8Exception, <cbool>False)

		cdef CefV8Exception* v8ExceptionPtr
		if <CefV8Exception*>(v8Exception.get()):
			v8ExceptionPtr = <CefV8Exception*>(v8Exception.get())
			lineNumber = v8ExceptionPtr.GetLineNumber()
			message = CefStringToPyString(v8ExceptionPtr.GetMessage())
			scriptResourceName = CefStringToPyString(v8ExceptionPtr.GetScriptResourceName())
			sourceLine = CefStringToPyString(v8ExceptionPtr.GetSourceLine())
			raise Exception("JavascriptCallback.Call() failed: javascript exception:\n\n %s.\n\n On line %s in %s.\n\n"
			                "Source of that line: %s" % (message, lineNumber, scriptResourceName, sourceLine))

		if not success:
			raise Exception("JavascriptCallback.Call() failed: ExecuteFunctionWithContext() called incorrectly")

		return V8ValueToPyValue(v8Retval, v8Context)

	def GetName(self):
		cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.__callbackID)
		cdef CefString cefFuncName
		cefFuncName = (<CefV8Value*>(v8Value.get())).GetFunctionName()
		return CefStringToPyString(cefFuncName)
