// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class DownloadHandler : public CefDownloadHandler
{
public:
    int downloadHandlerId_;
public:
    DownloadHandler(int downloadHandlerId)
        : downloadHandlerId_(downloadHandlerId) {
    }

    virtual bool ReceivedData(void* data, int data_size) OVERRIDE;
    virtual void Complete() OVERRIDE;
    
protected:
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(DownloadHandler);
  // Include the default locking implementation.
  IMPLEMENT_LOCKING(DownloadHandler);
};
