// Copyright (c) 2017 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once

#include "common/cefpython_public_api.h"
#include "include/cef_dialog_handler.h"

#if defined(OS_LINUX)
#include "dialog_handler_gtk.h"
#endif


class DialogHandler : public CefDialogHandler
{
public:
    DialogHandler();
    virtual ~DialogHandler(){}

    bool OnFileDialog(CefRefPtr<CefBrowser> browser,
                      FileDialogMode mode,
                      const CefString& title,
                      const CefString& default_file_path,
                      const std::vector<CefString>& accept_filters,
                      CefRefPtr<CefFileDialogCallback> callback)
                      override;

public:
#if defined(OS_LINUX)
    // Default dialog handler impl for GTK.
    CefRefPtr<ClientDialogHandlerGtk> dialog_handler_;
#endif

private:
    IMPLEMENT_REFCOUNTING(DialogHandler);
};
