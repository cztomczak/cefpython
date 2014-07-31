# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# TODO: cleanup the code in string_utils.pyx and string_utils_win.pyx,
#       see this topic for a review of the code in this file, see the
#       posts by Stefan Behnel:
#       https://groups.google.com/d/topic/cython-users/VICzhVn-zPw/discussion

# TODO: make this configurable through ApplicationSettings.
UNICODE_ENCODE_ERRORS = "replace"
BYTES_DECODE_ERRORS = "replace"

# Any bytes/unicode encoding and decoding in cefpython should
# be performed only using functions from this file - let's
# keep it in one place for future fixes - see Issue 60 ("Strings
# should be unicode by default, if bytes is required make it
# explicit").

cdef py_string CharToPyString(
        const char* charString):
    if PY_MAJOR_VERSION < 3:
        return <bytes>charString
    else:
        return <unicode>((<bytes>charString).decode(
                g_applicationSettings["string_encoding"],
                errors=BYTES_DECODE_ERRORS))

"""
cdef py_string CppToPyString(
        cpp_string cppString):
    if PY_MAJOR_VERSION < 3:
        return <bytes>cppString
    else:
        return <unicode>((<bytes>cppString).decode(
                g_applicationSettings["string_encoding"],
                errors=BYTES_DECODE_ERRORS))
"""

cdef py_string CefToPyString(
        ConstCefString& cefString):
    cdef cpp_string cppString
    if cefString.empty():
        return ""
    IF UNAME_SYSNAME == "Windows":
        cdef wchar_t* wcharstr = <wchar_t*> cefString.c_str()
        return WidecharToPyString(wcharstr)
    ELSE:
        cppString = cefString.ToString()
        if PY_MAJOR_VERSION < 3:
            return <bytes>cppString
        else:
            return <unicode>((<bytes>cppString).decode(
                    g_applicationSettings["string_encoding"],
                    errors=BYTES_DECODE_ERRORS))

cdef void PyToCefString(
        py_string pyString,
        CefString& cefString
        ) except *:
    if PY_MAJOR_VERSION < 3:
        if type(pyString) == unicode:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))
    else:
        # The unicode type is not defined in Python 3.
        if type(pyString) == str:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))
    cdef cpp_string cppString = pyString
    # Using cefString.FromASCII() will result in DCHECK failures
    # when a non-ascii character is encountered.
    cefString.FromString(cppString)

cdef CefString PyToCefStringValue(
        py_string pyString
        ) except *:
    cdef CefString cefString
    PyToCefString(pyString, cefString)
    return cefString

cdef void PyToCefStringPointer(
        py_string pyString,
        CefString* cefString
        ) except *:
    if PY_MAJOR_VERSION < 3:
        if type(pyString) == unicode:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))
    else:
        # The unicode type is not defined in Python 3.
        if type(pyString) == str:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))

    cdef cpp_string cppString = pyString
    # When used cefString.FromASCII(), a DCHECK failed
    # when passed a unicode string.
    cefString.FromString(cppString)

cdef py_string VoidPtrToString(const void* data, size_t dataLength):
    if PY_MAJOR_VERSION < 3:
        return <bytes>((<char*>data)[:dataLength])
    else:
        return <unicode>((<bytes>(<char*>data)[:dataLength]).decode(
                g_applicationSettings["string_encoding"],
                errors=BYTES_DECODE_ERRORS))
