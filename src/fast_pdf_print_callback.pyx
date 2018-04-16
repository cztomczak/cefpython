include "cefpython.pyx"
include "browser.pyx"

cdef public void PrintToPDF_OnPdfPrintFinished(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefString& path,
        cpp_bool ok
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef py_string pyPath
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnPdfPrintFinished")
        pyPath = CefToPyString(path)
        callback = pyBrowser.GetClientCallback("OnMyPdfPrintFinished")
        if callback is None:
            callback = pyBrowser.GetClientCallback("OnPdfPrintFinished")
        if callback:
            callback(path=pyPath, ok=ok)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
