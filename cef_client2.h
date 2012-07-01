#include "include/cef_client.h"

class CefClient2 : public CefClient

{
public:
	CefClient2()
	{
	}
	virtual ~CefClient2()
	{
	}

	// CefClient methods
  virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE
      { return NULL; }
  virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE
      { return NULL; }
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

protected:
	 // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(CefClient2);
  // Include the default locking implementation.
  IMPLEMENT_LOCKING(CefClient2);
};