from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_ptr cimport CefRefPtr
from cef_browser cimport CefBrowser


cdef extern from "client_handler/fast_pdf_print_callback.h":

    cdef cppclass CefFastPdfPrintCallback:
        CefFastPdfPrintCallback(CefRefPtr[CefBrowser] browser)
        void OnPdfPrintFinished(const CefString& path, cpp_bool ok)
