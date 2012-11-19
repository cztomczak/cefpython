# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_client cimport CefClient

cdef extern from "clienthandler/clienthandler.h":

	cdef cppclass ClientHandler(CefClient):
		pass
		
