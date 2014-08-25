// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class CookieVisitor : public CefCookieVisitor
{
public:
    int cookieVisitorId_;
public:
    CookieVisitor(int cookieVisitorId)
        : cookieVisitorId_(cookieVisitorId) {
    }    

    virtual bool Visit(
            const CefCookie& cookie,
            int count,
            int total,
            bool& deleteCookie
            ) OVERRIDE;
    
protected:
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(CookieVisitor);
};
