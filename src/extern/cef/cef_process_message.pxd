# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# noinspection PyUnresolvedReferences
from cef_types cimport cef_process_id_t
from cef_ptr cimport CefRefPtr
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool
from cef_values cimport CefListValue

cdef extern from "include/cef_process_message.h":
    cdef CefRefPtr[CefProcessMessage] CefProcessMessage_Create \
            "CefProcessMessage::Create"(const CefString& name)
    cdef cppclass CefProcessMessage:
        cpp_bool IsValid()
        cpp_bool IsReadOnly()
        CefRefPtr[CefProcessMessage] Copy()
        CefString GetName()
        CefRefPtr[CefListValue] GetArgumentList()
    # noinspection PyUnresolvedReferences
    ctypedef cef_process_id_t CefProcessId
