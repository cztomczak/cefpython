# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

cimport cef_type_wrappers
cimport cef_ptr

cdef extern from "include/cef_app.h":
	
	cdef cppclass CefApp:
		pass

	cdef int CefInitialize(cef_type_wrappers.CefSettings, cef_ptr.CefRefPtr[CefApp])
	cdef void CefRunMessageLoop() nogil
	cdef void CefDoMessageLoopWork() nogil
	cdef void CefQuitMessageLoop()
	cdef void CefShutdown()
	
	