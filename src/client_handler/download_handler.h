// Copyright (c) 2016 CEF Python. See the Authors and License files.

#include "common/cefpython_public_api.h"
#include "include/cef_download_handler.h"


class DownloadHandler : public CefDownloadHandler
{
public:
    DownloadHandler(){}
    virtual ~DownloadHandler(){}

    void OnBeforeDownload(CefRefPtr<CefBrowser> browser,
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
