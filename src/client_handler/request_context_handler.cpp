// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "request_context_handler.h"
#include "cefpython_public_api.h"
#include "DebugLog.h"

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
                        const CefString& top_origin_url,
                        CefRefPtr<CefWebPluginInfo> plugin_info,
                        PluginPolicy* plugin_policy) {
    // Called on multiple threads
    return RequestHandler_OnBeforePluginLoad(browser_, mime_type, plugin_url,
                                             top_origin_url, plugin_info,
                                             plugin_policy);
}
