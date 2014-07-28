# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

from windows cimport HWND, RECT, HINSTANCE, HCURSOR
from cef_types_wrappers cimport CefStructBase
from cef_string cimport CefString
from cef_types_win cimport _cef_key_info_t

cdef extern from "include/internal/cef_win.h":

    ctypedef HWND CefWindowHandle
    ctypedef HCURSOR CefCursorHandle

    cdef cppclass CefWindowInfo:
        void SetAsChild(HWND, RECT)
        void SetAsPopup(HWND, CefString&)
        void SetTransparentPainting(int)
        void SetAsOffScreen(HWND)

    IF CEF_VERSION == 3:
        cdef cppclass CefMainArgs(CefStructBase):
            CefMainArgs()
            CefMainArgs(HINSTANCE hInstance)

    ctypedef _cef_key_info_t CefKeyInfo
