# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

# CefV8 Objects, Arrays and Functions can be created only inside V8 context,
# you need to call CefV8Context::Enter() and CefV8Context::Exit():
# http://code.google.com/p/chromiumembedded/issues/detail?id=203
# Entering context should be done for Frame::CallFunction().

# Javascript arrays may have missing keys, iterating using GetArrayLength()
# will not work, example: a = [1,2]; a[10] = 3;

# Test passing "window" object from javascript, whether nesting level protection works.

cdef object V8ValueToPyValue(CefRefPtr[CefV8Value] v8Value, nestingLevel=0):

	if nestingLevel > 10:
		raise Exception("V8ValueToPyValue() failed: data passed from Javascript to Python has"
				" more than 10 levels of nesting, this is probably an infinite recursion, stopping.")

	cdef CefV8Value* v8ValuePtr = <CefV8Value*>(v8Value.get())
	cdef CefString cefString
	cdef vector[CefString] keys
	cdef vector[CefString].iterator iterator

	if v8ValuePtr.IsArray():
		# A test against IsArray should be done before IsObject().
		# Remember about increasing the nestingLevel.
		arrayLength = v8ValuePtr.GetArrayLength()
		pyarray = []
		for key in xrange(0, arrayLength):
			pyarray.append(V8ValueToPyValue(v8ValuePtr.GetValue(<int>int(key)), nestingLevel+1))
		return pyarray
	elif v8ValuePtr.IsBool():
		return v8ValuePtr.GetBoolValue()
	elif v8ValuePtr.IsDate():
		raise Exception("V8ValueToPyValue() failed: Date object is not supported, you are not allowed"
				"to pass it from Javascript to Python.")
	elif v8ValuePtr.IsInt():
		# A check against IsInt() must be done before IsDouble(), as any js integer
		# returns true when calling IsDouble().
		return v8ValuePtr.GetIntValue()
	elif v8ValuePtr.IsDouble():
		return v8ValuePtr.GetDoubleValue()
	elif v8ValuePtr.IsFunction():
		# TODO: JavascriptCallback
		# v8Value.GetFunctionName()
		pass
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
			value = V8ValueToPyValue(v8ValuePtr.GetValue(cefString), nestingLevel+1)
			pydict[key] = value
			preinc(iterator)
		return pydict
	elif v8ValuePtr.IsString():
		return CefStringToPyString(v8ValuePtr.GetStringValue())
	elif v8ValuePtr.IsUndefined():
		return None
	else:
		raise Exception("V8ValueToPyValue() failed: unknown type of CefV8Value.")


cdef CefRefPtr[CefV8Value] PyValueToV8Value(object pyValue, nestingLevel=0) except *:

	if nestingLevel > 10:
		raise Exception("PyValueToV8Value() failed: data passed from Python to Javascript has"
				" more than 10 levels of nesting, this is probably an infinite recursion, stopping.")

	cdef CefString cefString
	cdef CefRefPtr[CefV8Value] v8Value

	pyValueType = type(pyValue)

	if pyValueType == types.ListType:
		# Remember about increasing nesting level.
		v8Value = cef_v8_static.CreateArray()
		for index,value in enumerate(pyValue):
			(<CefV8Value*>(v8Value.get())).SetValue(int(index), PyValueToV8Value(value, nestingLevel+1))
		return v8Value
	elif pyValueType == types.BooleanType:
		return cef_v8_static.CreateBool(bool(pyValue))
	elif pyValueType == types.IntType:
		return cef_v8_static.CreateInt(int(pyValue))
	elif pyValueType == types.FloatType:
		return cef_v8_static.CreateDouble(float(pyValue))
	elif pyValueType == types.FunctionType or pyValueType == types.MethodType:
		# TODO: passing callbacks from Python to Javascript.
		pass
	elif pyValueType == types.NoneType:
		return cef_v8_static.CreateNull()
	elif pyValueType == types.DictType:
		v8Value = cef_v8_static.CreateObject(<CefRefPtr[CefBase]>NULL, <CefRefPtr[CefV8Accessor]>NULL)
		for key, value in pyValue.items():
			# A dict may have an int key, a string key or even a tuple key:
			# {0: 12, '0': 12, (0, 1): 123}
			key = str(key)
			cefString.FromASCII(<char*>key)
			(<CefV8Value*>(v8Value.get())).SetValue(cefString, PyValueToV8Value(value, nestingLevel+1), V8_PROPERTY_ATTRIBUTE_NONE)
		return v8Value
	elif pyValueType == types.StringType:
		cefString.FromASCII(<char*>pyValue)
		return cef_v8_static.CreateString(cefString)
	else:
		raise Exception("PyValueToV8Value() failed: an unsupported python type was passed from"
				" python to javascript: %s" % pyValueType.__name__)
