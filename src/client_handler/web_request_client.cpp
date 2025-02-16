// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "web_request_client.h"

void WebRequestClient::OnRequestComplete(CefRefPtr<CefURLRequest> request) {
    WebRequestClient_OnRequestComplete(webRequestId_, request);
}

void WebRequestClient::OnUploadProgress(CefRefPtr<CefURLRequest> request,
                            int64_t current,
                            int64_t total) {
    WebRequestClient_OnUploadProgress(webRequestId_, request, current, total);
}

void WebRequestClient::OnDownloadProgress(CefRefPtr<CefURLRequest> request,
                              int64_t current,
                              int64_t total) {
    WebRequestClient_OnDownloadProgress(webRequestId_, request, current,
            total);
}

void WebRequestClient::OnDownloadData(CefRefPtr<CefURLRequest> request,
                          const void* data,
                          size_t data_length) {
    WebRequestClient_OnDownloadData(webRequestId_, request, data, data_length);
}

bool WebRequestClient::GetAuthCredentials(bool isProxy,
                                const CefString& host,
                                int port,
                                const CefString& realm,
                                const CefString& scheme,
                                CefRefPtr<CefAuthCallback> callback) {
    // Not yet implemented.
    return false;
}
