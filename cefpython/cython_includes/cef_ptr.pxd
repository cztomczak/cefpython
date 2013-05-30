# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from Cython.Shadow import void

cdef extern from "include/internal/cef_ptr.h":
    cdef cppclass CefRefPtr[T]:
        T* get()
        void swap(CefRefPtr[T]& r)
