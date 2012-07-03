# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/internal/cef_ptr.h":
	cdef cppclass CefRefPtr[T]:
		T* get()