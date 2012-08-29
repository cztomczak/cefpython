# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_client cimport CefClient
from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
cimport cef_types
from cef_string cimport CefString
from libcpp cimport bool as cbool
from cef_v8 cimport CefV8Context
from cef_request cimport CefRequest
from cef_response cimport CefResponse
from cef_content_filter cimport CefContentFilter
from cef_cookie cimport CefCookieManager
from cef_stream cimport CefStreamReader
from cef_download_handler cimport CefDownloadHandler

cdef extern from "clienthandler/clienthandler.h":

	# Types for casting callbacks.

	# CefLoadHandler types.

	ctypedef void (*OnLoadEnd_type)(
			CefRefPtr[CefBrowser] browser,
			CefRefPtr[CefFrame] frame,
			int httpStatusCode
	)

	ctypedef void (*OnLoadStart_type)(
			CefRefPtr[CefBrowser] browser,
			CefRefPtr[CefFrame] frame
	)
	
	ctypedef cbool (*OnLoadError_type)(
			CefRefPtr[CefBrowser] browser,
			CefRefPtr[CefFrame] frame,
			cef_types.cef_handler_errorcode_t errorCode,
			CefString& failedUrl,
			CefString& errorText
	)

	# CefKeyboardHandler types.

	ctypedef cbool (*OnKeyEvent_type)(
			CefRefPtr[CefBrowser] browser,
			cef_types.cef_handler_keyevent_type_t eventType,
			int keyCode,
			int modifiers,
			cbool isSystemKey,
			cbool isAfterJavascript
	)

	# CefV8ContextHandler types.

	ctypedef void (*OnContextCreated_type)(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefV8Context] v8Context
	)

	# ClientHandler class.
	
	cdef cppclass ClientHandler(CefClient):
		
		# CefLoadHandler callbacks.
		void SetCallback_OnLoadEnd(OnLoadEnd_type)
		void SetCallback_OnLoadStart(OnLoadStart_type)
		void SetCallback_OnLoadError(OnLoadError_type)

		# CefKeyboardHandler callbacks.
		void SetCallback_OnKeyEvent(OnKeyEvent_type)

		# CefV8ContextHandler callbacks.
		void SetCallback_OnContextCreated(OnContextCreated_type)

