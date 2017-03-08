// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_keyboard_handler.h"


class KeyboardHandler : public CefKeyboardHandler
{
public:
    KeyboardHandler(){}
    virtual ~KeyboardHandler(){}

    bool OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                       const CefKeyEvent& event,
                       CefEventHandle os_event,
                       bool* is_keyboard_shortcut) override;

    bool OnKeyEvent(CefRefPtr<CefBrowser> browser,
                    const CefKeyEvent& event,
                    CefEventHandle os_event) override;

private:
    IMPLEMENT_REFCOUNTING(KeyboardHandler);
};
