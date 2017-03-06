// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "common/cefpython_public_api.h"

class WebRequestClient : public CefURLRequestClient
{
public:
    int webRequestId_;
public:
    WebRequestClient(int webRequestId) :
            webRequestId_(webRequestId) {
    }    
    virtual ~WebRequestClient(){}

    virtual void OnRequestComplete(CefRefPtr<CefURLRequest> request) OVERRIDE;

    virtual void OnUploadProgress(CefRefPtr<CefURLRequest> request,
                                int64 current,
                                int64 total) OVERRIDE;

    virtual void OnDownloadProgress(CefRefPtr<CefURLRequest> request,
                                  int64 current,
                                  int64 total) OVERRIDE;

    virtual void OnDownloadData(CefRefPtr<CefURLRequest> request,
                              const void* data,
                              size_t data_length) OVERRIDE;

    virtual bool GetAuthCredentials(bool isProxy,
                                  const CefString& host,
                                  int port,
                                  const CefString& realm,
                                  const CefString& scheme,
                                  CefRefPtr<CefAuthCallback> callback) OVERRIDE;

protected:
  IMPLEMENT_REFCOUNTING(WebRequestClient);
};
