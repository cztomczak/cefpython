// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

// d:\cefpython\src\setup/cefpython.h(22) : warning C4190: 'RequestHandler_GetCookieManager' 
// has C-linkage specified, but returns UDT 'CefRefPtr<T>' which is incompatible with C
#pragma warning(disable:4190)

#include "include/cef_client.h"
#include "util.h"

// To be able to use 'public' declarations you need to include Python.h and cefpython.h.
#include "Python.h"
#include "setup/cefpython.h"

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

class ClientHandler : public CefClient,
				public CefLoadHandler,
				public CefKeyboardHandler,
				public CefV8ContextHandler,
				public CefRequestHandler,
				public CefDisplayHandler
/*
				public CefLifeSpanHandler,				
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

	// Implemented handlers:
	
	virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE
	{ return this; }
	
	virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE
	{ return this; }
	
	virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE
	{ return this; }
	
	virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE
	{ return this; }

	virtual CefRefPtr<CefV8ContextHandler> GetV8ContextHandler() OVERRIDE
	{ return this; }

	// Still NOT implemented handlers:

	virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE
	{ return NULL; }

	virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE
	{ return NULL; }
	
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

	virtual bool OnBeforeBrowse(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			CefRefPtr<CefRequest> request,
			cef_handler_navtype_t navType,
			bool isRedirect) OVERRIDE;

	virtual bool OnBeforeResourceLoad(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefRequest> request,
			CefString& redirectUrl,
			CefRefPtr<CefStreamReader>& resourceStream,
			CefRefPtr<CefResponse> response,
			int loadFlags) OVERRIDE;

	virtual void OnResourceRedirect(
			CefRefPtr<CefBrowser> browser,
			const CefString& old_url,
			CefString& new_url) OVERRIDE;

	virtual void OnResourceResponse(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			CefRefPtr<CefResponse> response,
			CefRefPtr<CefContentFilter>& filter) OVERRIDE;

	virtual bool OnProtocolExecution(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			bool& allowOSExecution) OVERRIDE;

	virtual bool GetDownloadHandler(
			CefRefPtr<CefBrowser> browser,
			const CefString& mimeType,
			const CefString& fileName,
			int64 contentLength,
			CefRefPtr<CefDownloadHandler>& handler) OVERRIDE;

	virtual bool GetAuthCredentials(
			CefRefPtr<CefBrowser> browser,
			bool isProxy,
			const CefString& host,
			int port,
			const CefString& realm,
			const CefString& scheme,
			CefString& username,
			CefString& password) OVERRIDE;

	virtual CefRefPtr<CefCookieManager> GetCookieManager(
			CefRefPtr<CefBrowser> browser,
			const CefString& main_url) OVERRIDE;

	//
	// CefDisplayHandler
	//

	virtual void OnAddressChange(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& url) OVERRIDE;

	virtual bool OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                const CefString& message,
                                const CefString& source,
                                int line) OVERRIDE;

	virtual void OnContentsSizeChange(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    int width,
                                    int height) OVERRIDE;

	virtual void OnNavStateChange(CefRefPtr<CefBrowser> browser,
                                bool canGoBack,
                                bool canGoForward) OVERRIDE;

	virtual void OnStatusMessage(CefRefPtr<CefBrowser> browser,
                               const CefString& value,
                               StatusType type) OVERRIDE;

	virtual void OnTitleChange(CefRefPtr<CefBrowser> browser,
                             const CefString& title) OVERRIDE;

	virtual bool OnTooltip(CefRefPtr<CefBrowser> browser,
                         CefString& text) OVERRIDE;	

	
	
protected:
	 
	// Include the default reference counting implementation.
	IMPLEMENT_REFCOUNTING(ClientHandler);
	
	// Include the default locking implementation.
	IMPLEMENT_LOCKING(ClientHandler);

};
