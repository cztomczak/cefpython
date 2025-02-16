// Copyright (c) 2018 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "cookie_access_filter.h"
#include "common/cefpython_public_api.h"


bool CookieAccessFilter::CanSendCookie(CefRefPtr<CefBrowser> browser,
                                       CefRefPtr<CefFrame> frame,
                                       CefRefPtr<CefRequest> request,
                                       const CefCookie& cookie) {
    REQUIRE_IO_THREAD();
    return CookieAccessFilter_CanSendCookie(browser, frame, request, cookie);
}

bool CookieAccessFilter::CanSaveCookie(CefRefPtr<CefBrowser> browser,
                                       CefRefPtr<CefFrame> frame,
                                       CefRefPtr<CefRequest> request,
                                       CefRefPtr<CefResponse> response,
                                       const CefCookie& cookie) {
    REQUIRE_IO_THREAD();
    return CookieAccessFilter_CanSaveCookie(browser, frame, request, response, cookie);
}
