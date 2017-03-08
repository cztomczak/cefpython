// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "focus_handler.h"


void FocusHandler::OnTakeFocus(CefRefPtr<CefBrowser> browser,
                               bool next)
{
    REQUIRE_UI_THREAD();
    FocusHandler_OnTakeFocus(browser, next);
}


bool FocusHandler::OnSetFocus(CefRefPtr<CefBrowser> browser,
                              cef_focus_source_t source)
{
    REQUIRE_UI_THREAD();
    return FocusHandler_OnSetFocus(browser, source);
}


void FocusHandler::OnGotFocus(CefRefPtr<CefBrowser> browser)
{
    REQUIRE_UI_THREAD();
    FocusHandler_OnGotFocus(browser);
}
