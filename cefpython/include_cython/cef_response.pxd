# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase
from cef_string cimport CefString
from multimap cimport multimap

cdef extern from "include/cef_response.h":

	ctypedef multimap[CefString, CefString] HeaderMap
	
	cdef cppclass CefResponse(CefBase):
		
		int GetStatus()
		void SetStatus(int status)
		CefString GetStatusText()
		void SetStatusText(CefString& statusText)
		CefString GetMimeType()
		void SetMimeType(CefString& mimeType)
		CefString GetHeader(CefString& name)
		void GetHeaderMap(HeaderMap& headerMap)
		void SetHeaderMap(HeaderMap& headerMap)

