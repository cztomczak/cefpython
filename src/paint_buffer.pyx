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
    cdef int width
    cdef int height
    cdef Py_ssize_t length

    def __init__(self):
        # TODO: Remove deprecated methods below from API reference
        #       and update examples during next release
        self.GetIntPointer = self.GetPointer
        self.GetString = self.GetBytes

    cpdef uintptr_t GetPointer(self) except *:
        return <uintptr_t>self.buffer

    cpdef object GetBytes(self, str mode="bgra", str origin="top-left"):
        cdef void* dest
        cdef py_bool dest_alloced = False
        cdef object ret

        origin = origin.lower()
        mode = mode.lower()
        assert origin in ("top-left", "bottom-left"), "Invalid origin"
        assert mode in ("bgra", "rgba"), "Invalid mode"

        # To get rid of a Cython warning:
        # | '__pyx_v_dest' may be used uninitialized in this function
        dest = <void*>malloc(0)

        if mode == "rgba":
            if not dest_alloced:
                dest = <void*>malloc(self.length)
                dest_alloced = True
            SwapBufferFromBgraToRgba(dest, self.buffer, self.width,
                    self.height)

        if origin == "bottom-left":
            if not dest_alloced:
                dest = <void*>malloc(self.length)
                dest_alloced = True
            FlipBufferUpsideDown(dest, self.buffer, self.width, self.height)

        if dest_alloced:
            ret = (<char*>dest)[:self.length]
            free(dest)
            return ret
        else:
            return (<char*>self.buffer)[:self.length]
