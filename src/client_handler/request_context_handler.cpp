// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "request_context_handler.h"
#include "common/cefpython_public_api.h"

// --------------------------------------------------------------------------
// CefRequestContextHandler
// --------------------------------------------------------------------------

CefRefPtr<CefCookieManager> RequestContextHandler::GetCookieManager() {
    REQUIRE_IO_THREAD();
    if (browser_.get()) {
        return RequestHandler_GetCookieManager(browser_,
            browser_->GetMainFrame()->GetURL());
    } else {
        CefString mainUrl;
        return RequestHandler_GetCookieManager(browser_, mainUrl);
    }    
    // Default: return NULL.
}

bool RequestContextHandler::OnBeforePluginLoad(
                        const CefString& mime_type,
                        const CefString& plugin_url,
                        bool is_main_frame,
                        const CefString& top_origin_url,
                        CefRefPtr<CefWebPluginInfo> plugin_info,
                        PluginPolicy* plugin_policy) {
    // Called on multiple threads
    return RequestHandler_OnBeforePluginLoad(browser_,
                                             mime_type,
                                             plugin_url,
                                             is_main_frame,
                                             top_origin_url,
                                             plugin_info,
                                             plugin_policy);
}
