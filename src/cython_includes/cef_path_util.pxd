# Copyright (c) 2016 The CEF Python Authors. All rights reserved.

from cef_types cimport PathKey
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_path_util.h" nogil:
    cpp_bool CefGetPath(PathKey key, CefString& path)
    cpp_bool CefOverridePath(PathKey key, const CefString& path)
