# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Typed Memoryviews:
# http://docs.cython.org/src/userguide/memoryviews.html

# BGRA to RGBA:
# http://stackoverflow.com/questions/13423110/how-to-convert-bgra-buffer-to-rgba-buffer-format

cdef PaintBuffer CreatePaintBuffer(void* buffer, int width, int height):
    cdef PaintBuffer paintBuffer = PaintBuffer()
    paintBuffer.buffer = buffer
    paintBuffer.width = width
    paintBuffer.height = height
    paintBuffer.length = width*height*4
    return paintBuffer

cdef class PaintBuffer:
    cdef void* buffer
    cdef int width
    cdef int height
    cdef Py_ssize_t length

    cpdef long long GetIntPointer(self) except *:
        return <long long>self.buffer

    cpdef object GetString(self, str origin="top-left", str mode="bgra"):
        cdef char* src
        cdef char* dest
        cdef object ret
        cdef int y
        cdef unsigned int tb
        cdef width = self.width
        cdef height = self.height
        cdef length = self.length

        if origin == "top-left":
            return (<char*>self.buffer)[:self.length]
        elif origin == "bottom-left":
            src = <char*>self.buffer
            dest = <char*>malloc(self.length)

            for y in range(0, height):
                tb = length - ((y+1)*width*4)
                memcpy(&dest[tb], &src[y*width*4], width*4)

            ret = dest[:self.length]
            free(dest)
            return ret
        else:
            raise Exception("PaintBuffer.GetString() failed: invalid origin")
