# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from cef_browser cimport CefWindowHandle
from cef_types cimport CefRect, CefSize
from libcpp cimport bool as cpp_bool


cdef extern from "include/internal/cef_types.h":
    ctypedef struct cef_insets_t:
        int top;
        int left;
        int bottom;
        int right;

    ctypedef enum cef_main_axis_alignment_t:
        CEF_MAIN_AXIS_ALIGNMENT_START,
        CEF_MAIN_AXIS_ALIGNMENT_CENTER,
        CEF_MAIN_AXIS_ALIGNMENT_END,

    ctypedef enum cef_cross_axis_alignment_t:
        CEF_CROSS_AXIS_ALIGNMENT_STRETCH,
        CEF_CROSS_AXIS_ALIGNMENT_START,
        CEF_CROSS_AXIS_ALIGNMENT_CENTER,
        CEF_CROSS_AXIS_ALIGNMENT_END,

    ctypedef struct CefBoxLayoutSettings:
        int horizontal;
        int inside_border_horizontal_spacing;
        int inside_border_vertical_spacing;
        cef_insets_t inside_border_insets;
        int between_child_spacing;
        cef_main_axis_alignment_t main_axis_alignment;
        cef_cross_axis_alignment_t cross_axis_alignment;
        int minimum_cross_axis_size;
        int default_flex;

cdef extern from "include/views/cef_box_layout.h":
    cdef cppclass CefBoxLayout:
        void SetFlexForView(CefRefPtr[CefWindow] view, int flex)

cdef extern from "include/views/cef_window_delegate.h":
    cdef cppclass CefWindowDelegate:
        pass

cdef extern from "include/views/cef_view.h":
    cdef cppclass CefView:
        pass

cdef extern from "include/views/cef_panel_delegate.h":
    cdef cppclass CefPanelDelegate:
        pass

cdef extern from "include/views/cef_panel.h":
    cdef cppclass CefPanel:
        @staticmethod
        CefRefPtr[CefPanel] CreatePanel(CefRefPtr[CefPanelDelegate] delegate)


cdef extern from "include/views/cef_fill_layout.h":
    cdef cppclass CefFillLayout:
        pass

cdef extern from "include/views/cef_window.h":
    cdef cppclass CefWindow:
        @staticmethod
        CefRefPtr[CefWindow] CreateTopLevelWindow(
                CefRefPtr[CefWindowDelegate] delegate)
        void Show()
        CefWindowHandle GetWindowHandle()
        void SetBounds(const CefRect& bounds)
        void CenterWindow(const CefSize& size)
        void SetVisible(cpp_bool visible)
        void Layout()
        CefRefPtr[CefFillLayout] SetToFillLayout()
        CefRefPtr[CefBoxLayout] SetToBoxLayout(
                const CefBoxLayoutSettings& settings)
        void RequestFocus()
        void RemoveAllChildViews()
        size_t GetChildViewCount()
        void AddChildView(CefRefPtr[CefPanel] view)
        void ReorderChildView(CefRefPtr[CefPanel] view, int index)
