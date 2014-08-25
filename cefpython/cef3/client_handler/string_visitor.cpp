// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "string_visitor.h"
#include <stdio.h>

void StringVisitor::Visit(
        const CefString& string
        ) {
    StringVisitor_Visit(stringVisitorId_, string);
}
