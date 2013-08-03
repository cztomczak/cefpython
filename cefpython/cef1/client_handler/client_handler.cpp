// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "client_handler.h"
#include <stdio.h>

// The const_cast<> were required in Cython <= 0.17.4,
// TODO: get rid of it.

// -----------------------------------------------------------------------------
// CefLoadHandler
// -----------------------------------------------------------------------------

void ClientHandler::OnLoadEnd(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      int httpStatusCode) {
  REQUIRE_UI_THREAD();
  LoadHandler_OnLoadEnd(browser, frame, httpStatusCode);
}

void ClientHandler::OnLoadStart(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame) {
  REQUIRE_UI_THREAD();
  LoadHandler_OnLoadStart(browser, frame);
}

bool ClientHandler::OnLoadError(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      cef_handler_errorcode_t errorCode,
      const CefString& failedUrl,
      CefString& errorText
    ) {
  REQUIRE_UI_THREAD();
  return LoadHandler_OnLoadError(
      browser, frame, errorCode, const_cast<CefString&>(failedUrl), errorText);
}

// -----------------------------------------------------------------------------
// CefKeyboardHandler
// -----------------------------------------------------------------------------

bool ClientHandler::OnKeyEvent(
      CefRefPtr<CefBrowser> browser,
      cef_handler_keyevent_type_t eventType,
      int keyCode,
      int modifiers,
      bool isSystemKey,
      bool isAfterJavascript) {
  REQUIRE_UI_THREAD();
  return KeyboardHandler_OnKeyEvent(
      browser, eventType, keyCode, modifiers, isSystemKey, isAfterJavascript);
}

// -----------------------------------------------------------------------------
// CefV8ContextHandler
// -----------------------------------------------------------------------------

void ClientHandler::OnContextCreated(
      CefRefPtr<CefBrowser> cefBrowser,
      CefRefPtr<CefFrame> cefFrame,
      CefRefPtr<CefV8Context> v8Context) {
  REQUIRE_UI_THREAD();
  V8ContextHandler_OnContextCreated(cefBrowser, cefFrame, v8Context);
}

void ClientHandler::OnContextReleased(
      CefRefPtr<CefBrowser> cefBrowser,
      CefRefPtr<CefFrame> cefFrame,
      CefRefPtr<CefV8Context> v8Context) {
  REQUIRE_UI_THREAD();
  V8ContextHandler_OnContextReleased(cefBrowser, cefFrame, v8Context);
}

void ClientHandler::OnUncaughtException(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefRefPtr<CefV8Context> context,
      CefRefPtr<CefV8Exception> exception,
      CefRefPtr<CefV8StackTrace> stackTrace) {
  REQUIRE_UI_THREAD();
  V8ContextHandler_OnUncaughtException(
      browser, frame, context, exception, stackTrace);
}

// -----------------------------------------------------------------------------
// CefRequestHandler
// -----------------------------------------------------------------------------

bool ClientHandler::OnBeforeBrowse(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefRefPtr<CefRequest> request,
      cef_handler_navtype_t navType,
      bool isRedirect) {
  REQUIRE_UI_THREAD();
  return RequestHandler_OnBeforeBrowse(
      browser, frame, request, navType, isRedirect);
}

bool ClientHandler::OnBeforeResourceLoad(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefRequest> request,
      CefString& redirectUrl,
      CefRefPtr<CefStreamReader>& resourceStream,
      CefRefPtr<CefResponse> response,
      int loadFlags) {
  REQUIRE_IO_THREAD();
  return RequestHandler_OnBeforeResourceLoad(
      browser, request, redirectUrl, resourceStream, response, loadFlags);
}

void ClientHandler::OnResourceRedirect(
      CefRefPtr<CefBrowser> browser,
      const CefString& old_url,
      CefString& new_url) {
  REQUIRE_IO_THREAD();
  RequestHandler_OnResourceRedirect(
      browser, const_cast<CefString&>(old_url), new_url);
}

void ClientHandler::OnResourceResponse(
      CefRefPtr<CefBrowser> browser,
      const CefString& url,
      CefRefPtr<CefResponse> response,
      CefRefPtr<CefContentFilter>& filter) {
  REQUIRE_UI_THREAD();
  RequestHandler_OnResourceResponse(
      browser, const_cast<CefString&>(url), response, filter);
}

bool ClientHandler::OnProtocolExecution(
      CefRefPtr<CefBrowser> browser,
      const CefString& url,
      bool& allowOSExecution) {
  REQUIRE_IO_THREAD();
  return RequestHandler_OnProtocolExecution(
      browser, const_cast<CefString&>(url), allowOSExecution);
}

bool ClientHandler::GetDownloadHandler(
      CefRefPtr<CefBrowser> browser,
      const CefString& mimeType,
      const CefString& fileName,
      int64 contentLength,
      CefRefPtr<CefDownloadHandler>& handler) {
  // Multiple downloads at the same time?
  AutoLock lock_scope(this);
  REQUIRE_UI_THREAD();
  return RequestHandler_GetDownloadHandler(browser, mimeType, fileName, 
      contentLength, handler);
}

bool ClientHandler::GetAuthCredentials(
      CefRefPtr<CefBrowser> browser,
      bool isProxy,
      const CefString& host,
      int port,
      const CefString& realm,
      const CefString& scheme,
      CefString& username,
      CefString& password) {
  REQUIRE_IO_THREAD();
  return RequestHandler_GetAuthCredentials(
      browser, isProxy, const_cast<CefString&>(host), port,
      const_cast<CefString&>(realm), const_cast<CefString&>(scheme),
      username, password);
}

