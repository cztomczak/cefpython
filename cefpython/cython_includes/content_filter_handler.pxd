# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "client_handler/content_filter_handler.h":
    cdef cppclass ContentFilterHandler:
        ContentFilterHandler(int contentFilterId)
