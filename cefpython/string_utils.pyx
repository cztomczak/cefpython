# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

IF UNAME_SYSNAME == "Windows":
    cdef int wchar_t_size = 2
ELSE:
    cdef int wchar_t_size = 4

cdef void CharToWidechar(char* charString, wchar_t* wideString, int wideSize):
    cdef int copiedCharacters = MultiByteToWideChar(
            CP_UTF8, 0, charString, -1, wideString, wideSize)
    # MultiByteToWideChar does not include the NULL character
    # when 0 bytes are written.
    if wideSize > 0 and copiedCharacters == 0:
        wideString[0] = <wchar_t>0;

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

cdef str WidecharToPyString(
        wchar_t* wcharString):
    cdef int charBytes = WideCharToMultiByte(
            CP_UTF8, 0, wcharString, -1, NULL, 0, NULL, NULL)
    assert charBytes > 0, "WideCharToMultiByte() returned 0"

    cdef char* charString = <char*>malloc(charBytes * sizeof(char))
    cdef int copiedBytes = WideCharToMultiByte(
            CP_UTF8, 0, wcharString, -1, charString, charBytes, NULL, NULL)

    # WideCharToMultiByte does not include the NULL character
    # when 0 bytes are written.
    if copiedBytes == 0:
        charString[0] = <char>0;

    cdef str pyString = CharToPyString(charString)
    free(charString)
    return pyString

cdef str CefToPyString(
        CefString& cefString):
    if cefString.empty():
        return ""
    cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
    return WidecharToPyString(wcharstr)
    # Or this way:
    # return cefString.ToString()

cdef void PyToCefString(
        py_string pyString,
        CefString& cefString
        ) except *:
    if bytes == str:
        # Python 2.7, bytes and str are the same types.
        if type(pyString) == unicode:
            pyString = pyString.encode(
                    g_applicationSettings["unicode_to_bytes_encoding"])
    else:
        # Python 3 requires bytes before converting to char*.
        if type(pyString) != bytes:
            pyString = pyString.encode("utf-8")

    cdef std_string stdString = pyString
    # When used cefString.FromASCII(), a DCHECK failed
    # when passed a unicode string.
    cefString.FromString(stdString)

cdef void PyToCefStringPointer(
        py_string pyString,
        CefString* cefString
        ) except *:
    if bytes == str:
        # Python 2.7, bytes and str are the same types.
        if type(pyString) == unicode:
            pyString = pyString.encode(
                    g_applicationSettings["unicode_to_bytes_encoding"])
        cefString.FromASCII(<char*>pyString)
    else:
        # Python 3 requires bytes before converting to char*.
        if type(pyString) != bytes:
            pyString = pyString.encode("utf-8")

    cdef std_string stdString = pyString
    # When used cefString.FromASCII(), a DCHECK failed
    # when passed a unicode string.
    cefString.FromString(stdString)
