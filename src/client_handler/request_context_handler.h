// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#if defined(_WIN32)
#include <stdint.h>
#endif

#include "common/cefpython_public_api.h"

#include "include/cef_request_context_handler.h"
#include "include/base/cef_callback.h"

class RequestContextHandler :
        public CefRequestContextHandler
{
private:
    CefRefPtr<CefBrowser> browser_;

public:
    // Browser may be NULL when instantiated from cefpython.CreateBrowserSync.
    // In such case SetBrowser will be called after browser creation.
    // GetCookieManager must handle a case when browser is NULL.
    explicit RequestContextHandler(CefRefPtr<CefBrowser> browser)
            : browser_(browser) {
    }

    void SetBrowser(CefRefPtr<CefBrowser> browser) {
        browser_ = browser;
    }

private:
    IMPLEMENT_REFCOUNTING(RequestContextHandler);
};
