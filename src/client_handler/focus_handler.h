// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_focus_handler.h"


class FocusHandler : public CefFocusHandler
{
public:
    FocusHandler(){}
    virtual ~FocusHandler(){}

    void OnTakeFocus(CefRefPtr<CefBrowser> browser,
                     bool next) override;

    bool OnSetFocus(CefRefPtr<CefBrowser> browser,
                    cef_focus_source_t source) override;

    void OnGotFocus(CefRefPtr<CefBrowser> browser) override;

private:
    IMPLEMENT_REFCOUNTING(FocusHandler);
};
