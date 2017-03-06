// Copyright (c) 2016 CEF Python. See the Authors and License files.

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
