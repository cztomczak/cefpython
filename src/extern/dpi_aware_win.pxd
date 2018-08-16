# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libcpp cimport bool as cpp_bool

cdef extern from "client_handler/dpi_aware.h":
    cdef void GetSystemDpi(int* dpix, int* dpiy)
    cdef void GetDpiAwareWindowSize(int* width, int* height)
    cdef void SetProcessDpiAware()
    cdef cpp_bool IsProcessDpiAware()
