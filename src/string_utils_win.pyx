# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef int wchar_t_size = 2

cdef void CharToWidechar(char* charString, wchar_t* wideString, int wideSize
        ) except *:
    cdef int copiedCharacters = MultiByteToWideChar(
            CP_UTF8, 0, charString, -1, wideString, wideSize)
    # MultiByteToWideChar does not include the NULL character
    # when 0 bytes are written.
    if wideSize > 0 and copiedCharacters == 0:
        wideString[0] = <wchar_t>0

cdef py_string WidecharToPyString(
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

    cdef py_string pyString = CharToPyString(charString)
    free(charString)
    return pyString
