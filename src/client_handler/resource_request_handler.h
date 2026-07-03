// Copyright (c) 2026 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once
#include "include/cef_resource_request_handler.h"
#include "cookie_access_filter.h"

// Minimal CefResourceRequestHandler that returns a CookieAccessFilter.
// CEF 146 moved CanSendCookie/CanSaveCookie out of CefRequestHandler into
// CefCookieAccessFilter, reachable only via this intermediate interface.
class ResourceRequestHandler : public CefResourceRequestHandler {
public:
    ResourceRequestHandler() {}
    virtual ~ResourceRequestHandler() {}

    CefRefPtr<CefCookieAccessFilter> GetCookieAccessFilter(
            CefRefPtr<CefBrowser> browser,
            CefRefPtr<CefFrame> frame,
            CefRefPtr<CefRequest> request) override {
        return new CookieAccessFilter();
    }

private:
    IMPLEMENT_REFCOUNTING(ResourceRequestHandler);
};
