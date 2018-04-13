#include "fast_pdf_print_callback.h"

void CefFastPdfPrintCallback::OnPdfPrintFinished(
        const CefString& path, bool ok
        ) {
    REQUIRE_UI_THREAD();
    PrintToPDF_OnPdfPrintFinished(browser_, path, ok);
}