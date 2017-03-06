// Copyright (c) 2016 CEF Python. See the Authors and License files.

#include "common/cefpython_public_api.h"
#include "include/cef_life_span_handler.h"


class LifespanHandler : public CefLifeSpanHandler
{
public:
    LifespanHandler(){}
    virtual ~LifespanHandler(){}

    typedef cef_window_open_disposition_t WindowOpenDisposition;

    bool OnBeforePopup(CefRefPtr<CefBrowser> browser,
                       CefRefPtr<CefFrame> frame,
                       const CefString& target_url,
                       const CefString& target_frame_name,
                       WindowOpenDisposition target_disposition,
                       bool user_gesture,
                       const CefPopupFeatures& popupFeatures,
                       CefWindowInfo& windowInfo,
                       CefRefPtr<CefClient>& client,
                       CefBrowserSettings& settings,
                       bool* no_javascript_access) override;
    void OnAfterCreated(CefRefPtr<CefBrowser> browser) override;
    bool DoClose(CefRefPtr<CefBrowser> browser) override;
    void OnBeforeClose(CefRefPtr<CefBrowser> browser) override;

private:
    IMPLEMENT_REFCOUNTING(LifespanHandler);
};
