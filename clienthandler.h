#include "include/cef_client.h"

typedef void (*OnLoadEnd_Type)(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>, int);

class ClientHandler : public CefClient,
				public CefLoadHandler
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
	
	virtual CefRefPtr<CefV8ContextHandler> GetV8ContextHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE
	{ return NULL; }
	
	virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE
	{ return NULL; }

	OnLoadEnd_Type OnLoadEnd_Callback;
	void SetCallback_OnLoadEnd(OnLoadEnd_Type callback)
	{
		this->OnLoadEnd_Callback = callback;
	}

	void ClientHandler::OnLoadEnd(CefRefPtr<CefBrowser> browser,
					CefRefPtr<CefFrame> frame,
					int httpStatusCode) OVERRIDE;
	
protected:
	 
	// Include the default reference counting implementation.
	IMPLEMENT_REFCOUNTING(ClientHandler);
	
	// Include the default locking implementation.
	IMPLEMENT_LOCKING(ClientHandler);

};
