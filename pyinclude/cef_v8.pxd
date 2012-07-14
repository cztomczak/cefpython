# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from libcpp.vector cimport vector
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
from cef_string cimport CefString
from libcpp cimport bool as cbool
from libcpp.vector cimport vector
cimport cef_types

cdef extern from "include/cef_v8.h":

	cdef cppclass CefV8Context:
		CefRefPtr[CefV8Value] GetGlobal()
		CefRefPtr[CefBrowser] GetBrowser()
		CefRefPtr[CefFrame] GetFrame()

	ctypedef vector[CefRefPtr[CefV8Value]] CefV8ValueList

	cdef cppclass CefV8Accessor:
		pass

	cdef cppclass CefV8Handler:
		pass

	cdef cppclass CefV8Value:
		int GetArrayLength()
		cbool GetBoolValue()
		double GetDoubleValue()
		CefString GetFunctionName()
		int GetIntValue()
		cbool GetKeys(vector[CefString]& keys)
		CefString GetStringValue()
		CefRefPtr[CefV8Value] GetValue(CefString& key) # object's property by key
		CefRefPtr[CefV8Value] GetValue(int index) # arrays index value
		cbool HasValue(CefString& key)
		cbool HasValue(int index)
		cbool IsArray()
		cbool IsBool()
		cbool IsDate()
		cbool IsDouble()
		cbool IsFunction()
		cbool IsInt()
		cbool IsNull()
		cbool IsObject()
		cbool IsString()
		cbool IsUndefined()
		cbool SetValue(
			CefString& key,
			CefRefPtr[CefV8Value] value,
		        cef_types.cef_v8_propertyattribute_t attribute
		)


