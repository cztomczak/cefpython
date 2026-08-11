// Copyright (c) 2026 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once
#include "include/cef_resource_request_handler.h"
#include "cookie_access_filter.h"

// Forwards resource request callbacks to the CEF Python RequestHandler.
class ResourceRequestHandler : public CefResourceRequestHandler {
public:
    ResourceRequestHandler() {}
    virtual ~ResourceRequestHandler() {}

    CefRefPtr<CefCookieAccessFilter> GetCookieAccessFilter(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefFrame> frame,
            CefRefPtr<CefRequest> request) override;

    ReturnValue OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefRequest> request,
                                     CefRefPtr<CefCallback> callback) override;

    CefRefPtr<CefResourceHandler> GetResourceHandler(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefFrame> frame,
            CefRefPtr<CefRequest> request) override;

    void OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                            CefRefPtr<CefFrame> frame,
                            CefRefPtr<CefRequest> request,
                            CefRefPtr<CefResponse> response,
                            CefString& new_url) override;

    void OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefFrame> frame,
                             CefRefPtr<CefRequest> request,
                             bool& allow_os_execution) override;

private:
    IMPLEMENT_REFCOUNTING(ResourceRequestHandler);
};
