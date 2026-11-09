# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "cpp_utils/PaintBuffer.h":

    cdef void CopyPaintBuffer(
            void* dest, const void* src, int width, int height,
            bint rgba, bint flip)
