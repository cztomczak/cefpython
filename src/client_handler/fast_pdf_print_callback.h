#include "common/cefpython_public_api.h"

class CefFastPdfPrintCallback : public CefPdfPrintCallback
{
  public:
    explicit CefFastPdfPrintCallback(CefRefPtr<CefBrowser> browser)
        : browser_(browser) {}
    virtual void OnPdfPrintFinished(const CefString& path, bool ok) OVERRIDE;

  protected:
    CefRefPtr<CefBrowser> browser_;
    IMPLEMENT_REFCOUNTING(CefFastPdfPrintCallback);
};