# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase
from cef_ptr cimport CefRefPtr
from cef_string cimport CefString
from cef_types cimport cef_weburlrequest_flags_t, cef_postdataelement_type_t
from libcpp.vector cimport vector as cpp_vector
from libcpp cimport bool as cpp_bool
from multimap cimport multimap as cpp_multimap

cdef extern from "include/cef_request.h":
    # This types won't be visible in pyx files!
    ctypedef cpp_multimap[CefString, CefString] HeaderMap
    ctypedef cef_weburlrequest_flags_t CefRequestFlags

    cdef CefRefPtr[CefRequest] CefRequest_Create "CefRequest::CreateRequest"()
    cdef cppclass CefRequest(CefBase):
        CefString GetURL()
        void SetURL(CefString& url)
        CefString GetMethod()
        void SetMethod(CefString& method)
        CefRefPtr[CefPostData] GetPostData()
        void SetPostData(CefRefPtr[CefPostData] postData)
        void GetHeaderMap(HeaderMap& headerMap)
        void SetHeaderMap(HeaderMap& headerMap)
        void Set(CefString& url,
                CefString& method,
                CefRefPtr[CefPostData] postData,
                HeaderMap& headerMap)
        CefRequestFlags GetFlags()
        void SetFlags(CefRequestFlags flags)
        CefString GetFirstPartyForCookies()
        void SetFirstPartyForCookies(CefString& url)

    ctypedef cpp_vector[CefRefPtr[CefPostDataElement]] ElementVector

    cdef CefRefPtr[CefPostData] CefPostData_Create \
            "CefPostData::CreatePostData"()
    cdef cppclass CefPostData(CefBase):
        size_t GetElementCount()
        void GetElements(ElementVector& elements)
        cpp_bool RemoveElement(CefRefPtr[CefPostDataElement] element)
        cpp_bool AddElement(CefRefPtr[CefPostDataElement] element)
        void RemoveElements()

    ctypedef cef_postdataelement_type_t ElementType

    cdef CefRefPtr[CefPostDataElement] CefPostDataElement_Create \
            "CefPostDataElement::CreatePostDataElement"()
    cdef cppclass CefPostDataElement(CefBase):
        void SetToEmpty()
        void SetToFile(CefString& fileName)
        void SetToBytes(size_t size, void* bytes)
        ElementType GetType()
        CefString GetFile()
        size_t GetBytesCount()
        size_t GetBytes(size_t size, void* bytes)
