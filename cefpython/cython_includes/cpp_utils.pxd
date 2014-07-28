# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "cpp_utils/PaintBuffer.h":

    cdef void FlipBufferUpsideDown(
            void* dest, void* src, int width, int height)

    cdef void SwapBufferFromBgraToRgba(
            void* dest, void* src, int width, int height)
