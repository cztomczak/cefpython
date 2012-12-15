# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

IF UNAME_SYSNAME == "Windows":
    cdef int wchar_t_size = 2
ELSE:
    cdef int wchar_t_size = 4

cdef str CharToPyString(
        char* charString):
    cdef str pyString
    if bytes == str:
        # Python 2.7, bytes and str are the same types.
        # "" + charString >> makes a copy of char*
        pyString = "" + charString
    else:
        # Python 3.
        pyString = (b"" + charString).decode("utf-8", "ignore")
    return pyString

cdef str WcharToPyString(
        wchar_t* wcharString):
    cdef int charBytes = WideCharToMultiByte(
            CP_UTF8, 0, wcharString, -1, NULL, 0, NULL, NULL)

    # When CefString is an empty string, WideCharToMultiByte returns 0 bytes, it does
    # not include the NUL character, so we need to use calloc instead of malloc.

    cdef char* charString = <char*>calloc(charBytes, sizeof(char))
    cdef int copiedBytes = WideCharToMultiByte(
            CP_UTF8, 0, wcharString, -1, charString, charBytes, NULL, NULL)

    cdef str pyString = CharToPyString(charString)
    free(charString)
    return pyString

cdef str CefToPyString(
        CefString& cefString):
    cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
    return WcharToPyString(wcharstr)

cdef void PyToCefString(
        py_string pyString,
        CefString& cefString
        ) except *:
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

cdef void PyToCefStringPointer(
        py_string pyString,
        CefString* cefString
        ) except *:
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
