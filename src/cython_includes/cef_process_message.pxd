# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_types cimport cef_process_id_t
from cef_ptr cimport CefRefPtr
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_values cimport CefListValue
from cef_types cimport cef_process_id_t

cdef extern from "include/cef_process_message.h":
    cdef CefRefPtr[CefProcessMessage] CefProcessMessage_Create \
            "CefProcessMessage::Create"(const CefString& name)
    cdef cppclass CefProcessMessage:
        cpp_bool IsValid()
        cpp_bool IsReadOnly()
        CefRefPtr[CefProcessMessage] Copy()
        CefString GetName()
        CefRefPtr[CefListValue] GetArgumentList()
    ctypedef cef_process_id_t CefProcessId
