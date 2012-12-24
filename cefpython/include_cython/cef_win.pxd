# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from windows cimport HWND, RECT, HINSTANCE, HCURSOR
from Cython.Shadow import void
from cef_types_wrappers cimport CefStructBase
from cef_string cimport CefString

cdef extern from "include/internal/cef_win.h":

    ctypedef HWND CefWindowHandle
    ctypedef HCURSOR CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(HWND, RECT)
        void SetAsOffScreen(HWND)
        void SetAsPopup(HWND, CefString&)
        void SetTransparentPainting(int)

    IF CEF_VERSION == 3:
        cdef cppclass CefMainArgs(CefStructBase):
            CefMainArgs()
            CefMainArgs(HINSTANCE hInstance)
