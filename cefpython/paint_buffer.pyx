# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef PaintBuffer CreatePaintBuffer(const void* buffer, int width, int height):
    cdef PaintBuffer paintBuffer = PaintBuffer()
    paintBuffer.buffer = buffer
    paintBuffer.width = width
    paintBuffer.height = height
    paintBuffer.length = width*height*4
    return paintBuffer

cdef class PaintBuffer:
    cdef const void* buffer
    cdef int width
    cdef int height
    cdef Py_ssize_t length

    cpdef long long GetIntPointer(self) except *:
        return <long long>self.buffer

    cpdef object GetString(self, str mode="bgra", str origin="top-left"):
        cdef void* dest
        cdef py_bool dest_alloced = False
        cdef object ret

        origin = origin.lower()
        mode = mode.lower()
        assert origin in ("top-left", "bottom-left"), "Invalid origin"
        assert mode in ("bgra", "rgba"), "Invalid mode"

        # To get rid of a Cython warning:
        # | ‘__pyx_v_dest’ may be used uninitialized in this function
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
