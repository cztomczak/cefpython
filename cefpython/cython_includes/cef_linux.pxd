# Copyright (c) 2012-2013 CEF Python Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from cef_types_linux cimport _cef_key_info_t
from Cython.Shadow import void

cdef extern from "include/internal/cef_linux.h":

    ctypedef _cef_key_info_t CefKeyInfo
    ctypedef void* CefWindowHandle    
    ctypedef void* CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(CefWindowHandle)
