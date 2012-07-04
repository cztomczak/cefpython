# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cimport cef_life_span_handler
cimport cef_ptr
from cef_client cimport CefClient

cdef class ClientHandler(CefClient):

	cdef cef_ptr.CefRefPtr[cef_life_span_handler.CefLifeSpanHandler] GetLifeSpanHandler():

		return NULL