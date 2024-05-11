// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "request_context_handler.h"
#include "common/cefpython_public_api.h"

// --------------------------------------------------------------------------
// CefRequestContextHandler
// --------------------------------------------------------------------------

// CefRefPtr<CefCookieManager> RequestContextHandler::GetCookieManager() {
//     REQUIRE_IO_THREAD();
//     if (browser_.get()) {
//         return RequestHandler_GetCookieManager(browser_,
//             browser_->GetMainFrame()->GetURL());
//     } else {
//         CefString mainUrl;
//         return RequestHandler_GetCookieManager(browser_, mainUrl);
//     }    
//     // Default: return NULL.
// }

