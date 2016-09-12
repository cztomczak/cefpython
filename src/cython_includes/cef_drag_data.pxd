# Copyright (c) 2016 The CEF Python authors. All rights reserved.

from libcpp cimport bool as cpp_bool
from cef_string cimport CefString
from cef_ptr cimport CefRefPtr

cdef extern from "include/cef_drag_data.h":
    cdef cppclass CefDragData:
        cpp_bool IsLink()
        cpp_bool IsFragment()
        CefString GetLinkURL()
        CefString GetLinkTitle()
        CefString GetFragmentText()
        CefString GetFragmentHtml()
        void SetFragmentText(const CefString& text)
        void SetFragmentHtml(const CefString& html)
        void SetFragmentBaseURL(const CefString& base_url)

    cdef CefRefPtr[CefDragData] CefDragData_Create "CefDragData::Create"()
