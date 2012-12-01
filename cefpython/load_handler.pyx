# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

cdef public void LoadHandler_OnLoadEnd(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		int httpStatusCode
		) except * with gil:
	
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LoadHandler_OnLoadEnd() failed: pyBrowser is %s" % pyBrowser)
			return
		pyFrame = GetPyFrameByCefFrame(cefFrame)	
		handler = pyBrowser.GetClientHandler("OnLoadEnd")
		if type(handler) is tuple:
			if pyFrame.IsMain():
				handler = handler[0]
			else:
				handler = handler[1]
		if handler:
			handler(pyBrowser, pyFrame, httpStatusCode)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)


cdef public void LoadHandler_OnLoadStart(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LoadHandler_OnLoadStart(): failed: pyBrowser is %s" % pyBrowser)
			return
		pyFrame = GetPyFrameByCefFrame(cefFrame)	
		handler = pyBrowser.GetClientHandler("OnLoadStart")
		if type(handler) is tuple:
			if pyFrame.IsMain():
				handler = handler[0]
			else:
				handler = handler[1]
		if handler:
			handler(pyBrowser, pyFrame)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)


cdef public c_bool LoadHandler_OnLoadError(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		cef_types.cef_handler_errorcode_t cefErrorCode,
		CefString& cefFailedURL,
		CefString& cefErrorText
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("LoadHandler_OnLoadError() failed: pyBrowser is %s" % pyBrowser)
			return False
		pyFrame = GetPyFrameByCefFrame(cefFrame)	
		handler = pyBrowser.GetClientHandler("OnLoadError")
		if type(handler) is tuple:
			if pyFrame.IsMain():
				handler = handler[0]
			else:
				handler = handler[1]
		if handler:
			errorText = [""] # errorText[0] is out
			ret = handler(pyBrowser, pyFrame, cefErrorCode, CefStringToPyString(cefFailedURL), errorText)
			if ret:
				PyStringToCefString(errorText[0], cefErrorText)
			return bool(ret)
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

# Network error constants.

ERR_FAILED = <int>cef_types.ERR_FAILED
ERR_ABORTED = <int>cef_types.ERR_ABORTED
ERR_INVALID_ARGUMENT = <int>cef_types.ERR_INVALID_ARGUMENT
ERR_INVALID_HANDLE = <int>cef_types.ERR_INVALID_HANDLE
ERR_FILE_NOT_FOUND = <int>cef_types.ERR_FILE_NOT_FOUND
ERR_TIMED_OUT = <int>cef_types.ERR_TIMED_OUT
ERR_FILE_TOO_BIG = <int>cef_types.ERR_FILE_TOO_BIG
ERR_UNEXPECTED = <int>cef_types.ERR_UNEXPECTED
ERR_ACCESS_DENIED = <int>cef_types.ERR_ACCESS_DENIED
ERR_NOT_IMPLEMENTED = <int>cef_types.ERR_NOT_IMPLEMENTED
ERR_CONNECTION_CLOSED = <int>cef_types.ERR_CONNECTION_CLOSED
ERR_CONNECTION_RESET = <int>cef_types.ERR_CONNECTION_RESET
ERR_CONNECTION_REFUSED = <int>cef_types.ERR_CONNECTION_REFUSED
ERR_CONNECTION_ABORTED = <int>cef_types.ERR_CONNECTION_ABORTED
ERR_CONNECTION_FAILED = <int>cef_types.ERR_CONNECTION_FAILED
ERR_NAME_NOT_RESOLVED = <int>cef_types.ERR_NAME_NOT_RESOLVED
ERR_INTERNET_DISCONNECTED = <int>cef_types.ERR_INTERNET_DISCONNECTED
ERR_SSL_PROTOCOL_ERROR = <int>cef_types.ERR_SSL_PROTOCOL_ERROR
ERR_ADDRESS_INVALID = <int>cef_types.ERR_ADDRESS_INVALID
ERR_ADDRESS_UNREACHABLE = <int>cef_types.ERR_ADDRESS_UNREACHABLE
ERR_SSL_CLIENT_AUTH_CERT_NEEDED = <int>cef_types.ERR_SSL_CLIENT_AUTH_CERT_NEEDED
ERR_TUNNEL_CONNECTION_FAILED = <int>cef_types.ERR_TUNNEL_CONNECTION_FAILED
ERR_NO_SSL_VERSIONS_ENABLED = <int>cef_types.ERR_NO_SSL_VERSIONS_ENABLED
ERR_SSL_VERSION_OR_CIPHER_MISMATCH = <int>cef_types.ERR_SSL_VERSION_OR_CIPHER_MISMATCH
ERR_SSL_RENEGOTIATION_REQUESTED = <int>cef_types.ERR_SSL_RENEGOTIATION_REQUESTED
ERR_CERT_COMMON_NAME_INVALID = <int>cef_types.ERR_CERT_COMMON_NAME_INVALID
ERR_CERT_DATE_INVALID = <int>cef_types.ERR_CERT_DATE_INVALID
ERR_CERT_AUTHORITY_INVALID = <int>cef_types.ERR_CERT_AUTHORITY_INVALID
ERR_CERT_CONTAINS_ERRORS = <int>cef_types.ERR_CERT_CONTAINS_ERRORS
ERR_CERT_NO_REVOCATION_MECHANISM = <int>cef_types.ERR_CERT_NO_REVOCATION_MECHANISM
ERR_CERT_UNABLE_TO_CHECK_REVOCATION = <int>cef_types.ERR_CERT_UNABLE_TO_CHECK_REVOCATION
ERR_CERT_REVOKED = <int>cef_types.ERR_CERT_REVOKED
ERR_CERT_INVALID = <int>cef_types.ERR_CERT_INVALID
ERR_CERT_END = <int>cef_types.ERR_CERT_END
ERR_INVALID_URL = <int>cef_types.ERR_INVALID_URL
ERR_DISALLOWED_URL_SCHEME = <int>cef_types.ERR_DISALLOWED_URL_SCHEME
ERR_UNKNOWN_URL_SCHEME = <int>cef_types.ERR_UNKNOWN_URL_SCHEME
ERR_TOO_MANY_REDIRECTS = <int>cef_types.ERR_TOO_MANY_REDIRECTS
ERR_UNSAFE_REDIRECT = <int>cef_types.ERR_UNSAFE_REDIRECT
ERR_UNSAFE_PORT = <int>cef_types.ERR_UNSAFE_PORT
ERR_INVALID_RESPONSE = <int>cef_types.ERR_INVALID_RESPONSE
ERR_INVALID_CHUNKED_ENCODING = <int>cef_types.ERR_INVALID_CHUNKED_ENCODING
ERR_METHOD_NOT_SUPPORTED = <int>cef_types.ERR_METHOD_NOT_SUPPORTED
ERR_UNEXPECTED_PROXY_AUTH = <int>cef_types.ERR_UNEXPECTED_PROXY_AUTH
ERR_EMPTY_RESPONSE = <int>cef_types.ERR_EMPTY_RESPONSE
ERR_RESPONSE_HEADERS_TOO_BIG = <int>cef_types.ERR_RESPONSE_HEADERS_TOO_BIG
ERR_CACHE_MISS = <int>cef_types.ERR_CACHE_MISS
ERR_INSECURE_RESPONSE = <int>cef_types.ERR_INSECURE_RESPONSE
