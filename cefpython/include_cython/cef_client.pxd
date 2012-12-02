# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase

cdef extern from "include/cef_client.h":
	
	# When inheriting "cef_base.CefBase" cython compiler throws an error:
	# https://groups.google.com/forum/?fromgroups#!topic/cython-users/p-PMDKsvfik

	cdef cppclass CefClient(CefBase):
		
		pass
