# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_base cimport CefBase
from cef_string cimport CefString
from multimap cimport multimap as cpp_multimap

cdef extern from "include/cef_response.h":
    ctypedef cpp_multimap[CefString, CefString] CefResponseHeaderMap

    cdef cppclass CefResponse(CefBase):
        int GetStatus()
        void SetStatus(int status)
        CefString GetStatusText()
        void SetStatusText(CefString& statusText)
        CefString GetMimeType()
        void SetMimeType(CefString& mimeType)
        CefString GetHeader(CefString& name)
        void GetHeaderMap(CefResponseHeaderMap& headerMap)
        void SetHeaderMap(CefResponseHeaderMap& headerMap)

