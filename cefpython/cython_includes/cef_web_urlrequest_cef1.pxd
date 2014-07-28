# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase
from cef_ptr cimport CefRefPtr
cimport cef_types
from cef_request_cef1 cimport CefRequest

cdef extern from "include/cef_web_urlrequest.h":
    cdef cppclass CefWebURLRequest(CefBase):
        void Cancel()
        cef_types.cef_weburlrequest_state_t GetState()

    cdef cppclass CefWebURLRequestClient(CefBase):
        pass
