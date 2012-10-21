from stddef cimport wchar_t

cdef object WideCharToPyString(wchar_t *wcharstr):
	cdef int charstr_bytes = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, NULL, 0, NULL, NULL)
    cdef char* charstr = <char*>calloc(charstr_bytes, sizeof(char))
	cdef int copied_bytes = WideCharToMultiByte(CP_UTF8, 0, wcharstr, -1, charstr, charstr_bytes, NULL, NULL)
    if bytes == str:
		pystring = "" + charstr # Python 2.7
	else:
		pystring = (b"" + charstr).decode("utf-8", "ignore") # Python 3
    free(charstr)
	return pystring