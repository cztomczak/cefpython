# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_ptr cimport CefRefPtr
from libcpp cimport bool as cpp_bool
from cef_string cimport CefString
from libcpp.vector cimport vector
from cef_types cimport cef_value_type_t

cdef extern from "include/cef_values.h":
    @staticmethod
    cdef CefRefPtr[CefBinaryValue] CefBinaryValue_Create \
        "CefBinaryValue::Create"(const void* data, size_t data_size)

    cdef cppclass CefValue:
        cpp_bool IsValid()
        cpp_bool IsOwned()
        cpp_bool IsReadOnly()
        cef_value_type_t GetType()
        cpp_bool GetBool()
        int GetInt()
        double GetDouble()
        CefString GetString()
        CefRefPtr[CefBinaryValue] GetBinary()
        CefRefPtr[CefDictionaryValue] GetDictionary()
        CefRefPtr[CefListValue] GetList()

    cdef cppclass CefBinaryValue:
        cpp_bool IsValid()
        cpp_bool IsOwned()
        CefRefPtr[CefBinaryValue] Copy()
        size_t GetSize()
        size_t GetData(void* buffer_, size_t buffer_size, size_t data_offset)
    
    @staticmethod    
    cdef CefRefPtr[CefDictionaryValue] CefDictionaryValue_Create \
        "CefDictionaryValue::Create"()

    cdef cppclass CefDictionaryValue:
        cpp_bool IsValid()
        cpp_bool IsOwned()
        cpp_bool IsReadOnly()
        CefRefPtr[CefDictionaryValue] Copy(cpp_bool exclude_empty_children)
        size_t GetSize()
        cpp_bool Clear()
        cpp_bool HasKey(const CefString& key)
        cpp_bool GetKeys(vector[CefString]& keys)
        cpp_bool Remove(const CefString& key)
        cef_value_type_t GetType(const CefString& key)
        cpp_bool GetBool(const CefString& key)
        int GetInt(const CefString& key)
        double GetDouble(const CefString& key)
        CefString GetString(const CefString& key)
        CefRefPtr[CefBinaryValue] GetBinary(const CefString& key)
        CefRefPtr[CefDictionaryValue] GetDictionary(const CefString& key)
        CefRefPtr[CefListValue] GetList(const CefString& key)
        cpp_bool SetNull(const CefString& key)
        cpp_bool SetBool(const CefString& key, cpp_bool value)
        cpp_bool SetInt(const CefString& key, int value)
        cpp_bool SetDouble(const CefString& key, double value)
        cpp_bool SetString(const CefString& key, const CefString& value)
        cpp_bool SetBinary(const CefString& key, CefRefPtr[CefBinaryValue] value)
        cpp_bool SetDictionary(const CefString& key, CefRefPtr[CefDictionaryValue] value)
        cpp_bool SetList(const CefString& key, CefRefPtr[CefListValue] value)

    cdef CefRefPtr[CefListValue] CefListValue_Create "CefListValue::Create"()

    cdef cppclass CefListValue:
        cpp_bool IsValid()
        cpp_bool IsOwned()
        cpp_bool IsReadOnly()
        CefRefPtr[CefListValue] Copy()
        cpp_bool SetSize(size_t size)
        size_t GetSize()
        cpp_bool Clear()
        cpp_bool Remove(size_t index)
        cef_value_type_t GetType(size_t index)
        cpp_bool GetBool(size_t index)
        int GetInt(size_t index)
        double GetDouble(size_t index)
        CefString GetString(size_t index)
        CefRefPtr[CefBinaryValue] GetBinary(size_t index)
        CefRefPtr[CefDictionaryValue] GetDictionary(size_t index)
        CefRefPtr[CefListValue] GetList(size_t index)
        cpp_bool SetNull(size_t index)
        cpp_bool SetBool(size_t index, cpp_bool value)
        cpp_bool SetInt(size_t index, int value)
        cpp_bool SetDouble(size_t index, double value)
        cpp_bool SetString(size_t index, const CefString& value)
        cpp_bool SetBinary(size_t index, CefRefPtr[CefBinaryValue] value)
        cpp_bool SetDictionary(size_t index, CefRefPtr[CefDictionaryValue] value)
        cpp_bool SetList(size_t index, CefRefPtr[CefListValue] value)
