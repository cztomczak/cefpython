// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#include "common/cefpython_public_api.h"
#include "include/cef_display_handler.h"


class DisplayHandler : public CefDisplayHandler
{
public:
    DisplayHandler(){}
    virtual ~DisplayHandler(){}

    void OnAddressChange(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefFrame> frame,
                         const CefString& url) override;

    void OnTitleChange(CefRefPtr<CefBrowser> browser,
                       const CefString& title) override;

    bool OnTooltip(CefRefPtr<CefBrowser> browser,
                   CefString& text) override;

    void OnStatusMessage(CefRefPtr<CefBrowser> browser,
                         const CefString& value) override;

    bool OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                          const CefString& message,
                          const CefString& source,
                          int line) override;

private:
    IMPLEMENT_REFCOUNTING(DisplayHandler);
};
