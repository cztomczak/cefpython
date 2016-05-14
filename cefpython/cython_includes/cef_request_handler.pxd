# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_auth_callback.h":
    cdef cppclass CefAuthCallback:
        void Continue(const CefString& username,
                      const CefString& password)
        void Cancel()

cdef extern from "include/cef_request_handler.h":
    cdef cppclass CefQuotaCallback:
        void Continue(cpp_bool allow)
        void Cancel()

    cdef cppclass CefAllowCertificateErrorCallback:
        void Continue(cpp_bool allow)
