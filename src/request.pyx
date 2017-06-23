# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class Request:
    Flags = {
        "None": cef_types.UR_FLAG_NONE,
        "SkipCache": cef_types.UR_FLAG_SKIP_CACHE,
        "AllowCachedCredentials": cef_types.UR_FLAG_ALLOW_CACHED_CREDENTIALS,
        "AllowCookies": 0, # keep for BC
        "ReportUploadProgress": cef_types.UR_FLAG_REPORT_UPLOAD_PROGRESS,
        "ReportLoadTiming": 0, # keep for BC
        "ReportRawHeaders": 0, # keep for BC
        "NoDownloadData": cef_types.UR_FLAG_NO_DOWNLOAD_DATA,
        "NoRetryOn5xx": cef_types.UR_FLAG_NO_RETRY_ON_5XX,
    }
    
    def __init__(self):
        # Request object is just a public API wrapper, 
        # the real Request object is named PyRequest.
        raise Exception("Request object cannot be instantiated directly, "
                "use static method Request.CreateRequest()")

    @staticmethod
    def CreateRequest():
        cdef CefRefPtr[CefRequest] cefRequest = CefRequest_Create()
        cdef PyRequest pyRequest = CreatePyRequest(cefRequest)
        return pyRequest

cdef PyRequest CreatePyRequest(CefRefPtr[CefRequest] cefRequest):
    # This can't be named "GetPyRequest()" as CefRequest has
    # no unique identifier, so each time a different python object
    # must be returned.
    cdef PyRequest pyRequest = PyRequest()
    pyRequest.cefRequest = cefRequest
    return pyRequest

cdef class PyRequest:
    cdef CefRefPtr[CefRequest] cefRequest

    cdef CefRefPtr[CefRequest] GetCefRequest(self) except *:
        if <void*>self.cefRequest != NULL and self.cefRequest.get():
            return self.cefRequest
        raise Exception("PyRequest.GetCefRequest() failed: "
                        "CefRequest was destroyed")

    cpdef str GetUrl(self):
        return CefToPyString(self.GetCefRequest().get().GetURL())

    cpdef py_void SetUrl(self, py_string url):
        cdef CefString cefUrl
        PyToCefString(url, cefUrl)
        self.GetCefRequest().get().SetURL(cefUrl)

    cpdef str GetMethod(self):
        return CefToPyString(self.GetCefRequest().get().GetMethod())

    cpdef py_void SetMethod(self, py_string method):
        cdef CefString cefMethod
        PyToCefString(method, cefMethod)
        self.GetCefRequest().get().SetMethod(cefMethod)

    cpdef object GetPostData(self):
        if self.GetMethod() != "POST":
            return {}
        cdef cpp_vector[CefRefPtr[CefPostDataElement]] elementVector
        cdef CefRefPtr[CefPostData] postData = (
                self.GetCefRequest().get().GetPostData())
        if postData.get() == NULL:
            return {}
        if postData.get().GetElementCount() == 0:
            return {}
        postData.get().GetElements(elementVector)
        cdef cpp_vector[CefRefPtr[CefPostDataElement]].iterator iterator = (
                elementVector.begin())
        cdef CefRefPtr[CefPostDataElement] postDataElement
        cdef list retMultipart = []
        cdef dict retUrlEncoded = {}
        # pyData is really of type "str", but Cython will throw
        # an error if we use that type: "Cannot convert 'bytes'
        # object to str implicitly. This is not portable to Py3."
        cdef object pyData 
        cdef size_t bytesCount
        cdef void* voidData
        cdef str pyFile
        while iterator != elementVector.end():
            postDataElement = deref(iterator)
            if postDataElement.get().GetType() == cef_types.PDE_TYPE_EMPTY:
                # May return an empty dict - retUrlEncoded.
                pass
            elif postDataElement.get().GetType() == cef_types.PDE_TYPE_BYTES:
                bytesCount = postDataElement.get().GetBytesCount()
                voidData = <void*>malloc(bytesCount)
                postDataElement.get().GetBytes(bytesCount, voidData)
                pyData = VoidPtrToString(voidData, bytesCount)
                free(voidData)
                if pyData.startswith('--') or retMultipart:
                    # Content-Type: multipart/form-data
                    retMultipart.append(pyData)
                else:
                    # Content-Type: application/x-www-form-urlencoded
                    retUrlEncoded.update(urlparse.parse_qsl(qs=pyData, 
                            keep_blank_values=True))
            elif postDataElement.get().GetType() == cef_types.PDE_TYPE_FILE:
                pyFile = CefToPyString(postDataElement.get().GetFile())
                retMultipart.append("@"+pyFile)
            else:
                raise Exception("Invalid type of CefPostDataElement")
            preinc(iterator)
        if retMultipart:
            return retMultipart
        else:
            return retUrlEncoded

    cpdef py_void SetPostData(self, object pyPostData):
        cdef CefRefPtr[CefPostData] postData = CefPostData_Create()
        cdef CefRefPtr[CefPostDataElement] postDataElement
        cdef py_string pyElement
        cdef CefString sfile
        if type(pyPostData) == list:
            for pyElement in pyPostData:
                if pyElement.startswith('--'):
                    postDataElement = CefPostDataElement_Create()
                    postDataElement.get().SetToBytes(len(pyElement), 
                            <char*>pyElement)
                elif pyElement.startswith('@'):
                    postDataElement = CefPostDataElement_Create()
                    PyToCefString(pyElement[1:], sfile)
                    postDataElement.get().SetToFile(sfile)
                elif not pyElement:
                    postDataElement = CefPostDataElement_Create()
                    postDataElement.get().SetToEmpty()
                else:
                    raise Exception("Invalid element in postData: %s" % (
                            pyElement))
                postData.get().AddElement(postDataElement)
            self.GetCefRequest().get().SetPostData(postData)
        elif type(pyPostData) == dict:
            pyElement = urllib.urlencode(pyPostData)
            pyElement = str(pyElement)
            postDataElement = CefPostDataElement_Create()
            postDataElement.get().SetToBytes(len(pyElement), <char*>pyElement)
            postData.get().AddElement(postDataElement)
            self.GetCefRequest().get().SetPostData(postData)
        else:
            raise Exception("Invalid type of postData, only dict|list allowed")

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
        self.GetCefRequest().get().GetHeaderMap(cefHeaderMap)
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
        cpdef list headerMultimap = []
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
        self.GetCefRequest().get().SetHeaderMap(cefHeaderMap)

    cpdef int GetFlags(self) except *:
        return self.GetCefRequest().get().GetFlags()

    cpdef py_void SetFlags(self, int flags):
        self.GetCefRequest().get().SetFlags(flags)

    cpdef str GetFirstPartyForCookies(self):
        return CefToPyString(
                self.GetCefRequest().get().GetFirstPartyForCookies())

    cpdef py_void SetFirstPartyForCookies(self, py_string url):
        self.GetCefRequest().get().SetFirstPartyForCookies(
                PyToCefStringValue(url))
