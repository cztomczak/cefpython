# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_types_linux cimport _cef_key_info_t

cdef extern from "include/internal/cef_linux.h":

    ctypedef _cef_key_info_t CefKeyInfo