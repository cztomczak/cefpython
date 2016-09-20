# Copyright (c) 2016 The CEF Python authors. All rights reserved.

include "cefpython.pyx"

cdef DragData_Init(CefRefPtr[CefDragData] cef_drag_data):
    cdef DragData drag_data = DragData()
    drag_data.cef_drag_data = cef_drag_data
    return drag_data

cdef class DragData:
    cdef CefRefPtr[CefDragData] cef_drag_data

    def __init__(self):
        self.cef_drag_data = CefDragData_Create()
        self.cef_drag_data.get().SetFragmentText(PyToCefStringValue("none"))
        self.cef_drag_data.get().SetFragmentHtml(PyToCefStringValue("none"))
        self.cef_drag_data.get().SetFragmentBaseURL(PyToCefStringValue(""))

    cpdef py_bool IsLink(self):
        return self.cef_drag_data.get().IsLink()

    cpdef py_bool IsFragment(self):
        return self.cef_drag_data.get().IsFragment()

    cpdef py_string GetLinkUrl(self):
        return CefToPyString(self.cef_drag_data.get().GetLinkURL())

    cpdef py_string GetLinkTitle(self):
        return CefToPyString(self.cef_drag_data.get().GetLinkTitle())

    cpdef py_string GetFragmentText(self):
        return CefToPyString(self.cef_drag_data.get().GetFragmentText())

    cpdef py_string GetFragmentHtml(self):
        return CefToPyString(self.cef_drag_data.get().GetFragmentHtml())

    cpdef PyImage GetImage(self):
        cdef CefRefPtr[CefImage] cef_image =\
                self.cef_drag_data.get().GetImage()
        if not cef_image.get():
            raise Exception("Image is not available")
        return PyImage_Init(cef_image)

    cpdef py_bool HasImage(self):
        return self.cef_drag_data.get().HasImage()
