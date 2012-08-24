// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "include/cef_client.h"
#include "util.h"
#include "setup/cefpython_api.h"
#include "Python.h"

// CefLoadHandler types.

typedef void (*OnLoadEnd_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame,
		int httpStatusCode
);

typedef void (*OnLoadStart_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame
);
	
typedef bool (*OnLoadError_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame,
		cef_handler_errorcode_t errorCode,
		const CefString& failedUrl,
		CefString& errorText
);

// CefKeyboardHandler types.

typedef bool (*OnKeyEvent_type)(
		CefRefPtr<CefBrowser> browser,
		cef_handler_keyevent_type_t eventType,
		int keyCode,
		int modifiers,
		bool isSystemKey,
		bool isAfterJavascript
);

// CefV8ContextHandler types.

typedef void (*OnContextCreated_type)(
		CefRefPtr<CefBrowser> cefBrowser,
		CefRefPtr<CefFrame> cefFrame,
		CefRefPtr<CefV8Context> v8Context
);

// CefRequestHandler types.

typedef bool (*OnBeforeBrowse_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame,
		CefRefPtr<CefRequest> request,
		cef_handler_navtype_t navType,
		bool isRedirect
);

typedef bool (*OnBeforeResourceLoad_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefRequest> request,
		CefString& redirectUrl,
		CefRefPtr<CefStreamReader>& resourceStream,
		CefRefPtr<CefResponse> response,
		int loadFlags
);

typedef void (*OnResourceRedirect_type)(
		CefRefPtr<CefBrowser> browser,
		const CefString& old_url,
		CefString& new_url
);

typedef void (*OnResourceResponse_type)(
		CefRefPtr<CefBrowser> browser,
		const CefString& url,
		CefRefPtr<CefResponse> response,
		CefRefPtr<CefContentFilter>& filter
);

typedef bool (*OnProtocolExecution_type)(
		CefRefPtr<CefBrowser> browser,
		const CefString& url,
		bool& allowOSExecution
);

typedef bool (*GetDownloadHandler_type)(
		CefRefPtr<CefBrowser> browser,
		const CefString& mimeType,
		const CefString& fileName,
		int64 contentLength,
		CefRefPtr<CefDownloadHandler>& handler
);

typedef bool (*GetAuthCredentials_type)(
		CefRefPtr<CefBrowser> browser,
		bool isProxy,
		const CefString& host,
		int port,
		const CefString& realm,
		const CefString& scheme,
		CefString& username,
		CefString& password
);

typedef CefRefPtr<CefCookieManager> (*GetCookieManager_type)(
		CefRefPtr<CefBrowser> browser,
		const CefString& main_url
);

// end of types.


class ClientHandler : public CefClient,
				public CefLoadHandler,
				public CefKeyboardHandler,
				public CefV8ContextHandler,
				public CefRequestHandler
