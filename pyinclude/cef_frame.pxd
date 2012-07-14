# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_types cimport int64
from cef_string cimport CefString
from libcpp cimport bool as cbool
from cef_ptr cimport CefRefPtr
from cef_v8 cimport CefV8Context

cdef extern from "include/cef_frame.h":
	
	cdef cppclass CefFrame:
		
		void ExecuteJavaScript(CefString& jsCode, CefString& scriptUrl, int startLine)
		CefString GetURL()
		int64 GetIdentifier()
		CefString GetSource()
		CefRefPtr[CefV8Context] GetV8Context()
		cbool IsMain()
		void SelectAll()
