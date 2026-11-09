# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef PaintBuffer CreatePaintBuffer(const void* buffer_, int width, int height):
    cdef PaintBuffer paintBuffer = PaintBuffer()
    paintBuffer.buffer = buffer_
    paintBuffer.width = width
    paintBuffer.height = height
    paintBuffer.length = width*height*4
    return paintBuffer

cdef class PaintBuffer:
    cdef const void* buffer
    cdef public int width
    cdef public int height
    cdef public Py_ssize_t length

    cpdef uintptr_t GetPointer(self) except *:
        # BEFORE MODIFYING CODE:
        # There is an exact copy of this method named "GetIntPointer"
        # (deprecated).
        return <uintptr_t>self.buffer

    cpdef object GetBytes(self, str mode="bgra", str origin="top-left"):
        cdef int width = self.width
        cdef int height = self.height
        cdef object ret

        origin = origin.lower()
        mode = mode.lower()
        assert origin in ("top-left", "bottom-left"), "Invalid origin"
        assert mode in ("bgra", "rgba"), "Invalid mode"

        if width <= 0 or height <= 0:
            return b""
        if width > PY_SSIZE_T_MAX // 4 // height:
            raise OverflowError("Paint buffer is too large")
        ret = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>width * height * 4)
        CopyPaintBuffer(PyBytes_AS_STRING(ret), self.buffer, width, height,
                        mode == "rgba", origin == "bottom-left")
        return ret

    # ---- DEPRECATED ---------------------------------------------------------
    # TODO: remove deprecated methods from API reference during next release.
    # TODO: remove deprecated methods after users had time to update code.

    cpdef uintptr_t GetIntPointer(self) except *:
        """@deprecated."""
        return <uintptr_t>self.buffer
