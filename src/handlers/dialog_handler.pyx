# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"


cdef public cpp_bool DialogHandler_OnFileDialog(
        CefRefPtr[CefBrowser] cef_browser,
        uint32 mode,
        const CefString& cefTitle,
        const CefString& cefDefaultFilePath,
        const cpp_vector[CefString]& cefAcceptFilters,
        int selected_accept_filter,
        CefRefPtr[CefFileDialogCallback] cefFileDialogCallback
        ) except * with gil:


    cdef PyBrowser pyBrowser
    cdef py_bool returnValue
    cdef py_string pyTitle
    cdef py_string pyDefaultFilePath
    cdef list pyAcceptFilters = []

    try:
        pyBrowser = GetPyBrowser(cef_browser, "OnFileDialog")

        pyTitle = CefToPyString(cefTitle)
        pyDefaultFilePath = CefToPyString(cefDefaultFilePath)

        for i in range(cefAcceptFilters.size()):
            pyAcceptFilters.append(CefToPyString(cefAcceptFilters[i]))


        callback = pyBrowser.GetClientCallback("OnFileDialog")
        if callback:
            returnValue = callback(
                     browser=pyBrowser,
                     mode=mode,
                     title=pyTitle,
                     default_file_path=pyDefaultFilePath,
                     accept_filters=pyAcceptFilters,
                     selected_accept_filter=selected_accept_filter,
                     file_dialog_callback = CreatePyFileDialogCallback(cefFileDialogCallback)
                   )


            return bool(returnValue)

    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

    return False





