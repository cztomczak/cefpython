# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_stream cimport CefStreamReader
from cef_string cimport CefString

cdef extern from "include/cef_stream.h" namespace "CefStreamReader":
    cdef CefRefPtr[CefStreamReader] CreateForFile(const CefString& fileName)
    cdef CefRefPtr[CefStreamReader] CreateForData(void* data, size_t size)