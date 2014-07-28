# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef PyDragData CreatePyDragData(CefRefPtr[CefDragData] cefDragData):
    cdef PyDragData pyDragData = PyDragData()
    pyDragData.cefDragData = cefDragData
    return pyDragData

cdef class PyDragData:
    cdef CefRefPtr[CefDragData] cefDragData

    cpdef py_bool IsLink(self):
        return self.cefDragData.get().IsLink()

    cpdef py_bool IsFragment(self):
        return self.cefDragData.get().IsFragment()

    cpdef py_bool IsFile(self):
        return self.cefDragData.get().IsFile()

    cpdef str GetLinkUrl(self):
        return CefToPyString(self.cefDragData.get().GetLinkURL())

    cpdef str GetLinkTitle(self):
        return CefToPyString(self.cefDragData.get().GetLinkTitle())

    cpdef str GetLinkMetadata(self):
        return CefToPyString(self.cefDragData.get().GetLinkMetadata())

    cpdef str GetFragmentText(self):
        return CefToPyString(self.cefDragData.get().GetFragmentText())

    cpdef str GetFragmentHtml(self):
        return CefToPyString(self.cefDragData.get().GetFragmentHtml())

    cpdef str GetFragmentBaseUrl(self):
        return CefToPyString(self.cefDragData.get().GetFragmentBaseURL())

    cpdef str GetFile(self):
        return CefToPyString(self.cefDragData.get().GetFileName())

    cpdef list GetFiles(self):
        cdef cpp_vector[CefString] files
        cdef cpp_vector[CefString].iterator it
        cdef cpp_bool succeeded = self.cefDragData.get().GetFileNames(files)
        cdef CefString value
        cdef list ret = []
        if succeeded:
            it = files.begin()
            while it != files.end():
                value = deref(it)
                ret.append(CefToPyString(value))
                preinc(it)
            return ret
        else:
            return []
