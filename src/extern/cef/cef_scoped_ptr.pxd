# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "include/base/cef_scoped_ptr.h":
    cdef cppclass scoped_ptr[T]:
        scoped_ptr()
        # noinspection PyUnresolvedReferences
        scoped_ptr(T* p)
        # noinspection PyUnresolvedReferences
        void reset()
        # noinspection PyUnresolvedReferences
        void reset(T* p)
        # noinspection PyUnresolvedReferences
        T* get()
        # noinspection PyUnresolvedReferences
        scoped_ptr[T]& Assign "operator="(scoped_ptr[T] p)
