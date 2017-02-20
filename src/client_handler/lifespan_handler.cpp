// Copyright (c) 2016 CEF Python. See the Authors and License files.

#include "lifespan_handler.h"
#include "dpi_aware.h"
#include "LOG_DEBUG.h"


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
                                    bool* no_javascript_access)
{
    REQUIRE_IO_THREAD();
    // Note: passing popupFeatures is not yet supported.
    const int popupFeaturesNotImpl = 0;
    return LifespanHandler_OnBeforePopup(browser, frame, target_url,
                        target_frame_name, target_disposition, user_gesture,
                        popupFeaturesNotImpl, windowInfo, client, settings,
                        no_javascript_access);
}


void LifespanHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser)
{
    REQUIRE_UI_THREAD();
    #if defined(OS_WIN)
    // High DPI support.
    CefString auto_zooming = ApplicationSettings_GetString("auto_zooming");
    if (!auto_zooming.empty()) {
        LOG_DEBUG << "Browser: OnAfterCreated(): auto_zooming = "
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
