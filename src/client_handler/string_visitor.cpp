// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "string_visitor.h"
#include <stdio.h>

void StringVisitor::Visit(
        const CefString& string
        ) {
    StringVisitor_Visit(stringVisitorId_, string);
}
