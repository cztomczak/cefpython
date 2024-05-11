# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_auth_callback.h":
    cdef cppclass CefAuthCallback:
        void Continue(const CefString& username,
                      const CefString& password)
        void Cancel()

