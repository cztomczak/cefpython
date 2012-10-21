# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cbool
from stddef cimport wchar_t

cdef extern from "include/internal/cef_string.h":
	ctypedef struct cef_string_t:
		pass
	cdef cppclass CefString:
		CefString()
		CefString(cef_string_t*)
		cbool FromASCII(char*)
		cbool FromString(wchar_t*, size_t, cbool)
		wchar_t* ToWString()
		char* c_str()