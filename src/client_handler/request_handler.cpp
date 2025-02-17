// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "request_handler.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_callback.h"


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


ReturnValue RequestHandler::OnBeforeResourceLoad(
                                        CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefRequest> request,
                                        CefRefPtr<CefCallback> callback)
{
    REQUIRE_IO_THREAD();
    bool retval = RequestHandler_OnBeforeResourceLoad(browser, frame, request);
    if (retval) {
        return RV_CANCEL;
    } else {
        return RV_CONTINUE;
    }
}


CefRefPtr<CefResourceHandler> RequestHandler::GetResourceHandler(
                                                CefRefPtr<CefBrowser> browser,
                                                CefRefPtr<CefFrame> frame,
                                                CefRefPtr<CefRequest> request)
{
    REQUIRE_IO_THREAD();
    return RequestHandler_GetResourceHandler(browser, frame, request);
}


void RequestHandler::OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefRequest> request,
                                        CefRefPtr<CefResponse> response,
                                        CefString& new_url)
{
    REQUIRE_IO_THREAD();
    RequestHandler_OnResourceRedirect(browser, frame, request->GetURL(),
                                      new_url, request, response);
}


bool RequestHandler::GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        bool isProxy,
                                        const CefString& host,
                                        int port,
                                        const CefString& realm,
                                        const CefString& scheme,
                                        CefRefPtr<CefAuthCallback> callback)
{
    REQUIRE_IO_THREAD();
    return RequestHandler_GetAuthCredentials(browser, frame, isProxy, host,
                                             port, realm, scheme, callback);
}


bool RequestHandler::OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                                    const CefString& origin_url,
                                    int64_t new_size,
                                    CefRefPtr<CefCallback> callback) {
    REQUIRE_IO_THREAD();
    return RequestHandler_OnQuotaRequest(browser, origin_url, new_size,
                                         callback);
}


void RequestHandler::OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                                         const CefString& url,
                                         bool& allow_os_execution) {
    REQUIRE_UI_THREAD();
    RequestHandler_OnProtocolExecution(browser, url, allow_os_execution);
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
                                               cef_termination_status_t status)
{
    REQUIRE_UI_THREAD();
    LOG(ERROR) << "[Browser process] OnRenderProcessTerminated()";
    RequestHandler_OnRendererProcessTerminated(browser, status);
}
