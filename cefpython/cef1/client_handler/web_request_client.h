// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#include "cefpython_public_api.h"

class WebRequestClient : public CefWebURLRequestClient
{
public:
    int webRequestId_;
public:
    WebRequestClient(int webRequestId) :
            webRequestId_(webRequestId) {
    }    
    virtual ~WebRequestClient(){}

    virtual void OnStateChange(CefRefPtr<CefWebURLRequest> requester,
                             RequestState state) OVERRIDE;

    virtual void OnRedirect(CefRefPtr<CefWebURLRequest> requester,
                          CefRefPtr<CefRequest> request,
                          CefRefPtr<CefResponse> response) OVERRIDE;

    virtual void OnHeadersReceived(CefRefPtr<CefWebURLRequest> requester,
                                 CefRefPtr<CefResponse> response) OVERRIDE;

    virtual void OnProgress(CefRefPtr<CefWebURLRequest> requester,
                          uint64 bytesSent, uint64 totalBytesToBeSent) OVERRIDE;

    virtual void OnData(CefRefPtr<CefWebURLRequest> requester,
                      const void* data, int dataLength) OVERRIDE;

    virtual void OnError(CefRefPtr<CefWebURLRequest> requester,
                       ErrorCode errorCode) OVERRIDE;
protected:

  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(WebRequestClient);

  // Include the default locking implementation.
  IMPLEMENT_LOCKING(WebRequestClient);

};
