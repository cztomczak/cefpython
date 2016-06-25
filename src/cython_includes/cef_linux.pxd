# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
from cef_types cimport CefRect

cdef extern from "include/internal/cef_linux.h":

    ctypedef unsigned long CefWindowHandle
    ctypedef unsigned long CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(CefWindowHandle parent,
                        const CefRect& windowRect)
        void SetAsWindowless(CefWindowHandle parent,
                             cpp_bool transparent)

    cdef cppclass CefMainArgs:
        CefMainArgs()
        CefMainArgs(int argc_arg, char** argv_arg)
