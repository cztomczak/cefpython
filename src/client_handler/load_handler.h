// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_load_handler.h"


class LoadHandler : public CefLoadHandler
{
public:
    LoadHandler(){}
    virtual ~LoadHandler(){}

    typedef cef_transition_type_t TransitionType;

    void OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                              bool isLoading,
                              bool canGoBack,
                              bool canGoForward) override;

    void OnLoadStart(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefFrame> frame,
                     TransitionType transition_type) override;

    void OnLoadEnd(CefRefPtr<CefBrowser> browser,
                   CefRefPtr<CefFrame> frame,
                   int httpStatusCode) override;

    void OnLoadError(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefFrame> frame,
                     cef_errorcode_t errorCode,
                     const CefString& errorText,
                     const CefString& failedUrl) override;

private:
    IMPLEMENT_REFCOUNTING(LoadHandler);
};
