# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from cef_string cimport CefString
# noinspection PyUnresolvedReferences
from cef_types cimport cef_urlrequest_flags_t, cef_postdataelement_type_t, cef_referrer_policy_t
# noinspection PyUnresolvedReferences
from libcpp.vector cimport vector as cpp_vector
from libcpp cimport bool as cpp_bool
# noinspection PyUnresolvedReferences
from multimap cimport multimap as cpp_multimap

cdef extern from "include/cef_request.h":
    # This types won't be visible in pyx files!
    ctypedef cpp_multimap[CefString, CefString] HeaderMap
    # ctypedef cef_urlrequest_flags_t CefRequestFlags
    ctypedef cef_referrer_policy_t ReferrerPolicy

    cdef CefRefPtr[CefRequest] CefRequest_Create "CefRequest::Create"()
    cdef cppclass CefRequest:
        cpp_bool IsReadOnly()
        CefString GetURL()
        void SetURL(CefString& url)
        CefString GetMethod()
        void SetMethod(CefString& method)
        void SetReferrer(CefString& referrer_url, ReferrerPolicy& policy)
        CefString GetReferrerURL()
        ReferrerPolicy GetReferrerPolicy()
        CefRefPtr[CefPostData] GetPostData()
        void SetPostData(CefRefPtr[CefPostData] postData)
        void GetHeaderMap(HeaderMap& headerMap)
        void SetHeaderMap(HeaderMap& headerMap)
        void Set(CefString& url,
                CefString& method,
                CefRefPtr[CefPostData] postData,
                HeaderMap& headerMap)
        int GetFlags()
        void SetFlags(int flags)
        CefString GetFirstPartyForCookies()
        void SetFirstPartyForCookies(CefString& url)

    # noinspection PyUnresolvedReferences
    ctypedef cpp_vector[CefRefPtr[CefPostDataElement]] ElementVector

    cdef CefRefPtr[CefPostData] CefPostData_Create \
            "CefPostData::Create"()
    cdef cppclass CefPostData:
        cpp_bool IsReadOnly()
        size_t GetElementCount()
        void GetElements(ElementVector& elements)
        cpp_bool RemoveElement(CefRefPtr[CefPostDataElement] element)
        cpp_bool AddElement(CefRefPtr[CefPostDataElement] element)
        void RemoveElements()

    # noinspection PyUnresolvedReferences
    ctypedef cef_postdataelement_type_t ElementType

    @staticmethod
    cdef CefRefPtr[CefPostDataElement] CefPostDataElement_Create \
            "CefPostDataElement::Create"()
    cdef cppclass CefPostDataElement:
        cpp_bool IsReadOnly()
        void SetToEmpty()
        void SetToFile(CefString& fileName)
        void SetToBytes(size_t size, void* bytes_)
        ElementType GetType()
        CefString GetFile()
        size_t GetBytesCount()
        size_t GetBytes(size_t size, void* bytes_)
