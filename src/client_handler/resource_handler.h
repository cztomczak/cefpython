// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ResourceHandler : public CefResourceHandler
{
public:
    int resourceHandlerId_;
public:
    ResourceHandler(int resourceHandlerId)
        : resourceHandlerId_(resourceHandlerId) {
    }    

  virtual bool ProcessRequest(CefRefPtr<CefRequest> request,
                              CefRefPtr<CefCallback> callback) OVERRIDE;

  virtual void GetResponseHeaders(CefRefPtr<CefResponse> response,
                                  int64& response_length,
                                  CefString& redirectUrl) OVERRIDE;

  virtual bool ReadResponse(void* data_out,
                            int bytes_to_read,
                            int& bytes_read,
                            CefRefPtr<CefCallback> callback) OVERRIDE;

  virtual bool CanGetCookie(const CefCookie& cookie) OVERRIDE;

  virtual bool CanSetCookie(const CefCookie& cookie) OVERRIDE;

  virtual void Cancel() OVERRIDE;
    
protected:
  IMPLEMENT_REFCOUNTING(ResourceHandler);
};
