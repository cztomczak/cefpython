# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"


cdef class PyFileDialogCallback:
    cdef CefRefPtr[CefFileDialogCallback] cefCallback
    cpdef py_void Continue(self,int selected_accept_filter,list file_paths):
        cdef cpp_vector[CefString] filePaths
        for f in file_paths:
            filePaths.push_back(PyToCefStringValue(f))
        self.cefCallback.get().Continue(selected_accept_filter,filePaths)

    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()


cdef PyFileDialogCallback CreatePyFileDialogCallback(
        CefRefPtr[CefFileDialogCallback] cefCallback):
    cdef PyFileDialogCallback pyCallback = PyFileDialogCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback


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
                     file_dialog_callback = CreatePyFileDialogCallback(cefFileDialogCallback))
            return bool(returnValue)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
    return False
