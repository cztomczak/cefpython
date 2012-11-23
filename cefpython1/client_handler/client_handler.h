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

// Python 3.2 fix - DL_IMPORT is not defined in Python.h
#ifndef DL_IMPORT /* declarations for DLL import/export */
#define DL_IMPORT(RTYPE) RTYPE
#endif
#ifndef DL_EXPORT /* declarations for DLL import/export */
#define DL_EXPORT(RTYPE) RTYPE
#endif

#include "setup/cefpython.h"

class ClientHandler : public CefClient,
        public CefLoadHandler,
        public CefKeyboardHandler,
        public CefV8ContextHandler,
        public CefRequestHandler,
        public CefDisplayHandler,
        public CefLifeSpanHandler
/*
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

  virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE
  { return this; }

  // NOT implemented handlers:

  virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE
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

  virtual void OnLoadEnd(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      int httpStatusCode
    ) OVERRIDE;
  
  
  virtual void OnLoadStart(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame
    ) OVERRIDE;
  
  virtual bool OnLoadError(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      cef_handler_errorcode_t errorCode,
      const CefString& failedUrl,
      CefString& errorText
    ) OVERRIDE;

  //
  // CefKeyboardHandler methods.
  //

  virtual bool OnKeyEvent(
      CefRefPtr<CefBrowser> browser,
      cef_handler_keyevent_type_t eventType,
      int keyCode,
      int modifiers,
      bool isSystemKey,
      bool isAfterJavascript
    ) OVERRIDE;

  //
  // CefV8ContextHandler methods.
  //

  virtual void OnContextCreated(
      CefRefPtr<CefBrowser> cefBrowser,
      CefRefPtr<CefFrame> cefFrame,
      CefRefPtr<CefV8Context> v8Context) OVERRIDE;

  virtual void OnContextReleased(
      CefRefPtr<CefBrowser> cefBrowser,
      CefRefPtr<CefFrame> cefFrame,
      CefRefPtr<CefV8Context> v8Context) OVERRIDE;

  virtual void OnUncaughtException(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefRefPtr<CefV8Context> context,
      CefRefPtr<CefV8Exception> exception,
      CefRefPtr<CefV8StackTrace> stackTrace) OVERRIDE;

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

  //
  // CefLifeSpanHandler
  //

  virtual bool DoClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

  virtual void OnAfterCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;

  virtual void OnBeforeClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

  virtual bool OnBeforePopup(CefRefPtr<CefBrowser> parentBrowser,
                             const CefPopupFeatures& popupFeatures,
                             CefWindowInfo& windowInfo,
                             const CefString& url,
                             CefRefPtr<CefClient>& client,
                             CefBrowserSettings& settings) OVERRIDE;

  virtual bool RunModal(CefRefPtr<CefBrowser> browser) OVERRIDE;

  
  
protected:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  IMPLEMENT_LOCKING(ClientHandler);

};
