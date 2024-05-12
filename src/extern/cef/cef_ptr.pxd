# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython
from libcpp cimport nullptr_t, bool

cdef extern from "include/internal/cef_ptr.h":
    cdef cppclass CefRefPtr[T]:
        CefRefPtr()
        # noinspection PyUnresolvedReferences
        CefRefPtr(T* p)
        # noinspection PyUnresolvedReferences
        CefRefPtr(const CefRefPtr[T]& r)
        # noinspection PyUnresolvedReferences
        T* get()
        # noinspection PyUnresolvedReferences
        void swap(CefRefPtr[T]& r)
        # noinspection PyUnresolvedReferences
        CefRefPtr[T]& Assign "operator="(nullptr_t)
        CefRefPtr[T]& Assign "operator="(T* p)
        bool operator bool()
        bool operator!()
