# Copyright (c) 2015 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool

cdef extern from "include/internal/cef_mac.h":

    ctypedef void* CefWindowHandle
    ctypedef void* CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(CefWindowHandle parent,
                        int x, int y, int width, int height)
        void SetAsWindowless(CefWindowHandle parent)

    cdef cppclass CefMainArgs:
        CefMainArgs()
        CefMainArgs(int argc_arg, char** argv_arg)
