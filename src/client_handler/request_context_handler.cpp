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
