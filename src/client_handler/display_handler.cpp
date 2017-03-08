// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "display_handler.h"


void DisplayHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    const CefString& url)
{
    REQUIRE_UI_THREAD();
    DisplayHandler_OnAddressChange(browser, frame, url);
}


void DisplayHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                                  const CefString& title)
{
    REQUIRE_UI_THREAD();
    DisplayHandler_OnTitleChange(browser, title);
}


bool DisplayHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                              CefString& text)
{
    REQUIRE_UI_THREAD();
    return DisplayHandler_OnTooltip(browser, text);
}


void DisplayHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                                    const CefString& value)
{
    REQUIRE_UI_THREAD();
    DisplayHandler_OnStatusMessage(browser, value);
}


bool DisplayHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                     const CefString& message,
                                     const CefString& source,
                                     int line)
{
    REQUIRE_UI_THREAD();
    return DisplayHandler_OnConsoleMessage(browser, message, source, line);
}
