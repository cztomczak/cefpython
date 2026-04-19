# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

# noinspection PyUnresolvedReferences
from windows cimport HWND, HINSTANCE, HCURSOR
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_types cimport CefRect

cdef extern from "include/internal/cef_win.h":

    # noinspection PyUnresolvedReferences
    ctypedef HWND CefWindowHandle
    # noinspection PyUnresolvedReferences
    ctypedef HCURSOR CefCursorHandle

    ctypedef enum cef_runtime_style_t:
        CEF_RUNTIME_STYLE_DEFAULT
        CEF_RUNTIME_STYLE_CHROME
        CEF_RUNTIME_STYLE_ALLOY

    cdef cppclass CefWindowInfo:
        cef_runtime_style_t runtime_style
        void SetAsChild(CefWindowHandle parent,
                        const CefRect windowRect)
        void SetAsPopup(CefWindowHandle parent,
                        const CefString& windowName)
        void SetAsWindowless(CefWindowHandle parent)

    cdef cppclass CefMainArgs:
        CefMainArgs()
        CefMainArgs(HINSTANCE hInstance)
