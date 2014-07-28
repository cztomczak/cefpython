# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_types_mac cimport _cef_key_info_t

cdef extern from "include/internal/cef_mac.h":

    ctypedef _cef_key_info_t CefKeyInfo