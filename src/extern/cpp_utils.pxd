# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "cpp_utils/PaintBuffer.h":

    cdef void FlipBufferUpsideDown(
            void* dest, void* src, int width, int height)

    cdef void SwapBufferFromBgraToRgba(
            void* dest, void* src, int width, int height)
