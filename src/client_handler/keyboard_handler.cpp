// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "keyboard_handler.h"


bool KeyboardHandler::OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                                    const CefKeyEvent& event,
                                    CefEventHandle os_event,
                                    bool* is_keyboard_shortcut)
{
    REQUIRE_UI_THREAD();
    return KeyboardHandler_OnPreKeyEvent(browser, event, os_event,
                                         is_keyboard_shortcut);
}


bool KeyboardHandler:: OnKeyEvent(CefRefPtr<CefBrowser> browser,
                                  const CefKeyEvent& event,
                                  CefEventHandle os_event)
{
    REQUIRE_UI_THREAD();
    return KeyboardHandler_OnKeyEvent(browser, event, os_event);
}
