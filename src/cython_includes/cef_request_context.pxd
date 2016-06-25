# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from cef_request_context_handler cimport CefRequestContextHandler
from cef_types cimport CefRequestContextSettings

cdef extern from "include/cef_request_context.h":
    cdef cppclass CefRequestContext:
        pass
    cdef CefRefPtr[CefRequestContext] CefRequestContext_CreateContext\
            "CefRequestContext::CreateContext"(
                    const CefRequestContextSettings& settings,
                    CefRefPtr[CefRequestContextHandler] handler)
