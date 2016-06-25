// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class RequestContextHandler :
        public CefRequestContextHandler
{
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

    virtual CefRefPtr<CefCookieManager> GetCookieManager() OVERRIDE;

private:
    CefRefPtr<CefBrowser> browser_;

private:
    IMPLEMENT_REFCOUNTING(RequestContextHandler);
};
