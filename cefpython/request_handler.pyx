# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

NAVTYPE_LINKCLICKED = <int>cef_types.NAVTYPE_LINKCLICKED
NAVTYPE_FORMSUBMITTED = <int>cef_types.NAVTYPE_FORMSUBMITTED
NAVTYPE_BACKFORWARD = <int>cef_types.NAVTYPE_BACKFORWARD
NAVTYPE_RELOAD = <int>cef_types.NAVTYPE_RELOAD
NAVTYPE_FORMRESUBMITTED = <int>cef_types.NAVTYPE_FORMRESUBMITTED
NAVTYPE_OTHER = <int>cef_types.NAVTYPE_OTHER
NAVTYPE_LINKDROPPED = <int>cef_types.NAVTYPE_LINKDROPPED

cdef public c_bool RequestHandler_OnBeforeBrowse(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefRequest] cefRequest,
		cef_types.cef_handler_navtype_t navType,
		c_bool isRedirect
		) except * with gil:
	
	# TODO: not yet implemented.
	return False

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_OnBeforeBrowse() failed: pyBrowser is %s" % pyBrowser)
			return False
		
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		pyRequest = GetPyRequestByCefRequest(cefRequest)

		handler = pyBrowser.GetClientHandler("OnBeforeBrowse")
		if handler:
			return bool(handler(pyBrowser, pyFrame, pyRequest, <int>navType, isRedirect))
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnBeforeResourceLoad(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefRequest] cefRequest,
		CefString& cefRedirectURL,
		CefRefPtr[CefStreamReader]& cefResourceStream,
		CefRefPtr[CefResponse] cefResponse,
		int loadFlags
		) except * with gil:

	# TODO: not yet implemented.
	return False

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_OnBeforeResourceLoad() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyRequest = GetPyRequestByCefRequest(cefRequest)
		pyRedirectURL = [""]
		pyResourceStream = GetPyStreamReaderByCefStreamReader(cefResourceStream)
		pyResponse = None

		handler = pyBrowser.GetClientHandler("OnBeforeResourceLoad")
		if handler:
			ret = handler(pyBrowser, pyRequest, pyRedirectURL, pyResourceStream, pyResponse)
			assert type(pyRedirectURL) == list
			assert type(pyRedirectURL[0]) == str
			if pyRedirectURL[0]:
				PyStringToCefString(pyRedirectURL[0], cefRedirectURL)
			return bool(ret)
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceRedirect(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefOldURL,
		CefString& cefNewURL
		) except * with gil:

	# TODO: needs testing.
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_OnResourceRedirect() failed: pyBrowser is %s" % pyBrowser)
			return

		pyOldURL = CefStringToPyString(cefOldURL)
		pyNewURL = [CefStringToPyString(cefNewURL)] # [""] pass by reference.

		handler = pyBrowser.GetClientHandler("OnResourceRedirect")
		if handler:
			handler(pyBrowser, pyOldURL, pyNewURL)
			# We should call it only when pyNewURL[0] changed.
			if pyNewURL[0]:
				PyStringToCefString(pyNewURL[0], cefNewURL)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceResponse(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		CefRefPtr[CefResponse] cefResponse,
		CefRefPtr[CefContentFilter]& cefFilter
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_OnResourceResponse() failed: pyBrowser is %s" % pyBrowser)
			return

		pyURL = CefStringToPyString(cefURL)
		pyResponse = CreatePyResponse(cefResponse)
		pyFilter = None

		handler = pyBrowser.GetClientHandler("OnResourceResponse")
		if handler:
			handler(pyBrowser, pyURL, pyResponse, pyFilter)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnProtocolExecution(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		c_bool& cefAllowOSExecution
		) except * with gil:

	# TODO: needs testing.
	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_OnProtocolExecution() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyURL = CefStringToPyString(cefURL)
		pyAllowOSExecution = [bool(cefAllowOSExecution)] # [True] pass by reference.

		handler = pyBrowser.GetClientHandler("OnProtocolExecution")
		if handler:
			ret = handler(pyBrowser, pyURL, pyAllowOSExecution)
			cefAllowOSExecution = bool(pyAllowOSExecution[0])
			return bool(ret)
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_GetDownloadHandler(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefMimeType,
		CefString& cefFilename,
		cef_types.int64 cefContentLength,
		CefRefPtr[CefDownloadHandler]& cefDownloadHandler
		) except * with gil:

	# TODO: not yet implemented.
	return False

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_GetDownloadHandler() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyMimeType = CefStringToPyString(cefMimeType)
		pyFilename = CefStringToPyString(cefFilename)
		pyContentLength = int(cefContentLength)
		pyDownloadHandler = None

		handler = pyBrowser.GetClientHandler("GetDownloadHandler")
		if handler:
			return bool(handler(pyBrowser, pyMimeType, pyFilename, pyContentLength, pyDownloadHandler))
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_GetAuthCredentials(
		CefRefPtr[CefBrowser] cefBrowser,
		c_bool cefIsProxy,
		CefString& cefHost,
		int cefPort,
		CefString& cefRealm,
		CefString& cefScheme,
		CefString& cefUsername,
		CefString& cefPassword
		) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_GetAuthCredentials() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyIsProxy = bool(cefIsProxy)
		pyHost = CefStringToPyString(cefHost)
		pyPort = int(cefPort)
		pyRealm = CefStringToPyString(cefRealm)
		pyScheme = CefStringToPyString(cefScheme)
		pyUsername = [""]
		pyPassword = [""]

		handler = pyBrowser.GetClientHandler("GetAuthCredentials")
		if handler:
			ret = handler(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
			if ret:
				PyStringToCefString(pyUsername[0], cefUsername)
				PyStringToCefString(pyPassword[0], cefPassword)
			return bool(ret)
		else:
			# Default implementation.
			IF UNAME_SYSNAME == "Windows":
				ret = HttpAuthenticationDialog(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
				if ret:
					PyStringToCefString(pyUsername[0], cefUsername)
					PyStringToCefString(pyPassword[0], cefPassword)
				return bool(ret)
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)



cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& mainURL) except * with gil:

	# TODO: not yet implemented.
	return <CefRefPtr[CefCookieManager]>NULL

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			Debug("RequestHandler_GetCookieManager() failed: pyBrowser is %s" % pyBrowser)
			return <CefRefPtr[CefCookieManager]>NULL

		pyMainURL = CefStringToPyString(mainURL)

		handler = pyBrowser.GetClientHandler("GetCookieManager")
		if handler:
			ret = handler(pyBrowser, pyMainURL)
			if ret:
				pass
			return <CefRefPtr[CefCookieManager]>NULL
		else:
			return <CefRefPtr[CefCookieManager]>NULL
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

