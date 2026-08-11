# Copyright (c) 2015 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

from libcpp cimport bool as cpp_bool
from cef_types cimport CefRect

cdef extern from "include/internal/cef_mac.h":

    ctypedef void* CefWindowHandle
    ctypedef void* CefCursorHandle

    ctypedef enum cef_runtime_style_t:
        CEF_RUNTIME_STYLE_DEFAULT
        CEF_RUNTIME_STYLE_CHROME
        CEF_RUNTIME_STYLE_ALLOY

    cdef cppclass CefWindowInfo:
        cef_runtime_style_t runtime_style
        void SetAsChild(CefWindowHandle parent,
                        const CefRect& windowRect)
        void SetAsWindowless(CefWindowHandle parent)

    cdef cppclass CefMainArgs:
        CefMainArgs()
        CefMainArgs(int argc_arg, char** argv_arg)
