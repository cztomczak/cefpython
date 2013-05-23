// Copyright (c) 2012-2013 CefPython Authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "web_request_client.h"

// Cython doesn't know nothing about 'const' so we need to remove it,
// otherwise you get compile error.

void WebRequestClient::OnStateChange(CefRefPtr<CefWebURLRequest> requester,
                             RequestState state) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnStateChange(webRequestId_, requester, state);
}

void WebRequestClient::OnRedirect(CefRefPtr<CefWebURLRequest> requester,
                      CefRefPtr<CefRequest> request,
                      CefRefPtr<CefResponse> response) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnRedirect(webRequestId_, requester, request, response);
}

void WebRequestClient::OnHeadersReceived(CefRefPtr<CefWebURLRequest> requester,
                             CefRefPtr<CefResponse> response) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnHeadersReceived(webRequestId_, requester, response);
}

void WebRequestClient::OnProgress(CefRefPtr<CefWebURLRequest> requester,
                      uint64 bytesSent, uint64 totalBytesToBeSent) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnProgress(webRequestId_, requester, bytesSent,
            totalBytesToBeSent);
}

void WebRequestClient::OnData(CefRefPtr<CefWebURLRequest> requester,
                  const void* data, int dataLength) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnData(webRequestId_, requester, const_cast<void*>(data),
            dataLength);
}

void WebRequestClient::OnError(CefRefPtr<CefWebURLRequest> requester,
                   ErrorCode errorCode) {
    REQUIRE_UI_THREAD();
    WebRequestClient_OnError(webRequestId_, requester, errorCode);
}
