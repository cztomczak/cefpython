// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
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
            ) OVERRIDE;
    
protected:
  IMPLEMENT_REFCOUNTING(StringVisitor);
};
