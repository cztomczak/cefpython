# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"
include "javascriptcallback.pyx"
include "pythoncallback.pyx"

# CefV8 Objects, Arrays and Functions can be created only inside V8 context,
# you need to call CefV8Context::Enter() and CefV8Context::Exit():
# http://code.google.com/p/chromiumembedded/issues/detail?id=203
# Entering context should be done for Frame::CallFunction().

cdef object V8ValueToPyValue(CefRefPtr[CefV8Value] v8Value, CefRefPtr[CefV8Context] v8Context, nestingLevel=0) except *:

	# With nestingLevel > 10 we get win32 exceptions.

	if nestingLevel > 8:
		print("raising exception...")
		raise Exception("V8ValueToPyValue() failed: data passed from Javascript to Python has"
				" more than 8 levels of nesting, this is probably an infinite recursion, stopping.")

	if __debug:
		# print("V8ValueToPyValue nestingLevel: %s" % nestingLevel)
		pass

	cdef CefV8Value* v8ValuePtr = <CefV8Value*>(v8Value.get())
	cdef CefString cefString
	cdef CefString cefFuncName
	cdef vector[CefString] keys
	cdef vector[CefString].iterator iterator

	cdef CefRefPtr[CefV8Value] v8JavascriptCallback
	cdef CefRefPtr[V8FunctionHandler] v8FunctionHandler # V8FunctionHandler inherits from V8Handler.
	cdef CefRefPtr[CefV8Handler] v8Handler

	if v8ValuePtr.IsArray():
		# A test against IsArray should be done before IsObject().
		# Remember about increasing the nestingLevel.
		arrayLength = v8ValuePtr.GetArrayLength()
		pyarray = []
		for key in range(0, arrayLength):
			pyarray.append(V8ValueToPyValue(v8ValuePtr.GetValue(<int>int(key)), v8Context, nestingLevel+1))
		return pyarray
	elif v8ValuePtr.IsBool():
		return v8ValuePtr.GetBoolValue()
	elif v8ValuePtr.IsDate():
		raise Exception("V8ValueToPyValue() failed: Date object is not supported, you are not allowed"
				"to pass it from Javascript to Python.")
	elif v8ValuePtr.IsUInt():
		# Check against uint must be done before IsInt().
		return v8ValuePtr.GetUIntValue()
	elif v8ValuePtr.IsInt():
		# A check against IsInt() must be done before IsDouble(), as any js integer
		# returns true when calling IsDouble().
		return v8ValuePtr.GetIntValue()
	elif v8ValuePtr.IsDouble():
		return v8ValuePtr.GetDoubleValue()
	elif v8ValuePtr.IsFunction():
		callbackID = PutV8JavascriptCallback(v8Value, v8Context)
		return JavascriptCallback(callbackID)
	elif v8ValuePtr.IsNull():
		return None
	elif v8ValuePtr.IsObject():
		# A test against IsObject() should be done after IsArray().
		# Remember about increasing the nestingLevel.
		v8ValuePtr.GetKeys(keys)
		iterator = keys.begin()
		pydict = dict()
		while iterator != keys.end():
			cefString = deref(iterator)
			key = CefStringToPyString(cefString)
			value = V8ValueToPyValue(v8ValuePtr.GetValue(cefString), v8Context, nestingLevel+1)
			pydict[key] = value
			preinc(iterator)
		return pydict
	elif v8ValuePtr.IsString():
		return CefStringToPyString(v8ValuePtr.GetStringValue())
	elif v8ValuePtr.IsUndefined():
		return None
	else:
		raise Exception("V8ValueToPyValue() failed: unknown type of CefV8Value.")


cdef CefRefPtr[CefV8Value] PyValueToV8Value(object pyValue, CefRefPtr[CefV8Context] v8Context, nestingLevel=0) except *:

	# With nestingLevel > 10 we get win32 exceptions.

	if nestingLevel > 8:
		raise Exception("PyValueToV8Value() failed: data passed from Python to Javascript has"
				" more than 8 levels of nesting, this is probably an infinite recursion, stopping.")

	if __debug:
		# print("PyValueToV8Value nestingLevel: %s" % nestingLevel)
		pass

	cdef CefString cefString
	cdef CefRefPtr[CefV8Value] v8Value # not initialized, later we assign using "cef_v8_static.Create...()"
	cdef CefString cefFuncName

	pyValueType = type(pyValue)

	# Issue 10: support for unicode and tuple.
	# http://code.google.com/p/cefpython/issues/detail?id=10

	if bytes == str: 
		# Python 2.7
		if pyValueType == unicode: # unicode string to bytes string
			pyValue = pyValue.encode(__applicationSettings["unicode_to_bytes_encoding"])
	else:
		# Python 3.2
		if pyValueType == bytes: # bytes to string
			pyValue = pyValue.decode(__applicationSettings["unicode_to_bytes_encoding"])
	
	if pyValueType == tuple:
		pyValue = list(pyValue)

	# Check type again, as code above might have changed it.
	pyValueType = type(pyValue)

	if pyValueType == list:
		# Remember about increasing nestingLevel.
		v8Value = cef_v8_static.CreateArray(len(pyValue))
		for index,value in enumerate(pyValue):
			(<CefV8Value*>(v8Value.get())).SetValue(int(index), PyValueToV8Value(value, v8Context, nestingLevel+1))
		return v8Value
	elif pyValueType == bool:
		return cef_v8_static.CreateBool(bool(pyValue))
	elif pyValueType == int:
		return cef_v8_static.CreateInt(int(pyValue))
	elif pyValueType == float:
		return cef_v8_static.CreateDouble(float(pyValue))
	elif pyValueType == types.FunctionType or pyValueType == types.MethodType:
		v8FunctionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
		(<V8FunctionHandler*>(v8FunctionHandler.get())).SetContext(v8Context)
		(<V8FunctionHandler*>(v8FunctionHandler.get())).SetCallback_V8Execute(<V8Execute_type>FunctionHandler_Execute)
		v8Handler = <CefRefPtr[CefV8Handler]> <CefV8Handler*>(<V8FunctionHandler*>(v8FunctionHandler.get()))
		PyStringToCefString(pyValue.__name__, cefFuncName)
		v8Value = cef_v8_static.CreateFunction(cefFuncName, v8Handler) # v8PythonCallback
		callbackID = PutPythonCallback(pyValue)
		(<V8FunctionHandler*>(v8FunctionHandler.get())).SetCallback_DelPythonCallback(<DelPythonCallback_type>DelPythonCallback)
		(<V8FunctionHandler*>(v8FunctionHandler.get())).SetPythonCallbackID(callbackID)
		return v8Value
	elif pyValueType == type(None):
		return cef_v8_static.CreateNull()
	elif pyValueType == dict:
		v8Value = cef_v8_static.CreateObject(<CefRefPtr[CefV8Accessor]>NULL)
		for key, value in pyValue.items():
			# A dict may have an int key, a string key or even a tuple key:
			# {0: 12, '0': 12, (0, 1): 123}
			# Remember about increasing nestingLevel.
			key = str(key)
			PyStringToCefString(key, cefString)
			(<CefV8Value*>(v8Value.get())).SetValue(cefString, PyValueToV8Value(value, v8Context, nestingLevel+1), V8_PROPERTY_ATTRIBUTE_NONE)
		return v8Value
	elif pyValueType == str:
		PyStringToCefString(pyValue, cefString)
		return cef_v8_static.CreateString(cefString)
	else:
		raise Exception("PyValueToV8Value() failed: an unsupported python type was passed from"
				" python to javascript: %s, value: %s" % (pyValueType.__name__, pyValue))
