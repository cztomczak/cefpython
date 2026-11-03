// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_request_handler.h"
#include "include/base/cef_callback.h"
#include "cookie_access_filter.h"
#include "resource_request_handler.h"

class RequestHandler : public CefRequestHandler,
                       public CookieAccessFilter
{
public:
    RequestHandler(){}
    virtual ~RequestHandler(){}

    CefRefPtr<CefResourceRequestHandler> GetResourceRequestHandler(
                        CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefRequest> request,
                        bool is_navigation,
                        bool is_download,
                        const CefString& request_initiator,
                        bool& disable_default_handling) override;

    bool OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefRequest> request,
                        bool user_gesture,
                        bool is_redirect) override;

    bool GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                            const CefString& origin_url,
                            bool isProxy,
                            const CefString& host,
                            int port,
                            const CefString& realm,
                            const CefString& scheme,
                            CefRefPtr<CefAuthCallback> callback) override;

    bool OnCertificateError(CefRefPtr<CefBrowser> browser,
                            cef_errorcode_t cert_error,
                            const CefString& request_url,
                            CefRefPtr<CefSSLInfo> ssl_info,
                            CefRefPtr<CefCallback> callback) override;

    void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                   cef_termination_status_t status,
                                   int error_code,
                                   const CefString& error_string) override;

private:
    IMPLEMENT_REFCOUNTING(RequestHandler);
};
