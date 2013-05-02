# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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

cdef str CefToPyString(
        ConstCefString& cefString):
    if cefString.empty():
        return ""
    IF UNAME_SYSNAME == "Windows":
        cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
        return WidecharToPyString(wcharstr)
    ELSE:
        # The windows version above is probably more efficient.
        return cefString.ToString()

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
