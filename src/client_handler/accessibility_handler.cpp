// Copyright (c) 2018 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "accessibility_handler.h"
#include "common/cefpython_public_api.h"


void AccessibilityHandler::OnAccessibilityTreeChange(
                           CefRefPtr<CefValue> value) {
    REQUIRE_UI_THREAD();
    AccessibilityHandler_OnAccessibilityTreeChange(value);
}

void AccessibilityHandler::OnAccessibilityLocationChange(
                           CefRefPtr<CefValue> value) {
    REQUIRE_UI_THREAD();
    AccessibilityHandler_OnAccessibilityLocationChange(value);
}
