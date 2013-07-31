// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "cookie_visitor.h"
#include <stdio.h>

bool CookieVisitor::Visit(
        const CefCookie& cookie,
        int count,
        int total,
        bool& deleteCookie
        ) {
    REQUIRE_IO_THREAD();
    return CookieVisitor_Visit(cookieVisitorId_, cookie, count, total, deleteCookie);
}
