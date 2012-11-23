# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase
from cef_string cimport CefString
from libcpp.map cimport map

cdef extern from "include/cef_response.h":

	# TODO: create .pxd for std::multimap
	# ctypedef multimap[CefString, CefString] HeaderMap
	
	cdef cppclass CefResponse(CefBase):
		
		int GetStatus()
		void SetStatus(int status)
		CefString GetStatusText()
		void SetStatusText(CefString& statusText)
		CefString GetMimeType()
		void SetMimeType(CefString& mimeType)
		CefString GetHeader(CefString& name)
		# virtual void GetHeaderMap(HeaderMap& headerMap) =0;
		# virtual void SetHeaderMap(const HeaderMap& headerMap) =0;

