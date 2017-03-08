# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_jsdialog_handler.h":
    cdef cppclass CefJSDialogCallback:
        void Continue(cpp_bool success,
                      const CefString& user_input)

