// Copyright (c) 2012 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "include/cef_client.h"
#include "util.h"
#include "setup/cefpython_api.h"

// CefLoadHandler types.

typedef void (*OnLoadEnd_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame,
		int httpStatusCode);

typedef void (*OnLoadStart_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame);
	
typedef bool (*OnLoadError_type)(
		CefRefPtr<CefBrowser> browser,
		CefRefPtr<CefFrame> frame,
		cef_handler_errorcode_t errorCode,
		const CefString& failedUrl,
		CefString& errorText);

// CefKeyboardHandler types.

typedef bool (*OnKeyEvent_type)(
		CefRefPtr<CefBrowser> browser,
		cef_handler_keyevent_type_t eventType,
		int keyCode,
		int modifiers,
		bool isSystemKey,
		bool isAfterJavascript);

// CefV8ContextHandler types.

typedef void (*OnContextCreated_type)(
		CefRefPtr<CefBrowser> cefBrowser,
		CefRefPtr<CefFrame> cefFrame,
		CefRefPtr<CefV8Context> v8Context);

// end of types.


class ClientHandler : public CefClient,
				public CefLoadHandler,
				public CefKeyboardHandler,
				public CefV8ContextHandler
/*
				public CefLifeSpanHandler,
				public CefRequestHandler,
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
	{ return NULL; }
	
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

	// CefLoadHandler methods.

	// OnLoadEnd.
	OnLoadEnd_type OnLoadEnd_callback;
	void SetCallback_OnLoadEnd(OnLoadEnd_type callback) 
	{
		this->OnLoadEnd_callback = callback; 
	}
	virtual void OnLoadEnd(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			int httpStatusCode) OVERRIDE
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
			CefRefPtr<CefFrame> frame) OVERRIDE
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
			CefString& errorText) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return this->OnLoadError_callback(browser, frame, errorCode, failedUrl, errorText);
	}


	// CefKeyboardHandler methods.

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
			bool isAfterJavascript) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		return this->OnKeyEvent_callback(browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript);
	}

	// CefV8ContextHandler methods.

	// OnContextCreated.
	OnContextCreated_type OnContextCreated_callback;
	void SetCallback_OnContextCreated(OnContextCreated_type callback)
	{
		this->OnContextCreated_callback = callback;
	}
	virtual void OnContextCreated(
			CefRefPtr<CefBrowser> cefBrowser,
			CefRefPtr<CefFrame> cefFrame,
			CefRefPtr<CefV8Context> v8Context) OVERRIDE
	{
		REQUIRE_UI_THREAD();
		this->OnContextCreated_callback(cefBrowser, cefFrame, v8Context);
	}

	// OnContextReleased.
	// Not implementing.

	
	
protected:
	 
	// Include the default reference counting implementation.
	IMPLEMENT_REFCOUNTING(ClientHandler);
	
	// Include the default locking implementation.
	IMPLEMENT_LOCKING(ClientHandler);

};
