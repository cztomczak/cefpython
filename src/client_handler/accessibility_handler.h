// Copyright (c) 2018 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_accessibility_handler.h"


class AccessibilityHandler : public CefAccessibilityHandler
{
public:
    AccessibilityHandler(){}
    virtual ~AccessibilityHandler(){}

    virtual void OnAccessibilityTreeChange(CefRefPtr<CefValue> value) override;
    virtual void OnAccessibilityLocationChange(CefRefPtr<CefValue> value) override;

private:
    IMPLEMENT_REFCOUNTING(AccessibilityHandler);
};
