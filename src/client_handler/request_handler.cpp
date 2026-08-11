// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "request_handler.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_callback.h"


CefRefPtr<CefResourceRequestHandler> RequestHandler::GetResourceRequestHandler(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefFrame> frame,
        CefRefPtr<CefRequest> request,
        bool is_navigation,
        bool is_download,
        const CefString& request_initiator,
        bool& disable_default_handling) {
    return new ResourceRequestHandler();
}


bool RequestHandler::OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefRequest> request,
                                    bool user_gesture,
                                    bool is_redirect)
{
    REQUIRE_UI_THREAD();
    return RequestHandler_OnBeforeBrowse(browser, frame, request,
                                         user_gesture, is_redirect);
}


bool RequestHandler::GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                                        const CefString& origin_url,
                                        bool isProxy,
                                        const CefString& host,
                                        int port,
                                        const CefString& realm,
                                        const CefString& scheme,
                                        CefRefPtr<CefAuthCallback> callback)
{
    REQUIRE_IO_THREAD();
    return RequestHandler_GetAuthCredentials(browser, origin_url, isProxy,
                                             host, port, realm, scheme,
                                             callback);
}


bool RequestHandler::OnCertificateError(
                                  CefRefPtr<CefBrowser> browser, // not used
                                  cef_errorcode_t cert_error,
                                  const CefString& request_url,
                                  CefRefPtr<CefSSLInfo> ssl_info, // not used
                                  CefRefPtr<CefCallback> callback)
{
    REQUIRE_UI_THREAD();
    return RequestHandler_OnCertificateError(cert_error, request_url,
                                             callback);
}


void RequestHandler::OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                               cef_termination_status_t status,
                                               int error_code,
                                               const CefString& error_string)
{
    REQUIRE_UI_THREAD();
    LOG(ERROR) << "[Browser process] OnRenderProcessTerminated()";
    RequestHandler_OnRendererProcessTerminated(browser, status);
}
