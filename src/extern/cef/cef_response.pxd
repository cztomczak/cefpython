# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString
# noinspection PyUnresolvedReferences
from multimap cimport multimap as cpp_multimap
from libcpp cimport bool as cpp_bool
from cef_ptr cimport CefRefPtr

cdef extern from "include/cef_response.h":
    ctypedef cpp_multimap[CefString, CefString] CefResponseHeaderMap

    cdef CefRefPtr[CefResponse] CefResponse_Create "CefResponse::Create"()

    cdef cppclass CefResponse:
        cpp_bool IsReadOnly()
        int GetStatus()
        void SetStatus(int status)
        CefString GetStatusText()
        void SetStatusText(CefString& statusText)
        CefString GetMimeType()
        void SetMimeType(CefString& mimeType)
        CefString GetHeaderByName(CefString& name)
        void GetHeaderMap(CefResponseHeaderMap& headerMap)
        void SetHeaderMap(CefResponseHeaderMap& headerMap)
