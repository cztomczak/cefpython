# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from libcpp cimport bool as cpp_bool
from cef_values cimport CefBinaryValue
from cef_types cimport cef_color_type_t, cef_alpha_type_t

cdef extern from "include/cef_image.h":

    cdef cppclass CefImage:
        size_t GetWidth()
        size_t GetHeight()
        CefRefPtr[CefBinaryValue] GetAsBitmap(float scale_factor,
                                              cef_color_type_t color_type,
                                              cef_alpha_type_t alpha_type,
                                              int& pixel_width,
                                              int& pixel_height)
        CefRefPtr[CefBinaryValue] GetAsPNG(float scale_factor,
                                           cpp_bool with_transparency,
                                           int& pixel_width,
                                           int& pixel_height)
