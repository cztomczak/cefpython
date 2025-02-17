// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_request_handler.h"
#include "include/base/cef_callback.h"
#include "cookie_access_filter.h"

typedef cef_return_value_t ReturnValue;


class RequestHandler : public CefRequestHandler,
                       public CookieAccessFilter
{
public:
    RequestHandler(){}
    virtual ~RequestHandler(){}

    bool OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefRequest> request,
                        bool user_gesture,
                        bool is_redirect) override;

    ReturnValue OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser,
                                     CefRefPtr<CefFrame> frame,
                                     CefRefPtr<CefRequest> request,
                                     CefRefPtr<CefCallback> callback
                                     ) ;

    CefRefPtr<CefResourceHandler> GetResourceHandler(
                                      CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame,
                                      CefRefPtr<CefRequest> request) ;

    void OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                            CefRefPtr<CefFrame> frame,
                            CefRefPtr<CefRequest> request,
                            CefRefPtr<CefResponse> response,
                            CefString& new_url) ;

    bool GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                            CefRefPtr<CefFrame> frame,
                            bool isProxy,
                            const CefString& host,
                            int port,
                            const CefString& realm,
                            const CefString& scheme,
                            CefRefPtr<CefAuthCallback> callback) ;

    bool OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                        const CefString& origin_url,
                        int64_t new_size,
                        CefRefPtr<CefCallback> callback) ;

    void OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                             const CefString& url,
                             bool& allow_os_execution) ;

    bool OnCertificateError(CefRefPtr<CefBrowser> browser,
                            cef_errorcode_t cert_error,
                            const CefString& request_url,
                            CefRefPtr<CefSSLInfo> ssl_info,
                            CefRefPtr<CefCallback> callback) override;

    void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                   cef_termination_status_t status) override;

private:
    IMPLEMENT_REFCOUNTING(RequestHandler);
};
