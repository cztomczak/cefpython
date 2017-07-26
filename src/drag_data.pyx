# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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

    cpdef py_bool IsFile(self):
        return self.cef_drag_data.get().IsFile()

    cpdef py_string GetFileName(self):
        return CefToPyString(self.cef_drag_data.get().GetFileName())

    cpdef list GetFileNames(self):
        cdef cpp_vector[CefString] cefNames
        self.cef_drag_data.get().GetFileNames(cefNames)
        cdef list names = []
        cdef cpp_vector[CefString].iterator iterator = cefNames.begin()
        cdef CefString cefString
        while iterator != cefNames.end():
            cefString = deref(iterator)
            names.append(CefToPyString(cefString))
            preinc(iterator)
        return names

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

    cpdef py_void SetFragmentText(self, text):
        cdef CefString cefText
        PyToCefString(text, cefText)
        self.cef_drag_data.get().SetFragmentText(cefText)

    cpdef py_void SetFragmentHtml(self, html):
        cdef CefString cefHtml
        PyToCefString(html, cefHtml)
        self.cef_drag_data.get().SetFragmentHtml(cefHtml)

    cpdef py_void AddFile(self, path, display_name):
        cdef CefString cefPath
        cdef CefString cefDisplayName
        PyToCefString(path, cefPath)
        PyToCefString(display_name, cefDisplayName)
        self.cef_drag_data.get().AddFile(cefPath, cefDisplayName)

    cpdef py_void ResetFileContents(self):
        self.cef_drag_data.get().ResetFileContents()

    IF UNAME_SYSNAME == "Linux":

        cpdef PyImage GetImage(self):
            cdef CefRefPtr[CefImage] cef_image =\
                    self.cef_drag_data.get().GetImage()
            if not cef_image.get():
                raise Exception("Image is not available")
            return PyImage_Init(cef_image)

        cpdef tuple GetImageHotspot(self):
            cdef CefPoint point = self.cef_drag_data.get().GetImageHotspot()
            return (point.x, point.y)

        cpdef py_bool HasImage(self):
            return self.cef_drag_data.get().HasImage()

    # END IF UNAME_SYSNAME == "Linux":
