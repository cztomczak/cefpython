# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

# noinspection PyUnresolvedReferences
cimport cef_types

# cef_color_type_t
CEF_COLOR_TYPE_RGBA_8888 = cef_types.CEF_COLOR_TYPE_RGBA_8888
CEF_COLOR_TYPE_BGRA_8888 = cef_types.CEF_COLOR_TYPE_BGRA_8888

# cef_alpha_type_t
CEF_ALPHA_TYPE_OPAQUE = cef_types.CEF_ALPHA_TYPE_OPAQUE
CEF_ALPHA_TYPE_PREMULTIPLIED = cef_types.CEF_ALPHA_TYPE_PREMULTIPLIED
CEF_ALPHA_TYPE_POSTMULTIPLIED = cef_types.CEF_ALPHA_TYPE_POSTMULTIPLIED


cdef PyImage PyImage_Init(CefRefPtr[CefImage] cef_image):
    cdef PyImage image = PyImage()
    image.cef_image = cef_image
    return image

cdef class PyImage:
    cdef CefRefPtr[CefImage] cef_image

    cpdef bytes GetAsBitmap(self,
                            float scale_factor,
                            cef_types.cef_color_type_t color_type,
                            cef_types.cef_alpha_type_t alpha_type):
        cdef int pixel_width = 0
        cdef int pixel_height = 0
        if not self.cef_image.get():
            raise Exception("cef_image is NULL")
        cdef CefRefPtr[CefBinaryValue] binary_value =\
                self.cef_image.get().GetAsBitmap(scale_factor,
                                                 color_type, alpha_type,
                                                 pixel_width, pixel_height)
        cdef size_t size = binary_value.get().GetSize()
        cdef void* abuffer = malloc(size)
        binary_value.get().GetData(abuffer, size, 0)
        cdef bytes ret = (<char*>abuffer)[:size]
        free(abuffer)
        return ret

    cpdef bytes GetAsPng(self, float scale_factor, py_bool with_transparency):
        cdef int pixel_width = 0
        cdef int pixel_height = 0
        if not self.cef_image.get():
            raise Exception("cef_image is NULL")
        cdef CefRefPtr[CefBinaryValue] binary_value =\
                self.cef_image.get().GetAsPNG(scale_factor,
                                              bool(with_transparency),
                                              pixel_width, pixel_height)
        cdef size_t size = binary_value.get().GetSize()
        cdef void* abuffer = malloc(size)
        binary_value.get().GetData(abuffer, size, 0)
        cdef bytes ret = (<char*>abuffer)[:size]
        free(abuffer)
        return ret

    cpdef size_t GetHeight(self):
        if not self.cef_image.get():
            raise Exception("cef_image is NULL")
        return self.cef_image.get().GetHeight()

    cpdef size_t GetWidth(self):
        if not self.cef_image.get():
            raise Exception("cef_image is NULL")
        return self.cef_image.get().GetWidth()

