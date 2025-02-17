// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#if defined(_WIN32)
#include <stdint.h>
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
                                  int64_t& response_length,
                                  CefString& redirectUrl) override;

  virtual bool ReadResponse(void* data_out,
                            int bytes_to_read,
                            int& bytes_read,
                            CefRefPtr<CefCallback> callback) override;

  virtual void Cancel() override;
    
private:
  IMPLEMENT_REFCOUNTING(ResourceHandler);
};
