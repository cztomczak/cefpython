# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/internal/cef_ptr.h":
    cdef cppclass CefRefPtr[T]:
        CefRefPtr()
        # noinspection PyUnresolvedReferences
        CefRefPtr(T* p)
        # noinspection PyUnresolvedReferences
        CefRefPtr(const CefRefPtr[T]& r)
        # noinspection PyUnresolvedReferences
        CefRefPtr[T]& Assign "operator="(T* p) # cefBrowser.Assign(CefBrowser*)
        # noinspection PyUnresolvedReferences
        T* get()
        # noinspection PyUnresolvedReferences
        void swap(CefRefPtr[T]& r)
