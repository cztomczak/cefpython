# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

# noinspection PyUnresolvedReferences
from cef_types cimport ReferrerPolicy
# noinspection PyUnresolvedReferences
cimport cef_types

# cef_urlrequest_flags_t
UR_FLAG_NONE = cef_types.UR_FLAG_NONE
UR_FLAG_SKIP_CACHE = cef_types.UR_FLAG_SKIP_CACHE
UR_FLAG_ONLY_FROM_CACHE = cef_types.UR_FLAG_ONLY_FROM_CACHE
UR_FLAG_ALLOW_STORED_CREDENTIALS = cef_types.UR_FLAG_ALLOW_STORED_CREDENTIALS
UR_FLAG_REPORT_UPLOAD_PROGRESS = cef_types.UR_FLAG_REPORT_UPLOAD_PROGRESS
UR_FLAG_NO_DOWNLOAD_DATA = cef_types.UR_FLAG_NO_DOWNLOAD_DATA
UR_FLAG_NO_RETRY_ON_5XX = cef_types.UR_FLAG_NO_RETRY_ON_5XX
UR_FLAG_STOP_ON_REDIRECT = cef_types.UR_FLAG_STOP_ON_REDIRECT

# cef_referrer_policy_t
REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_FROM_SECURE_TO_INSECURE = cef_types.REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_FROM_SECURE_TO_INSECURE
REFERRER_POLICY_DEFAULT = cef_types.REFERRER_POLICY_DEFAULT
REFERRER_POLICY_REDUCE_REFERRER_GRANULARITY_ON_TRANSITION_CROSS_ORIGIN = cef_types.REFERRER_POLICY_REDUCE_REFERRER_GRANULARITY_ON_TRANSITION_CROSS_ORIGIN
REFERRER_POLICY_ORIGIN_ONLY_ON_TRANSITION_CROSS_ORIGIN = cef_types.REFERRER_POLICY_ORIGIN_ONLY_ON_TRANSITION_CROSS_ORIGIN
REFERRER_POLICY_NEVER_CLEAR_REFERRER = cef_types.REFERRER_POLICY_NEVER_CLEAR_REFERRER
REFERRER_POLICY_ORIGIN = cef_types.REFERRER_POLICY_ORIGIN
REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_CROSS_ORIGIN = cef_types.REFERRER_POLICY_CLEAR_REFERRER_ON_TRANSITION_CROSS_ORIGIN
REFERRER_POLICY_ORIGIN_CLEAR_ON_TRANSITION_FROM_SECURE_TO_INSECURE = cef_types.REFERRER_POLICY_ORIGIN_CLEAR_ON_TRANSITION_FROM_SECURE_TO_INSECURE
REFERRER_POLICY_NO_REFERRER = cef_types.REFERRER_POLICY_NO_REFERRER
REFERRER_POLICY_LAST_VALUE = cef_types.REFERRER_POLICY_LAST_VALUE

class Request:
    # TODO: autocomplete in PyCharm doesn't work for these flags
    Flags = {
        "None": cef_types.UR_FLAG_NONE,
        "SkipCache": cef_types.UR_FLAG_SKIP_CACHE,
        "OnlyFromCache": cef_types.UR_FLAG_ONLY_FROM_CACHE,
        "AllowCachedCredentials": 0, # keep dummy for BC
        "AllowStoredCredentials": cef_types.UR_FLAG_ALLOW_STORED_CREDENTIALS,
        "AllowCookies": 0, # keep dummy for BC
        "ReportUploadProgress": cef_types.UR_FLAG_REPORT_UPLOAD_PROGRESS,
        "ReportLoadTiming": 0, # keep dummy for BC
        "ReportRawHeaders": 0, # keep dummy for BC
        "NoDownloadData": cef_types.UR_FLAG_NO_DOWNLOAD_DATA,
        "NoRetryOn5xx": cef_types.UR_FLAG_NO_RETRY_ON_5XX,
        "StopOnRedirect": cef_types.UR_FLAG_STOP_ON_REDIRECT,
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
        if self.cefRequest and self.cefRequest.get():
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

    cpdef py_void SetReferrer(self, py_string referrer_url, cef_types.cef_referrer_policy_t policy):
        cdef CefString cefReferrerUrl
        PyToCefString(referrer_url, cefReferrerUrl)
        self.GetCefRequest().get().SetReferrer(cefReferrerUrl, policy)

    cpdef str GetReferrerURL(self):
        return CefToPyString(self.GetCefRequest().get().GetReferrerURL())

    cpdef cef_types.cef_referrer_policy_t GetReferrerPolicy(self):
        cdef cef_types.cef_referrer_policy_t rp
        rp = <cef_types.cef_referrer_policy_t>self.GetCefRequest().get().GetReferrerPolicy()
        return rp

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
        cdef bytes pyData
        cdef size_t bytesCount
        cdef void* voidData
        cdef bytes pyFile
        while iterator != elementVector.end():
            postDataElement = deref(iterator)
            if postDataElement.get().GetType() == cef_types.PDE_TYPE_EMPTY:
                # May return an empty dict - retUrlEncoded.
                pass
            elif postDataElement.get().GetType() == cef_types.PDE_TYPE_BYTES:
                bytesCount = postDataElement.get().GetBytesCount()
                voidData = <void*>malloc(bytesCount)
                postDataElement.get().GetBytes(bytesCount, voidData)
                pyData = VoidPtrToBytes(voidData, bytesCount)
                free(voidData)
                if pyData.startswith(b'--') or retMultipart:
                    # Content-Type: multipart/form-data
                    retMultipart.append(pyData)
                else:
                    # Content-Type: application/x-www-form-urlencoded
                    quoted = urlparse_quote(pyData, safe="=")
                    retUrlEncoded.update(urlparse.parse_qsl(qs=quoted,
                            keep_blank_values=True))
                    if PY_MAJOR_VERSION >= 3:
                        retUrlEncoded_copy = copy.deepcopy(retUrlEncoded)
                        retUrlEncoded = dict()
                        for key in retUrlEncoded_copy:
                            retUrlEncoded[key.encode("utf-8", "replace")] =\
                                    retUrlEncoded_copy[key].encode(
                                                    "utf-8", "replace")
            elif postDataElement.get().GetType() == cef_types.PDE_TYPE_FILE:
                pyFile = CefToPyBytes(postDataElement.get().GetFile())
                retMultipart.append(b"@"+pyFile)
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
        cdef bytes pyElement
        cdef CefString sfile
        if type(pyPostData) == list:
            for pyElement in pyPostData:
                if pyElement.startswith(b'--'):
                    postDataElement = CefPostDataElement_Create()
                    postDataElement.get().SetToBytes(len(pyElement), 
                            <char*>pyElement)
                elif pyElement.startswith(b'@'):
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
            pyElement = urllib_urlencode(pyPostData).encode("utf-8", "replace")
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
