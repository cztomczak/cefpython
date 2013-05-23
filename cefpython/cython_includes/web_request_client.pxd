# Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "client_handler/web_request_client.h":
    cdef cppclass WebRequestClient:
        WebRequestClient(int webRequestId)
