# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/internal/cef_types_win.h":

    ctypedef struct _cef_key_info_t:
        int key
