// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "lifespan_handler.h"
#if defined(OS_WIN)
#include "dpi_aware.h"
#endif
#include "include/base/cef_logging.h"


bool LifespanHandler::OnBeforePopup(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    const CefString& target_url,
                                    const CefString& target_frame_name,
                                    WindowOpenDisposition target_disposition,
                                    bool user_gesture,
                                    const CefPopupFeatures& popupFeatures,
                                    CefWindowInfo& windowInfo,
                                    CefRefPtr<CefClient>& client,
                                    CefBrowserSettings& settings,
                                    CefRefPtr<CefDictionaryValue>& extra_info,
                                    bool* no_javascript_access)
{
    REQUIRE_UI_THREAD();
    // Note: passing popupFeatures is not yet supported.
    const int popupFeaturesNotImpl = 0;
    return LifespanHandler_OnBeforePopup(browser, frame, target_url,
                        target_frame_name, target_disposition, user_gesture,
                        popupFeaturesNotImpl, windowInfo, client, settings,
                        extra_info, no_javascript_access);
}


void LifespanHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser)
{
    REQUIRE_UI_THREAD();
    #if defined(OS_WIN)
    // High DPI support.
    CefString auto_zooming = ApplicationSettings_GetString("auto_zooming");
    if (!auto_zooming.empty()) {
        LOG(INFO) << "[Browser process] OnAfterCreated(): auto_zooming = "
                  << auto_zooming.ToString();
        SetBrowserDpiSettings(browser, auto_zooming);
    }
    #endif // OS_WIN
    LifespanHandler_OnAfterCreated(browser);
}


bool LifespanHandler::DoClose(CefRefPtr<CefBrowser> browser)
{
    REQUIRE_UI_THREAD();
    return LifespanHandler_DoClose(browser);
}


void LifespanHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser)
{
    REQUIRE_UI_THREAD();
    LifespanHandler_OnBeforeClose(browser);
}
