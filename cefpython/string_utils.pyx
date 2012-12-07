# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef object ToPyString(CefString& cefString):

	cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
	cdef int charstr_bytes = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, NULL, 0, NULL, NULL)
	
	# When CefString is an empty string, WideCharToMultiByte returns 0 bytes, it does
	# not include the NUL character, so we need to use calloc instead of malloc.
	cdef char* charstr = <char*>calloc(charstr_bytes, sizeof(char))
	cdef int copied_bytes = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, charstr, charstr_bytes, NULL, NULL)
	
	if bytes == str:
		# Python 2.7, bytes and str are the same types.
		# "" + charstr >> makes a copy of char*
		pyString = "" + charstr
	else:
		# Python 3.
		pyString = (b"" + charstr).decode("utf-8", "ignore")
	free(charstr)
	return pyString

cdef void ToCefString(pyString, CefString& cefString) except *:
	
	if bytes == str: 
		# Python 2.7, bytes and str are the same types.
		if type(pyString) == unicode:
			pyString = pyString.encode(g_applicationSettings["unicode_to_bytes_encoding"])
	else: 
		# Python 3 requires bytes before converting to char*.
		if type(pyString) != bytes:
			pyString = pyString.encode("utf-8")	
	
	cdef c_string cString = pyString
	# When used cefString.FromASCII(), a DCHECK failed when passed a unicode string.
	cefString.FromString(cString)
		
cdef void ToCefStringPointer(pyString, CefString* cefString) except *:
	
	if bytes == str:
		# Python 2.7, bytes and str are the same types.
		if type(pyString) == unicode:
			pyString = pyString.encode(g_applicationSettings["unicode_to_bytes_encoding"])
		cefString.FromASCII(<char*>pyString)
	else:
		# Python 3 requires bytes before converting to char*.
		if type(pyString) != bytes:
			pyString = pyString.encode("utf-8")	
	
	cdef c_string cString = pyString
	# When used cefString.FromASCII(), a DCHECK failed when passed a unicode string.
	cefString.FromString(cString)
