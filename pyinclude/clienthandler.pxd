# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_client cimport CefClient
from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame

cdef extern from "clienthandler.h":

	ctypedef void (*OnLoadEnd_Type)(CefRefPtr[CefBrowser], CefRefPtr[CefFrame], int)
	
	cdef cppclass ClientHandler(CefClient):
		
		void SetCallback_OnLoadEnd(OnLoadEnd_Type)

	
