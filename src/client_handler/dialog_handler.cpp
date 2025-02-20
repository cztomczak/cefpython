// Copyright (c) 2017 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "dialog_handler.h"


DialogHandler::DialogHandler()
{
#if defined(OS_LINUX)
    // Provide the GTK-based default dialog implementation on Linux.
    dialog_handler_ = new ClientDialogHandlerGtk();
#endif
}


bool DialogHandler::OnFileDialog(CefRefPtr<CefBrowser> browser,
                                 FileDialogMode mode,
                                 const CefString& title,
                                 const CefString& default_file_path,
                                 const std::vector<CefString>& accept_filters,
                                 CefRefPtr<CefFileDialogCallback> callback)
{
#if defined(OS_LINUX)
    return dialog_handler_->OnFileDialog(browser,
                                         mode,
                                         title,
                                         default_file_path,
                                         accept_filters,
                                         callback);
#else
    return false;
#endif

}