/*
				public CefLifeSpanHandler,				
				public CefDisplayHandler,
				public CefFocusHandler,
				public CefPrintHandler,
				public CefDragHandler,
				public CefPermissionHandler,
				public DownloadListener{
*/
{
public:
	ClientHandler(){}
	virtual ~ClientHandler(){}

	// CefClient methods
	virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE
		{ return this; }
	
	virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE
		{ return this; }
	
	virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE
		{ return this; }
	
	virtual CefRefPtr<CefMenuHandler> GetMenuHandler() OVERRIDE
	{ return NULL; }  
	
	virtual CefRefPtr<CefPermissionHandler> GetPermissionHandler() OVERRIDE
	{ return NULL; }  
	
	virtual CefRefPtr<CefPrintHandler> GetPrintHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefFindHandler> GetFindHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefJSDialogHandler> GetJSDialogHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefV8ContextHandler> GetV8ContextHandler() OVERRIDE
		{ return this; }
	
	virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE
	{ return NULL; }

	//
	// CefLoadHandler methods.
	//

	// OnLoadEnd.

	OnLoadEnd_type OnLoadEnd_callback;
	void SetCallback_OnLoadEnd(OnLoadEnd_type callback) 
	{
		this->OnLoadEnd_callback = callback; 
	}
	virtual void OnLoadEnd(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			int httpStatusCode
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		this->OnLoadEnd_callback(browser, frame, httpStatusCode);
	}
	
	// OnLoadStart.

	OnLoadStart_type OnLoadStart_callback;
	void SetCallback_OnLoadStart(OnLoadStart_type callback)
	{
		this->OnLoadStart_callback = callback;
	}
	virtual void OnLoadStart(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		this->OnLoadStart_callback(browser, frame);
	}
	
	// OnLoadError.

	OnLoadError_type OnLoadError_callback;
	void SetCallback_OnLoadError(OnLoadError_type callback)
	{
		this->OnLoadError_callback = callback;
	}
	virtual bool OnLoadError(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			cef_handler_errorcode_t errorCode,
			const CefString& failedUrl,
			CefString& errorText
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return this->OnLoadError_callback(browser, frame, errorCode, failedUrl, errorText);
	}

	//
	// CefKeyboardHandler methods.
	//

	// OnKeyEvent.

	OnKeyEvent_type OnKeyEvent_callback;
	void SetCallback_OnKeyEvent(OnKeyEvent_type callback)
	{
		this->OnKeyEvent_callback = callback;
	}
	virtual bool OnKeyEvent(
			CefRefPtr<CefBrowser> browser,
			cef_handler_keyevent_type_t eventType,
			int keyCode,
			int modifiers,
			bool isSystemKey,
			bool isAfterJavascript
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return this->OnKeyEvent_callback(browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript);
	}

	//
	// CefV8ContextHandler methods.
	//

	// OnContextCreated.

	OnContextCreated_type OnContextCreated_callback;
	void SetCallback_OnContextCreated(OnContextCreated_type callback)
	{
		this->OnContextCreated_callback = callback;
	}
	virtual void OnContextCreated(
			CefRefPtr<CefBrowser> cefBrowser,
			CefRefPtr<CefFrame> cefFrame,
			CefRefPtr<CefV8Context> v8Context
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		this->OnContextCreated_callback(cefBrowser, cefFrame, v8Context);
	}

	// OnContextReleased.
	// Not implementing.

	//
	// CefRequestHandler methods.
	//

	// OnBeforeBrowse.

	OnBeforeBrowse_type OnBeforeBrowse_callback;
	void SetCallback_OnBeforeBrowse(OnBeforeBrowse_type callback)
	{
		this->OnBeforeBrowse_callback = callback;
	}
	virtual bool OnBeforeBrowse(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			CefRefPtr<CefRequest> request,
			cef_handler_navtype_t navType,
			bool isRedirect
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return false;
		//return this->OnBeforeBrowse_callback(browser, frame, request, navType, isRedirect);
	}

	// OnBeforeResourceLoad.

	OnBeforeResourceLoad_type OnBeforeResourceLoad_callback;
	void SetCallback_OnBeforeResourceLoad(OnBeforeResourceLoad_type callback)
	{
		this->OnBeforeResourceLoad_callback = callback;
	}
	virtual bool OnBeforeResourceLoad(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefRequest> request,
			CefString& redirectUrl,
			CefRefPtr<CefStreamReader>& resourceStream,
			CefRefPtr<CefResponse> response,
			int loadFlags
		) OVERRIDE
	{
		REQUIRE_IO_THREAD();
		bool ret;
		PyEval_InitThreads();
		//PyGILState_STATE gstate = PyGILState_Ensure();
		//Py_BEGIN_ALLOW_THREADS;
		ret = this->OnBeforeResourceLoad_callback(browser, request, redirectUrl, resourceStream, response, loadFlags);
		//Py_END_ALLOW_THREADS;
		//PyGILState_Release(gstate);
		return ret;
	}

	// OnResourceRedirect.

	OnResourceRedirect_type OnResourceRedirect_callback;
	void SetCallback_OnResourceRedirect(OnResourceRedirect_type callback)
	{
		this->OnResourceRedirect_callback = callback;
	}
	virtual void OnResourceRedirect(
			CefRefPtr<CefBrowser> browser,
			const CefString& old_url,
			CefString& new_url
		) OVERRIDE
	{
		REQUIRE_IO_THREAD();
		this->OnResourceRedirect_callback(browser, old_url, new_url);
	}

	// OnResourceResponse.

	OnResourceResponse_type OnResourceResponse_callback;
	void SetCallback_OnResourceResponse(OnResourceResponse_type callback)
	{
		this->OnResourceResponse_callback = callback;
	}
	virtual void OnResourceResponse(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			CefRefPtr<CefResponse> response,
			CefRefPtr<CefContentFilter>& filter
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		this->OnResourceResponse_callback(browser, url, response, filter);
	}

	// OnProtocolExecution.

	OnProtocolExecution_type OnProtocolExecution_callback;
	void SetCallback_OnProtocolExecution(OnProtocolExecution_type callback)
	{
		this->OnProtocolExecution_callback = callback;
	}
	virtual bool OnProtocolExecution(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			bool& allowOSExecution
		) OVERRIDE
	{
		REQUIRE_IO_THREAD();
		return this->OnProtocolExecution_callback(browser, url, allowOSExecution);
	}

	// GetDownloadHandler.

	GetDownloadHandler_type GetDownloadHandler_callback;
	void SetCallback_GetDownloadHandler(GetDownloadHandler_type callback)
	{
		this->GetDownloadHandler_callback = callback;
	}
	virtual bool GetDownloadHandler(
			CefRefPtr<CefBrowser> browser,
			const CefString& mimeType,
			const CefString& fileName,
			int64 contentLength,
			CefRefPtr<CefDownloadHandler>& handler
		) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return this->GetDownloadHandler_callback(browser, mimeType, fileName, contentLength, handler);
	}

	// GetAuthCredentials.

	GetAuthCredentials_type GetAuthCredentials_callback;
	void SetCallback_GetAuthCredentials(GetAuthCredentials_type callback)
	{
		this->GetAuthCredentials_callback = callback;
	}
	virtual bool GetAuthCredentials(
			CefRefPtr<CefBrowser> browser,
			bool isProxy,
			const CefString& host,
			int port,
			const CefString& realm,
			const CefString& scheme,
			CefString& username,
			CefString& password
		) OVERRIDE
	{
		REQUIRE_IO_THREAD();
		return this->GetAuthCredentials_callback(browser, isProxy, host, port, realm, scheme, username, password);
	}

	// GetCookieManager.

	GetCookieManager_type GetCookieManager_callback;
	void SetCallback_GetCookieManager(GetCookieManager_type callback)
	{
		this->GetCookieManager_callback = callback;
	}
	virtual CefRefPtr<CefCookieManager> GetCookieManager(
			CefRefPtr<CefBrowser> browser,
			const CefString& main_url
		) OVERRIDE
	{
		REQUIRE_IO_THREAD();
		return this->GetCookieManager_callback(browser, main_url);
	}
	
protected:
	 
	// Include the default reference counting implementation.
	IMPLEMENT_REFCOUNTING(ClientHandler);
	
	// Include the default locking implementation.
	IMPLEMENT_LOCKING(ClientHandler);

};
