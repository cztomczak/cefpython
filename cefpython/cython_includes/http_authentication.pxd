# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from windows cimport HWND
from libcpp.string cimport string as c_string

cdef extern from "http_authentication/AuthCredentials.h":

    ctypedef struct AuthCredentialsData:
        c_string username
        c_string password

cdef extern from "http_authentication/AuthDialog.h":

    cdef AuthCredentialsData* AuthDialog(HWND parent) nogil
