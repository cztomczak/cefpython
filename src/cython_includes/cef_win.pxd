# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

# noinspection PyUnresolvedReferences
from windows cimport HWND, RECT, HINSTANCE, HCURSOR
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/internal/cef_win.h":

    ctypedef HWND CefWindowHandle
    ctypedef HCURSOR CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(CefWindowHandle parent,
                        RECT windowRect)
        void SetAsPopup(CefWindowHandle parent,
                        const CefString& windowName)
        void SetAsWindowless(CefWindowHandle parent,
                        cpp_bool transparent)

    cdef cppclass CefMainArgs:
        CefMainArgs()
        CefMainArgs(HINSTANCE hInstance)
