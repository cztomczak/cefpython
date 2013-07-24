// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ClientHandler : 
		public CefClient
{
public:
  ClientHandler(){}
  virtual ~ClientHandler(){}

  ///
  // Return the handler for context menus. If no handler is provided the default
  // implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefContextMenuHandler> GetContextMenuHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for dialogs. If no handler is provided the default
  // implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDialogHandler> GetDialogHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser display state events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for download events. If no handler is returned downloads
  // will not be allowed.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDownloadHandler> GetDownloadHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for drag events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for focus events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for geolocation permissions requests. If no handler is
  // provided geolocation access will be denied by default.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefGeolocationHandler> GetGeolocationHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for JavaScript dialogs. If no handler is provided the
  // default implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefJSDialogHandler> GetJSDialogHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for keyboard events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser life span events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser load status events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for off-screen rendering events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser request events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Called when a new message is received from a different process. Return true
  // if the message was handled or false otherwise. Do not keep a reference to
  // or attempt to access the message outside of this callback.
  ///
  /*--cef()--*/
  virtual bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message)
                                        OVERRIDE;

private:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  // IMPLEMENT_LOCKING(ClientHandler);

};
