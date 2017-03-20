// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_jsdialog_handler.h"

#if defined(OS_LINUX)
#include "dialog_handler_gtk.h"
#endif


class JSDialogHandler : public CefJSDialogHandler
{
public:
    JSDialogHandler();
    virtual ~JSDialogHandler(){}

    typedef cef_jsdialog_type_t JSDialogType;

    bool OnJSDialog(CefRefPtr<CefBrowser> browser,
                    const CefString& origin_url,
                    JSDialogType dialog_type,
                    const CefString& message_text,
                    const CefString& default_prompt_text,
                    CefRefPtr<CefJSDialogCallback> callback,
                    bool& suppress_message) override;

    bool OnBeforeUnloadDialog(CefRefPtr<CefBrowser> browser,
                              const CefString& message_text,
                              bool is_reload,
                              CefRefPtr<CefJSDialogCallback> callback
                              ) override;

    void OnResetDialogState(CefRefPtr<CefBrowser> browser) override;
    void OnDialogClosed(CefRefPtr<CefBrowser> browser) override;

public:
#if defined(OS_LINUX)
    // Default dialog handler impl for GTK.
    CefRefPtr<ClientDialogHandlerGtk> dialog_handler_;
#endif

private:
    IMPLEMENT_REFCOUNTING(JSDialogHandler);
};
