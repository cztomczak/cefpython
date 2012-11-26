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
		c_bool isRedirect) except * with gil:
	
	# TODO: not yet implemented.
	return <c_bool>False

	try:
		# ignoreError=True - when creating browser window there is no browser yet added to the g_pyBrowsers,
		# it's happening because CreateBrowser() does the initial navigation.
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			return <c_bool>False
		
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		pyRequest = GetPyRequestByCefRequest(cefRequest)

		handler = pyBrowser.GetClientHandler("OnBeforeBrowse")
		if handler:
			return <c_bool>bool(handler(pyBrowser, pyFrame, pyRequest, <int>navType, isRedirect))
		else:
			return <c_bool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnBeforeResourceLoad(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefRequest] cefRequest,
		CefString& cefRedirectURL,
		CefRefPtr[CefStreamReader]& cefResourceStream,
		CefRefPtr[CefResponse] cefResponse,
		int loadFlags) except * with gil:

	# TODO: not yet implemented.
	return <c_bool>False

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
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
			return <c_bool>bool(ret)
		else:
			return <c_bool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceRedirect(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefOldURL,
		CefString& cefNewURL) except * with gil:

	# TODO: needs testing.

	try:
		return

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyOldURL = CefStringToPyString(cefOldURL)
		pyNewURL = [CefStringToPyString(cefNewURL)] # [""] - string by reference by passing in a list

		handler = pyBrowser.GetClientHandler("OnResourceRedirect")
		if handler:
			handler(pyBrowser, pyOldURL, pyNewURL)
			PyStringToCefString(pyNewURL[0], cefNewURL) # we should call it only when pyNewURL[0] changed.
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RequestHandler_OnResourceResponse(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		CefRefPtr[CefResponse] cefResponse,
		CefRefPtr[CefContentFilter]& cefFilter) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyURL = CefStringToPyString(cefURL)
		pyResponse = CreatePyResponse(cefResponse)
		pyFilter = None # TODO.

		handler = pyBrowser.GetClientHandler("OnResourceResponse")
		if handler:
			handler(pyBrowser, pyURL, pyResponse, pyFilter)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_OnProtocolExecution(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		c_bool& cefAllowOSExecution) except * with gil:

	# TODO: needs testing.

	try:
		return <c_bool>False

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyURL = CefStringToPyString(cefURL)
		pyAllowOSExecution = [bool(cefAllowOSExecution)] # [True]

		handler = pyBrowser.GetClientHandler("OnProtocolExecution")
		if handler:
			ret = handler(pyBrowser, pyURL, pyAllowOSExecution)
			cefAllowOSExecution = <c_bool>bool(pyAllowOSExecution[0])
			return <c_bool>bool(ret)
		else:
			return <c_bool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef public c_bool RequestHandler_GetDownloadHandler(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefMimeType,
		CefString& cefFilename,
		cef_types.int64 cefContentLength,
		CefRefPtr[CefDownloadHandler]& cefDownloadHandler) except * with gil:

	# TODO: not yet implemented.
	return <c_bool>False

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyMimeType = CefStringToPyString(cefMimeType)
		pyFilename = CefStringToPyString(cefFilename)
		pyContentLength = int(cefContentLength)
		pyDownloadHandler = None # TODO.

		handler = pyBrowser.GetClientHandler("GetDownloadHandler")
		if handler:
			return <c_bool>bool(handler(pyBrowser, pyMimeType, pyFilename, pyContentLength, pyDownloadHandler))
		else:
			return <c_bool>False
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
		CefString& cefPassword) except * with gil:

	try:
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
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
			return <c_bool>bool(ret)
		else:
			# Default implementation.
			IF UNAME_SYSNAME == "Windows":
				ret = Requesthandler_GetAuthCredentials_Windows(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
				if ret:
					PyStringToCefString(pyUsername[0], cefUsername)
					PyStringToCefString(pyPassword[0], cefPassword)
				return <c_bool>bool(ret)
			return <c_bool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

# Using "with nogil" in this function, so this needs to be a "cdef function".
cdef c_bool Requesthandler_GetAuthCredentials_Windows(browser, isProxy, host, port, realm, scheme, username, password) except *:
	
	cdef AuthCredentialsData* credentialsData
	innerWindowID = browser.GetInnerWindowID() # innerWindowID is a top window for a popup
	cdef HWND handle = <HWND><int>innerWindowID
	with nogil:
		credentialsData = AuthDialog(handle)
	if credentialsData == NULL:
		return <c_bool>False
	else:
		# In Python 2.7 c_str returns a string.
		username[0] = credentialsData.username.c_str()
		password[0] = credentialsData.password.c_str()
		# Python 3
		if str != bytes:
			# c_str() returned bytes.
			if type(username[0]) == bytes:
				username[0] = username[0].decode(g_applicationSettings["unicode_to_bytes_encoding"])
			if type(password[0]) == bytes:
				password[0] = password[0].decode(g_applicationSettings["unicode_to_bytes_encoding"])
		return <c_bool>True

cdef public CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& mainURL) except * with gil:

	# TODO: not yet implemented.
	return <CefRefPtr[CefCookieManager]>NULL

	try:
		return <CefRefPtr[CefCookieManager]>NULL

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyMainURL = CefStringToPyString(mainURL)

		handler = pyBrowser.GetClientHandler("GetCookieManager")
		if handler:
			ret = handler(pyBrowser, pyMainURL)
			if ret:
				# TODO: return CefCookieManager.
				pass
			return <CefRefPtr[CefCookieManager]>NULL 
		else:
			return <CefRefPtr[CefCookieManager]>NULL
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

