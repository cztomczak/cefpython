# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

cimport cef_type_wrappers
from cef_ptr cimport CefRefPtr
from cef_win cimport CefMainArgs

cdef extern from "include/cef_app.h":
	
	cdef cppclass CefApp:
		pass

	cdef int CefInitialize(cef_type_wrappers.CefSettings, CefRefPtr[CefApp])
	cdef void CefRunMessageLoop() nogil
	cdef void CefDoMessageLoopWork() nogil
	cdef void CefQuitMessageLoop()
	cdef void CefShutdown()

    CefExecuteProcess(CefMainArgs& args, CefRefPtr[CefApp] application)	
	