// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#if defined(_WIN32)
#include <stdint.h>
#endif

#include "common/cefpython_public_api.h"

class StringVisitor : public CefStringVisitor
{
public:
    int stringVisitorId_;
public:
    StringVisitor(int stringVisitorId)
        : stringVisitorId_(stringVisitorId) {
    }

    virtual void Visit(
            const CefString& string
            ) override;
    
protected:
  IMPLEMENT_REFCOUNTING(StringVisitor);
};
