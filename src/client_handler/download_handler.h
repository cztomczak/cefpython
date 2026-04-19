// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_download_handler.h"


class DownloadHandler : public CefDownloadHandler
{
public:
    DownloadHandler(){}
    virtual ~DownloadHandler(){}

    bool OnBeforeDownload(CefRefPtr<CefBrowser> browser,
                          CefRefPtr<CefDownloadItem> download_item,
                          const CefString& suggested_name,
                          CefRefPtr<CefBeforeDownloadCallback> callback
                          ) override;

    void OnDownloadUpdated(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefDownloadItem> download_item,
                           CefRefPtr<CefDownloadItemCallback> callback
                           ) override;

private:
    IMPLEMENT_REFCOUNTING(DownloadHandler);
};
