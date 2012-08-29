# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cbool
from cef_string cimport CefString
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Value
from cef_v8 cimport CefV8ValueList
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Context

cdef extern from "v8functionhandler/v8functionhandler.h":

	# CefV8Handler.Execute() type.
	ctypedef cbool (*V8Execute_type)(
			CefRefPtr[CefV8Context] context,
			int pythonCallbackID,
			CefString& name,
			CefRefPtr[CefV8Value] object,
			CefV8ValueList& arguments,
			CefRefPtr[CefV8Value]& retval,
			CefString& exception
	)

	# DelPythonCallbac() type.
	ctypedef void (*DelPythonCallback_type)(
			int callbackID
	)

	cdef cppclass CefV8Handler:
		pass

	# V8FunctionHandler class.
	cdef cppclass V8FunctionHandler(CefV8Handler):
		# V8FunctionHandler callbacks.
		void SetCallback_V8Execute(V8Execute_type)
		void SetCallback_DelPythonCallback(DelPythonCallback_type)
		# Context.
		void SetContext(CefRefPtr[CefV8Context])
		void SetPythonCallbackID(int callbackID)
		CefRefPtr[CefV8Context] GetContext()