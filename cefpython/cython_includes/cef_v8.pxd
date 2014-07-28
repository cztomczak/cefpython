# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from libcpp.vector cimport vector as cpp_vector
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
from cef_string cimport CefString
from cef_base cimport CefBase
from libcpp cimport bool as cpp_bool
cimport cef_types

cdef extern from "include/cef_v8.h":

    cdef cppclass CefV8Context(CefBase):

        CefRefPtr[CefV8Value] GetGlobal()
        CefRefPtr[CefBrowser] GetBrowser()
        CefRefPtr[CefFrame] GetFrame()
        cpp_bool Enter()
        cpp_bool Exit()
        cpp_bool IsSame(CefRefPtr[CefV8Context] that)

    ctypedef cpp_vector[CefRefPtr[CefV8Value]] CefV8ValueList

    cdef cppclass CefV8Accessor(CefBase):
        pass

    cdef cppclass CefV8Handler(CefBase):
        pass

    cdef cppclass CefV8Exception(CefBase):

        int GetLineNumber()
        CefString GetMessage()
        CefString GetScriptResourceName()
        CefString GetSourceLine()

    cdef cppclass CefV8Value(CefBase):

        CefRefPtr[CefV8Value] ExecuteFunctionWithContext(
            CefRefPtr[CefV8Context] context,
                CefRefPtr[CefV8Value] object,
                CefV8ValueList& arguments)

        int GetArrayLength()
        cpp_bool GetBoolValue()
        double GetDoubleValue()
        CefString GetFunctionName()
        int GetIntValue()
        unsigned int GetUIntValue()
        cpp_bool GetKeys(cpp_vector[CefString]& keys)
        CefString GetStringValue()

        CefRefPtr[CefV8Value] GetValue(CefString& key) # object's property by key
        CefRefPtr[CefV8Value] GetValue(int index) # arrays index value

        cpp_bool HasValue(CefString& key)
        cpp_bool HasValue(int index)

        cpp_bool SetValue(CefString& key, CefRefPtr[CefV8Value] value, cef_types.cef_v8_propertyattribute_t attribute)
        cpp_bool SetValue(int index, CefRefPtr[CefV8Value] value)

        cpp_bool IsArray()
        cpp_bool IsBool()
        cpp_bool IsDate()
        cpp_bool IsDouble()
        cpp_bool IsFunction()
        cpp_bool IsInt()
        cpp_bool IsUInt()
        cpp_bool IsNull()
        cpp_bool IsObject()
        cpp_bool IsString()
        cpp_bool IsUndefined()

        cpp_bool HasException()
        CefRefPtr[CefV8Exception] GetException()
        cpp_bool ClearException()

    cdef cppclass CefV8StackTrace(CefBase):

        int GetFrameCount()
        CefRefPtr[CefV8StackFrame] GetFrame(int index)

    cdef cppclass CefV8StackFrame(CefBase):

        CefString GetScriptName()
        CefString GetScriptNameOrSourceURL()
        CefString GetFunctionName()
        int GetLineNumber()
        int GetColumn()
        cpp_bool IsEval()
        cpp_bool IsConstructor()

