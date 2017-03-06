# Copyright (c) 2016 CEF Python. See the Authors and License files.

cdef extern from "include/base/cef_scoped_ptr.h":
    cdef cppclass scoped_ptr[T]:
        scoped_ptr()
        # noinspection PyUnresolvedReferences
        scoped_ptr(T* p)
        # noinspection PyUnresolvedReferences
        void reset()
        # noinspection PyUnresolvedReferences
        T* get()
        # noinspection PyUnresolvedReferences
        scoped_ptr[T]& Assign "operator="(scoped_ptr[T]& p)
