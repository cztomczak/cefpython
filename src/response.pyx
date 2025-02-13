# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef PyResponse CreatePyResponse(CefRefPtr[CefResponse] cefResponse):
    cdef PyResponse pyResponse = PyResponse()
    pyResponse.cefResponse = cefResponse
    return pyResponse

cdef class PyResponse:
    cdef CefRefPtr[CefResponse] cefResponse

    cdef CefRefPtr[CefResponse] GetCefResponse(self
            ) except *:
        if self.cefResponse and self.cefResponse.get():
            return self.cefResponse
        raise Exception("CefResponse was destroyed, you cannot use this object anymore")

    cpdef py_bool IsReadOnly(self):
        return self.GetCefResponse().get().IsReadOnly()

    cpdef int GetStatus(self) except *:
        return self.GetCefResponse().get().GetStatus()

    cpdef py_void SetStatus(self, int status):
        assert type(status) == int, "Response.SetStatus() failed: status param is not an int"
        self.GetCefResponse().get().SetStatus(status)

    cpdef str GetStatusText(self):
        return CefToPyString(self.GetCefResponse().get().GetStatusText())

    cpdef py_void SetStatusText(self, py_string statusText):
        assert type(statusText) in (str, unicode, bytes), (
                "Response.SetStatusText() failed: statusText param is not a string")
        cdef CefString cefStatusText
        PyToCefString(statusText, cefStatusText)
        self.GetCefResponse().get().SetStatusText(cefStatusText)

    cpdef str GetMimeType(self):
        return CefToPyString(self.GetCefResponse().get().GetMimeType())

    cpdef py_void SetMimeType(self, py_string mimeType):
        assert type(mimeType) in (str, unicode, bytes), (
                "Response.SetMimeType() failed: mimeType param is not a string")
        cdef CefString cefMimeType
        PyToCefString(mimeType, cefMimeType)
        self.GetCefResponse().get().SetMimeType(cefMimeType)

    cpdef str GetHeaderByName(self, py_string name):
        assert type(name) in (str, unicode, bytes), (
                "Response.GetHeaderByName() failed: name param is not a string")
        cdef CefString cefName
        PyToCefString(name, cefName)
        return CefToPyString(self.GetCefResponse().get().GetHeaderByName(cefName))

    cpdef dict GetHeaderMap(self):
        cdef list headerMultimap = self.GetHeaderMultimap()
        cdef dict headerMap = {}
        cdef tuple headerTuple
        for headerTuple in headerMultimap:
            key = headerTuple[0]
            value = headerTuple[1]
            headerMap[key] = value
        return headerMap

    cpdef list GetHeaderMultimap(self):
        cdef cpp_multimap[CefString, CefString] cefHeaderMap
        self.GetCefResponse().get().GetHeaderMap(cefHeaderMap)
        cdef list pyHeaderMultimap = []
        cdef cpp_multimap[CefString, CefString].iterator iterator = (
                cefHeaderMap.begin())
        cdef CefString cefKey
        cdef CefString cefValue
        cdef str pyKey
        cdef str pyValue
        while iterator != cefHeaderMap.end():
            cefKey = deref(iterator).first
            cefValue = deref(iterator).second
            pyKey = CefToPyString(cefKey)
            pyValue = CefToPyString(cefValue)
            pyHeaderMultimap.append((pyKey, pyValue))
            preinc(iterator)
        return pyHeaderMultimap

    cpdef py_void SetHeaderMap(self, dict headerMap):
        assert len(headerMap) > 0, "headerMap param is empty"
        cdef list headerMultimap = []
        cdef object key
        for key in headerMap:
            headerMultimap.append((str(key), str(headerMap[key])))
        self.SetHeaderMultimap(headerMultimap)

    cpdef py_void SetHeaderMultimap(self, list headerMultimap):
        assert len(headerMultimap) > 0, "headerMultimap param is empty"
        cdef cpp_multimap[CefString, CefString] cefHeaderMap
        cdef CefString cefKey
        cdef CefString cefValue
        cdef cpp_pair[CefString, CefString] pair
        cdef tuple headerTuple
        for headerTuple in headerMultimap:
            PyToCefString(str(headerTuple[0]), cefKey)
            PyToCefString(str(headerTuple[1]), cefValue)
            pair.first, pair.second = cefKey, cefValue
            cefHeaderMap.insert(pair)
        self.GetCefResponse().get().SetHeaderMap(cefHeaderMap)
