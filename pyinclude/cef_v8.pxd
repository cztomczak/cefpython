# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from libcpp.vector cimport vector
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
from cef_string cimport CefString
from libcpp cimport bool as cbool
cimport cef_types

cdef extern from "include/cef_v8.h":

	cdef cppclass CefV8Context:
		CefRefPtr[CefV8Value] GetGlobal()
		CefRefPtr[CefBrowser] GetBrowser()
		CefRefPtr[CefFrame] GetFrame()

	ctypedef vector[CefRefPtr[CefV8Value]] CefV8ValueList

	cdef cppclass CefV8Handler:
		pass

	cdef cppclass CefV8Value:
		cbool SetValue(
			CefString& key,
			CefRefPtr[CefV8Value] value,
		        cef_types.cef_v8_propertyattribute_t attribute
		)


cdef extern from "include/cef_v8.h" namespace "CefV8Value":

	cdef CefRefPtr[CefV8Value] CreateFunction(
			CefString& name,
	                CefRefPtr[CefV8Handler] handler)