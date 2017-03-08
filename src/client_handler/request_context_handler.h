// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#if defined(_WIN32)
#include <stdint.h>
#endif

#include "common/cefpython_public_api.h"

class RequestContextHandler :
        public CefRequestContextHandler
{
private:
    CefRefPtr<CefBrowser> browser_;
    typedef cef_plugin_policy_t PluginPolicy;

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
    virtual bool OnBeforePluginLoad(const CefString& mime_type,
                                  const CefString& plugin_url,
                                  bool is_main_frame,
                                  const CefString& top_origin_url,
                                  CefRefPtr<CefWebPluginInfo> plugin_info,
                                  PluginPolicy* plugin_policy) OVERRIDE;

private:
    IMPLEMENT_REFCOUNTING(RequestContextHandler);
};
