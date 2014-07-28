# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from libc.limits cimport UINT_MAX

cdef extern from "include/internal/cef_types.h":
    cdef enum cef_drag_operations_mask_t:
        DRAG_OPERATION_NONE    = 0,
        DRAG_OPERATION_COPY    = 1,
        DRAG_OPERATION_LINK    = 2,
        DRAG_OPERATION_GENERIC = 4,
        DRAG_OPERATION_PRIVATE = 8,
        DRAG_OPERATION_MOVE    = 16,
        DRAG_OPERATION_DELETE  = 32,
        DRAG_OPERATION_EVERY   = UINT_MAX
