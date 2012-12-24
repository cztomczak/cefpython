#include "client_handler.h"
#include <stdio.h>

// Cython doesn't know nothing about 'const' so we need to remove it,
// otherwise you get compile error.

//
// CefLoadHandler
//

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

//
// CefKeyboardHandler
//

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

//
// CefV8ContextHandler
//

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

//
// CefRequestHandler
//

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
  REQUIRE_UI_THREAD();
  return RequestHandler_GetDownloadHandler(
      browser, const_cast<CefString&>(mimeType),
      const_cast<CefString&>(fileName), contentLength, handler);
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

//
// CefDisplayHandler
//

void ClientHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& url) {
  DisplayHandler_OnAddressChange(browser, frame, const_cast<CefString&>(url));
}

bool ClientHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                const CefString& message,
                                const CefString& source,
                                int line) {
  return DisplayHandler_OnConsoleMessage(
      browser, const_cast<CefString&>(message),
      const_cast<CefString&>(source), line);
}

void ClientHandler::OnContentsSizeChange(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    int width,
                                    int height) {
  DisplayHandler_OnContentsSizeChange(browser, frame, width, height);
}

void ClientHandler::OnNavStateChange(CefRefPtr<CefBrowser> browser,
                                bool canGoBack,
                                bool canGoForward) {
  DisplayHandler_OnNavStateChange(browser, canGoBack, canGoForward);
}

void ClientHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                               const CefString& value,
                               StatusType type) {
  DisplayHandler_OnStatusMessage(browser, const_cast<CefString&>(value), type);
}


void ClientHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                             const CefString& title) {
  DisplayHandler_OnTitleChange(browser, const_cast<CefString&>(title));
}

bool ClientHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                         CefString& text) {
  return DisplayHandler_OnTooltip(browser, text);
}

//
// CefLifeSpanHandler
//

bool ClientHandler::DoClose(CefRefPtr<CefBrowser> browser) {
  return LifespanHandler_DoClose(browser);
}

void ClientHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
  LifespanHandler_OnAfterCreated(browser);
}

void ClientHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
  LifespanHandler_OnBeforeClose(browser);
}

bool ClientHandler::OnBeforePopup(CefRefPtr<CefBrowser> parentBrowser,
                           const CefPopupFeatures& popupFeatures,
                           CefWindowInfo& windowInfo,
                           const CefString& url,
                           CefRefPtr<CefClient>& client,
                           CefBrowserSettings& settings) {
  // @TODO
  return false;
}

bool ClientHandler::RunModal(CefRefPtr<CefBrowser> browser) {
  return LifespanHandler_RunModal(browser);
}

//
// CefRenderHandler
//

bool ClientHandler::GetViewRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) {
  return RenderHandler_GetViewRect(browser, rect);
}

bool ClientHandler::GetScreenRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) {
  return RenderHandler_GetScreenRect(browser, rect);
}

bool ClientHandler::GetScreenPoint(CefRefPtr<CefBrowser> browser,
                            int viewX,
                            int viewY,
                            int& screenX,
                            int& screenY) {
  return RenderHandler_GetScreenPoint(
      browser, viewX, viewY, screenX, screenY);
}

void ClientHandler::OnPopupShow(CefRefPtr<CefBrowser> browser,
                         bool show) {
  RenderHandler_OnPopupShow(browser, show);
}

void ClientHandler::OnPopupSize(CefRefPtr<CefBrowser> browser,
                         const CefRect& rect) {
  RenderHandler_OnPopupSize(browser, const_cast<CefRect&>(rect));
}

void ClientHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                     PaintElementType type,
                     const RectList& dirtyRects,
                     const void* buffer) {
  RenderHandler_OnPaint(browser, type,
      const_cast<RectList&>(dirtyRects),
      const_cast<void*>(buffer));
}

void ClientHandler::OnCursorChange(CefRefPtr<CefBrowser> browser,
                            CefCursorHandle cursor) {
  RenderHandler_OnCursorChange(browser, cursor);
}
