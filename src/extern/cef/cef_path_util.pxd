# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_types cimport PathKey
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_path_util.h" nogil:
    cpp_bool CefGetPath(PathKey key, CefString& path)
