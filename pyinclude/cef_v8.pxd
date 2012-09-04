# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from libcpp.vector cimport vector
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
from cef_string cimport CefString
from cef_base cimport CefBase
from libcpp cimport bool as cbool
from libcpp.vector cimport vector
cimport cef_types

cdef extern from "include/cef_v8.h":

	cdef cppclass CefV8Context(CefBase):

		CefRefPtr[CefV8Value] GetGlobal()
		CefRefPtr[CefBrowser] GetBrowser()
		CefRefPtr[CefFrame] GetFrame()

	ctypedef vector[CefRefPtr[CefV8Value]] CefV8ValueList

	cdef cppclass CefV8Accessor(CefBase):
		pass

	cdef cppclass CefV8Handler(CefBase):
		pass

	cdef cppclass CefV8Exception(CefBase):

		int GetLineNumber()
		CefString GetMessage()
		CefString GetScriptResourceName()
		CefString GetSourceLine()

	cdef cppclass CefV8Value(CefBase):
		
		CefRefPtr[CefV8Value] ExecuteFunctionWithContext(
			CefRefPtr[CefV8Context] context,
		        CefRefPtr[CefV8Value] object,
		        CefV8ValueList& arguments)

		int GetArrayLength()
		cbool GetBoolValue()
		double GetDoubleValue()
		CefString GetFunctionName()
		int GetIntValue()
		unsigned int GetUIntValue()
		cbool GetKeys(vector[CefString]& keys)
		CefString GetStringValue()
		
		CefRefPtr[CefV8Value] GetValue(CefString& key) # object's property by key
		CefRefPtr[CefV8Value] GetValue(int index) # arrays index value
		
		cbool HasValue(CefString& key)
		cbool HasValue(int index)

		cbool SetValue(CefString& key, CefRefPtr[CefV8Value] value, cef_types.cef_v8_propertyattribute_t attribute)
		cbool SetValue(int index, CefRefPtr[CefV8Value] value)
		
		cbool IsArray()
		cbool IsBool()
		cbool IsDate()
		cbool IsDouble()
		cbool IsFunction()
		cbool IsInt()
		cbool IsUInt()
		cbool IsNull()
		cbool IsObject()
		cbool IsString()
		cbool IsUndefined()		

		cbool HasException()
		CefRefPtr[CefV8Exception] GetException()
		cbool ClearException()

	cdef cppclass CefV8StackTrace(CefBase):		
		pass

	cdef cppclass CefV8StackFrame(CefBase):
		pass




