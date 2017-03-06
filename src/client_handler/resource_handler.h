// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "common/cefpython_public_api.h"

class ResourceHandler : public CefResourceHandler
{
public:
    int resourceHandlerId_;
public:
    ResourceHandler(int resourceHandlerId)
        : resourceHandlerId_(resourceHandlerId) {
    }    

  virtual bool ProcessRequest(CefRefPtr<CefRequest> request,
                              CefRefPtr<CefCallback> callback) override;

  virtual void GetResponseHeaders(CefRefPtr<CefResponse> response,
                                  int64& response_length,
                                  CefString& redirectUrl) override;

  virtual bool ReadResponse(void* data_out,
                            int bytes_to_read,
                            int& bytes_read,
                            CefRefPtr<CefCallback> callback) override;

  virtual bool CanGetCookie(const CefCookie& cookie) override;

  virtual bool CanSetCookie(const CefCookie& cookie) override;

  virtual void Cancel() OVERRIDE;
    
private:
  IMPLEMENT_REFCOUNTING(ResourceHandler);
};
