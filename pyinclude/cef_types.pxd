# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/internal/cef_types.h":
	
	cdef enum cef_log_severity_t:
		LOGSEVERITY_VERBOSE = -1,
		LOGSEVERITY_INFO,
		LOGSEVERITY_WARNING,
		LOGSEVERITY_ERROR,
		LOGSEVERITY_ERROR_REPORT,
		LOGSEVERITY_DISABLE = 99

	cdef enum cef_thread_id_t:
		TID_UI = 0,
		TID_IO = 1,
		TID_FILE = 2,
	