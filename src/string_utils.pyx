# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# In Python 2 all cefpython strings are byte strings, but in Python 3
# all cefpython strings are unicode. Unicode issues were discussed
# in Issue #60: https://github.com/cztomczak/cefpython/issues/60

# Unicode issues were discussed on cython-users, see posts by Stefan
# Behnel: https://groups.google.com/d/topic/cython-users/VICzhVn-zPw/discussion

# See the "basestring" comment in cefpython.pyx.
# Note that bytes != str != unicode != basestring in Cython

# Any bytes/unicode encoding and decoding in cefpython should
# be performed only using functions from this file - let's
# keep it in one place for future fixes - see Issue 60 ("Strings
# should be unicode by default, if bytes is required make it
# explicit").

include "cefpython.pyx"

# TODO: make this configurable through ApplicationSettings.
UNICODE_ENCODE_ERRORS = "replace"
BYTES_DECODE_ERRORS = "replace"


cdef py_string AnyToPyString(object value):
    cdef object valueType = type(value)
    if valueType == str or valueType == bytes:
        return value
    elif PY_MAJOR_VERSION < 3 and valueType == unicode:
        # The unicode type is not defined in Python 3
        return value
    else:
        return ""

cdef py_string CharToPyString(
        const char* charString):
    if PY_MAJOR_VERSION < 3:
        return <bytes>charString
    else:
        return <unicode>((<bytes>charString).decode(
                g_applicationSettings["string_encoding"],
                errors=BYTES_DECODE_ERRORS))


cdef bytes PyStringToChar(py_string pyString):
    if PY_MAJOR_VERSION < 3:
        return <bytes>pyString
    else:
        # The unicode type is not defined in Python 3.
        if type(pyString) == str:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))
        return pyString


# Not used anywhere so commented out.
# ---
# cdef py_string CppToPyString(
#         cpp_string cppString):
#     if PY_MAJOR_VERSION < 3:
#         return <bytes>cppString
#     else:
#         return <unicode>((<bytes>cppString).decode(
#                 g_applicationSettings["string_encoding"],
#                 errors=BYTES_DECODE_ERRORS))
# ---

# No need for this function as you can do it in one line.
# Stays here just for the info on how to do it.
# ---
# cdef cpp_string PyToCppString(py_string pyString) except *:
#     cdef cpp_string cppString = pyString
#     return cppString
# ---

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

cdef bytes CefToPyBytes(
        ConstCefString& cefString):
    return <bytes>cefString.ToString()

cdef void PyToCefString(
        py_string pyString,
        CefString& cefString
        ) except *:
    if PY_MAJOR_VERSION < 3:
        # Handle objects that may be converted to string e.g. QString
        if not isinstance(pyString, str) and not isinstance(pyString, unicode):
            pyString = str(pyString)
        if type(pyString) == unicode:
            pyString = <bytes>(pyString.encode(
                    g_applicationSettings["string_encoding"],
                    errors=UNICODE_ENCODE_ERRORS))
    else:
        # Handle objects that may be converted to string e.g. QString
        if not isinstance(pyString, str) and not isinstance(pyString, bytes):
            pyString = str(pyString)
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

cdef bytes VoidPtrToBytes(const void* data, size_t dataLength):
    return <bytes>((<char*>data)[:dataLength])

