# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libcpp cimport bool as cpp_bool

cdef extern from "client_handler/dpi_aware.h":
    cdef void SetProcessDpiAware()
    cdef void GetSystemDpi(int* dpix, int* dpiy)
    cdef void GetDpiAwareWindowSize(int* width, int* height)

