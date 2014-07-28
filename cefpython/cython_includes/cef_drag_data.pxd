# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cpp_bool
from cef_string cimport CefString
from libcpp.vector cimport vector as cpp_vector

cdef extern from "include/cef_drag_data.h":
    cdef cppclass CefDragData:
        cpp_bool IsLink()
        cpp_bool IsFragment()
        cpp_bool IsFile()
        CefString GetLinkURL()
        CefString GetLinkTitle()
        CefString GetLinkMetadata()
        CefString GetFragmentText()
        CefString GetFragmentHtml()
        CefString GetFragmentBaseURL()
        CefString GetFileName()
        cpp_bool GetFileNames(cpp_vector[CefString]& names)
