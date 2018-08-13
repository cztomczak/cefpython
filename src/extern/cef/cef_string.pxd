# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libcpp cimport bool as cpp_bool
from libc.stddef cimport wchar_t
from libcpp.string cimport string as cpp_string
from wstring cimport wstring as cpp_wstring

cdef extern from "include/internal/cef_string.h":
    ctypedef struct cef_string_t:
        pass
    cdef cppclass CefString:
        CefString()
        CefString(cef_string_t*)
        void Attach(cef_string_t* str, cpp_bool owner)
        cpp_bool empty()
        cpp_bool FromASCII(char*)
        # noinspection PyUnresolvedReferences
        cpp_bool FromString(wchar_t*, size_t, cpp_bool)
        cpp_bool FromString(cpp_string& str)
        cpp_string ToString()
        cpp_wstring ToWString()
        const char* c_str()
        size_t length()
