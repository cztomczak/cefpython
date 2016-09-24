# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_jsdialog_handler.h":
    cdef cppclass CefJSDialogCallback:
        void Continue(cpp_bool success,
                      const CefString& user_input)

