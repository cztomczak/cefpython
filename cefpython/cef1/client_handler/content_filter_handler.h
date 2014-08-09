// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ContentFilterHandler : public CefContentFilter
{
public:
    int contentFilterId_;
public:
    ContentFilterHandler(int contentFilterId) :
            contentFilterId_(contentFilterId) {
    }    
    virtual ~ContentFilterHandler(){}

    virtual void ProcessData(const void* data, int data_size,
                           CefRefPtr<CefStreamReader>& substitute_data) OVERRIDE;

    virtual void Drain(CefRefPtr<CefStreamReader>& remainder) OVERRIDE;
    
protected:
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ContentFilterHandler);
};
