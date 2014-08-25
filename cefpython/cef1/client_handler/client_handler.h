// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ClientHandler : public CefClient,
        public CefLoadHandler,
        public CefKeyboardHandler,
        public CefV8ContextHandler,
        public CefRequestHandler,
        public CefDisplayHandler,
        public CefLifeSpanHandler,
        public CefRenderHandler,
        public CefDragHandler
/*
        public CefFocusHandler,
        public CefMenuHandler,
        public CefPrintHandler,
        public CefPermissionHandler,
        public CefFindHandler,
        public CefJSDialogHandler,
*/
{
public:
  ClientHandler(){}
  virtual ~ClientHandler(){}

  // ---------------------------------------------------------------------------
  // Handlers that are already implemented
  // ---------------------------------------------------------------------------

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

  virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE
  { return this; }

  virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE
  { return this; }

  // ---------------------------------------------------------------------------
  // NOT yet implemented handlers
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefLoadHandler methods.
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefKeyboardHandler methods.
  // ---------------------------------------------------------------------------

  virtual bool OnKeyEvent(
      CefRefPtr<CefBrowser> browser,
      cef_handler_keyevent_type_t eventType,
      int keyCode,
      int modifiers,
      bool isSystemKey,
      bool isAfterJavascript
    ) OVERRIDE;

  // ---------------------------------------------------------------------------
  // CefV8ContextHandler methods.
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefRequestHandler methods.
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefDisplayHandler
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefLifeSpanHandler
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CefRenderHandler
  // ---------------------------------------------------------------------------

#if defined(OS_WIN)

  virtual bool GetViewRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) OVERRIDE;

  virtual bool GetScreenRect(CefRefPtr<CefBrowser> browser,
                             CefRect& rect) OVERRIDE;

  virtual bool GetScreenPoint(CefRefPtr<CefBrowser> browser,
                              int viewX,
                              int viewY,
                              int& screenX,
                              int& screenY) OVERRIDE;

  virtual void OnPopupShow(CefRefPtr<CefBrowser> browser,
                           bool show) OVERRIDE;

  virtual void OnPopupSize(CefRefPtr<CefBrowser> browser,
                           const CefRect& rect) OVERRIDE;

  virtual void OnPaint(CefRefPtr<CefBrowser> browser,
                       PaintElementType type,
                       const RectList& dirtyRects,
                       const void* buffer) OVERRIDE;

  virtual void OnCursorChange(CefRefPtr<CefBrowser> browser,
                              CefCursorHandle cursor) OVERRIDE;

#endif

  // --------------------------------------------------------------------------- 
  // CefDragHandler
  // ---------------------------------------------------------------------------

  virtual bool OnDragStart(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefDragData> dragData,
                           DragOperationsMask mask) OVERRIDE;

  virtual bool OnDragEnter(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefDragData> dragData,
                           DragOperationsMask mask) OVERRIDE;

protected:

  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);

  // Include the default locking implementation.
  IMPLEMENT_LOCKING(ClientHandler);

};
