// Copyright (c) 2018 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_resource_request_handler.h"


class CookieAccessFilter : public CefCookieAccessFilter
{
public:
    CookieAccessFilter(){}
    virtual ~CookieAccessFilter(){}

    virtual bool CanSendCookie(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               CefRefPtr<CefRequest> request,
                               const CefCookie& cookie) override;
    virtual bool CanSaveCookie(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              CefRefPtr<CefRequest> request,
                              CefRefPtr<CefResponse> response,
                              const CefCookie& cookie) override;

private:
    IMPLEMENT_REFCOUNTING(CookieAccessFilter);
};
