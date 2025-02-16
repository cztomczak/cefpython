// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#if defined(_WIN32)
#include <stdint.h>
#endif

#include "common/cefpython_public_api.h"

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
            ) override;
    
protected:
  IMPLEMENT_REFCOUNTING(CookieVisitor);
};
