# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from windows cimport HWND
from libcpp.string cimport string

cdef extern from "http_authentication/AuthCredentials.h":

	ctypedef struct AuthCredentialsData:
		string username
		string password

cdef extern from "http_authentication/AuthDialog.h":
	
	cdef AuthCredentialsData* AuthDialog(HWND parent) nogil
