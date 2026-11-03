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
                          cef_log_severity_t level,
                          const CefString& message,
                          const CefString& source,
                          int line) override;

    bool OnAutoResize(CefRefPtr<CefBrowser> browser,
                      const CefSize& new_size) override;

    void OnLoadingProgressChange(CefRefPtr<CefBrowser> browser,
                                 double progress) override;
    
    bool OnCursorChange(CefRefPtr<CefBrowser> browser,
                    CefCursorHandle cursor,
                    cef_cursor_type_t type,
                    const CefCursorInfo& custom_cursor_info
                    ) override;

private:
    IMPLEMENT_REFCOUNTING(DisplayHandler);
};
