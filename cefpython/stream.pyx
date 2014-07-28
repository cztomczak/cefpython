# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef class PyStreamReader:
    cdef CefRefPtr[CefStreamReader] cefStreamReader
    
    cdef cpp_bool HasCefStreamReader(self) except *:
        if <void*>self.cefStreamReader != NULL and self.cefStreamReader.get():
            return True
        return False

    cdef CefRefPtr[CefStreamReader] GetCefStreamReader(self) except *:
        if self.HasCefStreamReader():
            return self.cefStreamReader
        return <CefRefPtr[CefStreamReader]>NULL

    cpdef py_void SetFile(self, py_string file):
        if os.path.exists(file):
            self.cefStreamReader = cef_stream_static.CreateForFile(
                    PyToCefStringValue(file))
        else:
            raise Exception("File does not exist: %s" % file)

    cpdef py_void SetData(self, py_string data):
        cdef cpp_string cppString = data
        # CreateForData() requires "void* data", we can't just pass
        # cppString.c_str() as it is const, we need to copy all data.
        cdef void* voidData
        cdef int dataLength = cppString.length()
        voidData = <void*>malloc(dataLength)
        memcpy(voidData, cppString.c_str(), dataLength)
        self.cefStreamReader = cef_stream_static.CreateForData(
                voidData, dataLength)
        free(voidData)
