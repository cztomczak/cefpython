# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/internal/cef_types_win.h":
	
	cdef enum cef_graphics_implementation_t:
		ANGLE_IN_PROCESS = 0,
		ANGLE_IN_PROCESS_COMMAND_BUFFER,
		DESKTOP_IN_PROCESS,
		DESKTOP_IN_PROCESS_COMMAND_BUFFER,
