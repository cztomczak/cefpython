// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "cookie_visitor.h"
#include <stdio.h>

bool CookieVisitor::Visit(
        const CefCookie& cookie,
        int count,
        int total,
        bool& deleteCookie
        ) {
    REQUIRE_IO_THREAD();
    return CookieVisitor_Visit(cookieVisitorId_, cookie, count, total, 
            deleteCookie);
}
