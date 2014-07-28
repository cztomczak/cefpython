# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from windows cimport BOOL

cdef extern from "include/internal/cef_types_win.h":

    cdef enum cef_graphics_implementation_t:
        ANGLE_IN_PROCESS = 0,
        ANGLE_IN_PROCESS_COMMAND_BUFFER,
        DESKTOP_IN_PROCESS,
        DESKTOP_IN_PROCESS_COMMAND_BUFFER,

    ctypedef struct _cef_key_info_t:
        int key
        BOOL sysChar
        BOOL imeChar
