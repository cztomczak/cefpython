# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"

cdef PyFileDialogCallback CreatePyFileDialogCallback(
        CefRefPtr[CefFileDialogCallback] cefCallback):
    cdef PyFileDialogCallback pyCallback = PyFileDialogCallback()
    pyCallback.cefCallback = cefCallback
    return pyCallback

cdef class PyFileDialogCallback:
    cdef CefRefPtr[CefFileDialogCallback] cefCallback

    cpdef py_void Continue(self,int selected_accept_filter,list file_paths):

        cdef cpp_vector[CefString] filePaths

        for f in file_paths:
            filePaths.push_back(PyToCefStringValue(f))

        self.cefCallback.get().Continue(selected_accept_filter,filePaths)

    cpdef py_void Cancel(self):
        self.cefCallback.get().Cancel()

cdef public cpp_bool DragHandler_OnDragEnter(CefRefPtr[CefBrowser] cef_browser,
                                        CefRefPtr[CefDragData] cef_drag_data,
                                        uint32 mask
                                    ) except * with gil:

    cdef PyBrowser pyBrowser
    cdef DragData drag_data

    cdef py_bool returnValue
    try:
        pyBrowser = GetPyBrowser(cef_browser, "OnDragEnter")
        drag_data = DragData_Init(cef_drag_data)


        callback = pyBrowser.GetClientCallback("OnDragEnter")
        if callback:
            returnValue = callback(browser=pyBrowser,
                     dragData=drag_data,
                     mask=mask)


            return bool(returnValue)

    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

    return False






