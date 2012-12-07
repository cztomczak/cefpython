# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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

	cdef PyBrowser pyBrowser
	cdef PyFrame pyFrame
	# cdef PyRequest pyRequest
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_OnBeforeBrowse() failed: pyBrowser is %s" % pyBrowser)
			return False
		
		pyFrame = GetPyFrame(cefFrame)
		pyRequest = None

		callback = pyBrowser.GetClientCallback("OnBeforeBrowse")
		if callback:
			return bool(callback(pyBrowser, pyFrame, pyRequest, <int>navType, isRedirect))
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnBeforeResourceLoad(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefRequest] cefRequest,
		CefString& cefRedirectUrl,
		CefRefPtr[CefStreamReader]& cefResourceStream,
		CefRefPtr[CefResponse] cefResponse,
		int loadFlags
		) except * with gil:

	# TODO: not yet implemented.
	return False

	cdef PyBrowser pyBrowser
	# cdef PyRequest pyRequest
	# cdef PyResourceStream pyResourceStream
	# cdef PyResponse pyResponse
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_OnBeforeResourceLoad() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyRequest = None
		pyRedirectUrl = [""]
		pyResourceStream = None
		pyResponse = None

		callback = pyBrowser.GetClientCallback("OnBeforeResourceLoad")
		if callback:
			ret = callback(pyBrowser, pyRequest, pyRedirectUrl, pyResourceStream, pyResponse)
			assert type(pyRedirectUrl) == list
			assert type(pyRedirectUrl[0]) == str
			if pyRedirectUrl[0]:
				ToCefString(pyRedirectUrl[0], cefRedirectUrl)
			return bool(ret)
		else:
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceRedirect(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefOldUrl,
		CefString& cefNewUrl
		) except * with gil:

	# TODO: needs testing.

	cdef PyBrowser pyBrowser
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_OnResourceRedirect() failed: pyBrowser is %s" % pyBrowser)
			return

		pyOldUrl = ToPyString(cefOldUrl)
		pyNewUrl = [ToPyString(cefNewUrl)] # [""] pass by reference.

		callback = pyBrowser.GetClientCallback("OnResourceRedirect")
		if callback:
			callback(pyBrowser, pyOldUrl, pyNewUrl)
			if pyNewUrl[0]:
				ToCefString(pyNewUrl[0], cefNewUrl)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceResponse(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefUrl,
		CefRefPtr[CefResponse] cefResponse,
		CefRefPtr[CefContentFilter]& cefContentFilter
		) except * with gil:

	cdef PyBrowser pyBrowser
	# cdef PyResponse pyResponse
	# cdef PyContentFilter pyContentFilter
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_OnResourceResponse() failed: pyBrowser is %s" % pyBrowser)
			return

		pyUrl = ToPyString(cefUrl)
		pyResponse = CreatePyResponse(cefResponse)
		pyContentFilter = None

		callback = pyBrowser.GetClientCallback("OnResourceResponse")
		if callback:
			callback(pyBrowser, pyUrl, pyResponse, pyContentFilter)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnProtocolExecution(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefUrl,
		c_bool& cefAllowOSExecution
		) except * with gil:

	# TODO: needs testing.

	cdef PyBrowser pyBrowser
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_OnProtocolExecution() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyUrl = ToPyString(cefUrl)
		pyAllowOSExecution = [bool(cefAllowOSExecution)] # [True] pass by reference.

		callback = pyBrowser.GetClientCallback("OnProtocolExecution")
		if callback:
			ret = callback(pyBrowser, pyUrl, pyAllowOSExecution)
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

	cdef PyBrowser pyBrowser
	# cdef PyDownloadHandler pyDownloadHandler
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_GetDownloadHandler() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyMimeType = ToPyString(cefMimeType)
		pyFilename = ToPyString(cefFilename)
		pyContentLength = int(cefContentLength)
		pyDownloadHandler = None

		callback = pyBrowser.GetClientCallback("GetDownloadHandler")
		if callback:
			return bool(callback(pyBrowser, pyMimeType, pyFilename, pyContentLength, pyDownloadHandler))
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

	cdef PyBrowser pyBrowser
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_GetAuthCredentials() failed: pyBrowser is %s" % pyBrowser)
			return False

		pyIsProxy = bool(cefIsProxy)
		pyHost = ToPyString(cefHost)
		pyPort = int(cefPort)
		pyRealm = ToPyString(cefRealm)
		pyScheme = ToPyString(cefScheme)
		pyUsername = [""]
		pyPassword = [""]

		callback = pyBrowser.GetClientCallback("GetAuthCredentials")
		if callback:
			ret = callback(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
			if ret:
				ToCefString(pyUsername[0], cefUsername)
				ToCefString(pyPassword[0], cefPassword)
			return bool(ret)
		else:
			# Default implementation.
			IF UNAME_SYSNAME == "Windows":
				ret = HttpAuthenticationDialog(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
				if ret:
					ToCefString(pyUsername[0], cefUsername)
					ToCefString(pyPassword[0], cefPassword)
				return bool(ret)
			return False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)



cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& mainUrl) except * with gil:

	# TODO: not yet implemented.
	return <CefRefPtr[CefCookieManager]>NULL

	cdef PyBrowser pyBrowser
	try:
		pyBrowser = GetPyBrowser(cefBrowser)
		if not pyBrowser:
			Debug("RequestHandler_GetCookieManager() failed: pyBrowser is %s" % pyBrowser)
			return <CefRefPtr[CefCookieManager]>NULL

		pyMainUrl = ToPyString(mainUrl)

		callback = pyBrowser.GetClientCallback("GetCookieManager")
		if callback:
			ret = callback(pyBrowser, pyMainUrl)
			if ret:
				pass
			return <CefRefPtr[CefCookieManager]>NULL
		else:
			return <CefRefPtr[CefCookieManager]>NULL
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

