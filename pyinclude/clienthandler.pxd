# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_client cimport CefClient
from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
cimport cef_types
from libcpp cimport bool as cbool
from cef_string cimport CefString

cdef extern from "clienthandler.h":

	# Types for casting callbacks.

	# CefLoadHandler types.

	ctypedef void (*OnLoadEnd_type)(CefRefPtr[CefBrowser] browser,
			 CefRefPtr[CefFrame] frame,
			 int httpStatusCode)

	ctypedef void (*OnLoadStart_type)(CefRefPtr[CefBrowser] browser,
			CefRefPtr[CefFrame] frame)
	
	ctypedef cbool (*OnLoadError_type)(CefRefPtr[CefBrowser] browser,
			CefRefPtr[CefFrame] frame,
			cef_types.cef_handler_errorcode_t errorCode,
			CefString& failedUrl,
			CefString& errorText)
	
	# ClientHandler class.
	
	cdef cppclass ClientHandler(CefClient):
		
		# CefLoadHandler callbacks.

		void SetCallback_OnLoadEnd(OnLoadEnd_type)
		void SetCallback_OnLoadStart(OnLoadStart_type)
		void SetCallback_OnLoadError(OnLoadError_type)

	
