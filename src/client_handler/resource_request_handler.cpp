// Copyright (c) 2026 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "resource_request_handler.h"
#include "common/cefpython_public_api.h"
#include "include/base/cef_logging.h"


CefRefPtr<CefCookieAccessFilter>
ResourceRequestHandler::GetCookieAccessFilter(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request) {
    REQUIRE_IO_THREAD();
    return new CookieAccessFilter();
}


ResourceRequestHandler::ReturnValue
ResourceRequestHandler::OnBeforeResourceLoad(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request,
        CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    if (RequestHandler_OnBeforeResourceLoad(browser, frame, request)) {
        return RV_CANCEL;
    }
    return RV_CONTINUE;
}


CefRefPtr<CefResourceHandler> ResourceRequestHandler::GetResourceHandler(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request) {
    REQUIRE_IO_THREAD();
    return RequestHandler_GetResourceHandler(browser, frame, request);
}


void ResourceRequestHandler::OnResourceRedirect(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request,
        CefRefPtr<CefResponse> response,
    CefString& new_url) {
    REQUIRE_IO_THREAD();
    RequestHandler_OnResourceRedirect(browser, frame, request->GetURL(),
                                      new_url, request, response);
}


void ResourceRequestHandler::OnProtocolExecution(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request,
        bool& allow_os_execution) {
    REQUIRE_IO_THREAD();
    RequestHandler_OnProtocolExecution(browser, request->GetURL(),
                                       allow_os_execution);
}
