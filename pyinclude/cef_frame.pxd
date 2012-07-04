# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cimport cef_types
cimport cef_string

cdef extern from "include/cef_frame.h":
	
	cdef cppclass CefFrame:
		
		void ExecuteJavaScript(cef_string.CefString& jsCode, cef_string.CefString& scriptUrl, int startLine)
		
		cef_types.int64 GetIdentifier() # int64 = long long
		cef_string.CefString GetSource()
		void SelectAll()