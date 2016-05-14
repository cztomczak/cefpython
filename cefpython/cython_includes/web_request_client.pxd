# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase

cdef extern from "client_handler/web_request_client.h":
    cdef cppclass WebRequestClient(CefBase):
        WebRequestClient(int webRequestId)
