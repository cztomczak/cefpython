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
        # BEFORE MODIFYING CODE:
        # There is an exact copy of this method named "GetString" (deprecated).
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

    # ---- DEPRECATED ---------------------------------------------------------
    # TODO: remove deprecated methods from API reference during next release.
    # TODO: remove deprecated methods after users had time to update code.

    cpdef uintptr_t GetIntPointer(self) except *:
        """@deprecated."""
        return <uintptr_t>self.buffer

    cpdef object GetString(self, str mode="bgra", str origin="top-left"):
        """@deprecated."""
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