CefRefPtr<CefCookieManager> ClientHandler::GetCookieManager(
      CefRefPtr<CefBrowser> browser,
      const CefString& main_url) {
  REQUIRE_IO_THREAD();
  return RequestHandler_GetCookieManager(
      browser, const_cast<CefString&>(main_url));
}

// -----------------------------------------------------------------------------
// CefDisplayHandler
// -----------------------------------------------------------------------------

void ClientHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& url) {
  REQUIRE_UI_THREAD();
  DisplayHandler_OnAddressChange(browser, frame, const_cast<CefString&>(url));
}

bool ClientHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                const CefString& message,
                                const CefString& source,
                                int line) {
  REQUIRE_UI_THREAD();
  return DisplayHandler_OnConsoleMessage(
      browser, const_cast<CefString&>(message),
      const_cast<CefString&>(source), line);
}

void ClientHandler::OnContentsSizeChange(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    int width,
                                    int height) {
  REQUIRE_UI_THREAD();
  DisplayHandler_OnContentsSizeChange(browser, frame, width, height);
}

void ClientHandler::OnNavStateChange(CefRefPtr<CefBrowser> browser,
                                bool canGoBack,
                                bool canGoForward) {
  REQUIRE_UI_THREAD();
  DisplayHandler_OnNavStateChange(browser, canGoBack, canGoForward);
}

void ClientHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                               const CefString& value,
                               StatusType type) {
  REQUIRE_UI_THREAD();
  DisplayHandler_OnStatusMessage(browser, const_cast<CefString&>(value), type);
}


void ClientHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                             const CefString& title) {
  REQUIRE_UI_THREAD();
  DisplayHandler_OnTitleChange(browser, const_cast<CefString&>(title));
}

bool ClientHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                         CefString& text) {
  REQUIRE_UI_THREAD();
  return DisplayHandler_OnTooltip(browser, text);
}

// -----------------------------------------------------------------------------
// CefLifeSpanHandler
// -----------------------------------------------------------------------------

bool ClientHandler::DoClose(CefRefPtr<CefBrowser> browser) {
  REQUIRE_UI_THREAD();
  return LifespanHandler_DoClose(browser);
}

void ClientHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
  REQUIRE_UI_THREAD();
  LifespanHandler_OnAfterCreated(browser);
}

void ClientHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
  REQUIRE_UI_THREAD();
  LifespanHandler_OnBeforeClose(browser);
}

bool ClientHandler::OnBeforePopup(CefRefPtr<CefBrowser> parentBrowser,
                           const CefPopupFeatures& popupFeatures,
                           CefWindowInfo& windowInfo,
                           const CefString& url,
                           CefRefPtr<CefClient>& client,
                           CefBrowserSettings& settings) {
  REQUIRE_UI_THREAD();
  // @TODO
  return false;
}

bool ClientHandler::RunModal(CefRefPtr<CefBrowser> browser) {
  REQUIRE_UI_THREAD();
  return LifespanHandler_RunModal(browser);
}

// -----------------------------------------------------------------------------
// CefRenderHandler
// -----------------------------------------------------------------------------

#if defined(OS_WIN)

bool ClientHandler::GetViewRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) {
  REQUIRE_UI_THREAD();
  return RenderHandler_GetViewRect(browser, rect);
}

bool ClientHandler::GetScreenRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) {
  REQUIRE_UI_THREAD();
  return RenderHandler_GetScreenRect(browser, rect);
}

bool ClientHandler::GetScreenPoint(CefRefPtr<CefBrowser> browser,
                            int viewX,
                            int viewY,
                            int& screenX,
                            int& screenY) {
  REQUIRE_UI_THREAD();
  return RenderHandler_GetScreenPoint(
      browser, viewX, viewY, screenX, screenY);
}

void ClientHandler::OnPopupShow(CefRefPtr<CefBrowser> browser,
                         bool show) {
  REQUIRE_UI_THREAD();
  RenderHandler_OnPopupShow(browser, show);
}

void ClientHandler::OnPopupSize(CefRefPtr<CefBrowser> browser,
                         const CefRect& rect) {
  REQUIRE_UI_THREAD();
  RenderHandler_OnPopupSize(browser, const_cast<CefRect&>(rect));
}

void ClientHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                     PaintElementType type,
                     const RectList& dirtyRects,
                     const void* buffer) {
  REQUIRE_UI_THREAD();
  RenderHandler_OnPaint(browser, type,
      const_cast<RectList&>(dirtyRects),
      const_cast<void*>(buffer));
}

void ClientHandler::OnCursorChange(CefRefPtr<CefBrowser> browser,
                            CefCursorHandle cursor) {
  REQUIRE_UI_THREAD();
  RenderHandler_OnCursorChange(browser, cursor);
}

// #if defined(OS_WIN) - CefRenderHandler
#endif 

// -----------------------------------------------------------------------------
// CefDragHandler
// -----------------------------------------------------------------------------

bool ClientHandler::OnDragStart(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefDragData> dragData,
                           DragOperationsMask mask) {
  REQUIRE_UI_THREAD();
  return DragHandler_OnDragStart(browser, dragData, mask);
}

bool ClientHandler::OnDragEnter(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefDragData> dragData,
                         DragOperationsMask mask) {
  REQUIRE_UI_THREAD();
  return DragHandler_OnDragEnter(browser, dragData, mask);
}
