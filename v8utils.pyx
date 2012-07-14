# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

# CefV8 Objects, Arrays and Functions can be created only inside V8 context,
# you need to call CefV8Context::Enter() and CefV8Context::Exit():
# http://code.google.com/p/chromiumembedded/issues/detail?id=203

# Javascript arrays may have missing keys, iterating using GetArrayLength()
# will not work, example: a = [1,2]; a[10] = 3;

# Test passing "window" object from javascript, whether nesting level protection works.

cdef object V8ValueToPyValue(CefRefPtr[CefV8Value] v8Value, nestingLevel=0):

	if nestingLevel > 10:
		raise Exception("V8ValueToPyValue() failed: data passed from Javascript to Python has"
				"more than 10 levels of nesting, this is probably an infinite recursion, stopping.")

	cdef CefV8Value* v8ValuePtr = <CefV8Value*>(v8Value.get())

	if v8ValuePtr.IsArray():
		# nestingLevel+1
		# TODO
		pass
	elif v8ValuePtr.IsBool():
		return v8ValuePtr.GetBoolValue()
	elif v8ValuePtr.IsDate():
		raise Exception("V8ValueToPyValue() failed: Date object is not supported, you are not allowed"
				"to pass it from Javascript to Python.")
	elif v8ValuePtr.IsDouble():
		return v8ValuePtr.GetDoubleValue()
	elif v8ValuePtr.IsFunction():
		# TODO: JavascriptCallback
		# v8Value.GetFunctionName()
		pass
	elif v8ValuePtr.IsInt():
		return v8ValuePtr.GetIntValue()
	elif v8ValuePtr.IsNull():
		return None
	elif v8ValuePtr.IsObject():
		# nestingLevel+1
		# TODO
		pass
	elif v8ValuePtr.IsString():
		return CefStringToPyString(v8ValuePtr.GetStringValue())
	elif v8ValuePtr.IsUndefined():
		return None
	else:
		raise Exception("V8ValueToPyValue() failed: unknown type of CefV8Value.")


cdef CefRefPtr[CefV8Value] PyValueToV8Value(object pyValue, nestingLevel=0):

	if nestingLevel > 10:
		raise Exception("PyValueToV8Value() failed: data passed from Python to Javascript has"
				"more than 10 levels of nesting, this is probably an infinite recursion, stopping.")

	#cdef CefRefPtr[CefV8Value] v8Value
	cdef CefString cefString

	pyValueType = type(pyValue)

	if pyValueType == types.ListType:
		# TODO
		pass
	elif pyValueType == types.BooleanType:
		return cef_v8_static.CreateBool(bool(pyValue))
	elif pyValueType == types.FloatType:
		return cef_v8_static.CreateDouble(float(pyValue))
	elif pyValueType == types.FunctionType or pyValueType == types.MethodType:
		# TODO: passing callbacks from Python to Javascript.
		pass
	elif pyValueType == types.IntType:
		return cef_v8_static.CreateInt(int(pyValue))
	elif pyValueType == types.NoneType:
		return cef_v8_static.CreateNull()
	elif pyValueType == types.DictType:
		# TODO
		pass
	elif pyValueType == types.StringType:
		cefString.FromASCII(<char*>pyValue)
		return cef_v8_static.CreateString(cefString)
	else:
		raise Exception("PyValueToV8Value() failed: an unsupported python type was passed from"
				" python to javascript: %s" % pyValueType.__name__)
