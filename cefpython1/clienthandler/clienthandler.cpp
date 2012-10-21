#include "clienthandler.h"
#include <stdio.h>

// Cython doesn't know nothing about 'const' so we need to remove it,
// otherwise you get compile error.

// 
// CefRequestHandler
//

bool ClientHandler::OnBeforeBrowse(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefFrame> frame,
			CefRefPtr<CefRequest> request,
			cef_handler_navtype_t navType,
			bool isRedirect)
{
	REQUIRE_UI_THREAD();
	return RequestHandler_OnBeforeBrowse(browser, frame, request, navType, isRedirect);
}

bool ClientHandler::OnBeforeResourceLoad(
			CefRefPtr<CefBrowser> browser,
			CefRefPtr<CefRequest> request,
			CefString& redirectUrl,
			CefRefPtr<CefStreamReader>& resourceStream,
			CefRefPtr<CefResponse> response,
			int loadFlags)
{
	REQUIRE_IO_THREAD();
	return RequestHandler_OnBeforeResourceLoad(browser, request, redirectUrl, resourceStream, response, loadFlags);
}

void ClientHandler::OnResourceRedirect(
			CefRefPtr<CefBrowser> browser,
			const CefString& old_url,
			CefString& new_url)
{
	REQUIRE_IO_THREAD();
	RequestHandler_OnResourceRedirect(browser, const_cast<CefString&>(old_url), new_url);
}

void ClientHandler::OnResourceResponse(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			CefRefPtr<CefResponse> response,
			CefRefPtr<CefContentFilter>& filter)
{
	REQUIRE_UI_THREAD();
	RequestHandler_OnResourceResponse(browser, const_cast<CefString&>(url), response, filter);
}

bool ClientHandler::OnProtocolExecution(
			CefRefPtr<CefBrowser> browser,
			const CefString& url,
			bool& allowOSExecution)
{
	REQUIRE_IO_THREAD();
	return RequestHandler_OnProtocolExecution(browser, const_cast<CefString&>(url), allowOSExecution);
}

bool ClientHandler::GetDownloadHandler(
			CefRefPtr<CefBrowser> browser,
			const CefString& mimeType,
			const CefString& fileName,
			int64 contentLength,
			CefRefPtr<CefDownloadHandler>& handler)
{
	REQUIRE_UI_THREAD();
	return RequestHandler_GetDownloadHandler(browser, const_cast<CefString&>(mimeType), const_cast<CefString&>(fileName), contentLength, handler);
}

bool ClientHandler::GetAuthCredentials(
			CefRefPtr<CefBrowser> browser,
			bool isProxy,
			const CefString& host,
			int port,
			const CefString& realm,
			const CefString& scheme,
			CefString& username,
			CefString& password)
{
	REQUIRE_IO_THREAD();
	return RequestHandler_GetAuthCredentials(browser, isProxy, const_cast<CefString&>(host), port, const_cast<CefString&>(realm),
		const_cast<CefString&>(scheme), username, password);
}

CefRefPtr<CefCookieManager> ClientHandler::GetCookieManager(
			CefRefPtr<CefBrowser> browser,
			const CefString& main_url)
{
	REQUIRE_IO_THREAD();
	return RequestHandler_GetCookieManager(browser, const_cast<CefString&>(main_url));
}

// 
// CefDisplayHandler
//

void ClientHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& url) 
{
	DisplayHandler_OnAddressChange(browser, frame, const_cast<CefString&>(url));
}

bool ClientHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                const CefString& message,
                                const CefString& source,
                                int line) 
{
	return DisplayHandler_OnConsoleMessage(browser, const_cast<CefString&>(message), const_cast<CefString&>(source), line);
}

void ClientHandler::OnContentsSizeChange(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    int width,
                                    int height) 
{
	DisplayHandler_OnContentsSizeChange(browser, frame, width, height);
}

void ClientHandler::OnNavStateChange(CefRefPtr<CefBrowser> browser,
                                bool canGoBack,
                                bool canGoForward)
{
	DisplayHandler_OnNavStateChange(browser, canGoBack, canGoForward);
}

void ClientHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                               const CefString& value,
                               StatusType type) 
{
	DisplayHandler_OnStatusMessage(browser, const_cast<CefString&>(value), type);
}


void ClientHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                             const CefString& title) 
{
	DisplayHandler_OnTitleChange(browser, const_cast<CefString&>(title));
}

bool ClientHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                         CefString& text) 
{
	return DisplayHandler_OnTooltip(browser, text); 
}

