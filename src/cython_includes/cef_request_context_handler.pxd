# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase

cdef extern from "include/cef_request_context_handler.h":
    cdef cppclass CefRequestContextHandler(CefBase):
        pass
