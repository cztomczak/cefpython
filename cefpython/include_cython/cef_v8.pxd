# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_ptr cimport CefRefPtr
from libcpp.vector cimport vector as c_vector
from cef_browser cimport CefBrowser
from cef_frame cimport CefFrame
from cef_string cimport CefString
from cef_base cimport CefBase
from libcpp cimport bool as c_bool
cimport cef_types

cdef extern from "include/cef_v8.h":

    cdef cppclass CefV8Context(CefBase):

        CefRefPtr[CefV8Value] GetGlobal()
        CefRefPtr[CefBrowser] GetBrowser()
        CefRefPtr[CefFrame] GetFrame()
        c_bool Enter()
        c_bool Exit()
        c_bool IsSame(CefRefPtr[CefV8Context] that)

    ctypedef c_vector[CefRefPtr[CefV8Value]] CefV8ValueList

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
        c_bool GetBoolValue()
        double GetDoubleValue()
        CefString GetFunctionName()
        int GetIntValue()
        unsigned int GetUIntValue()
        c_bool GetKeys(c_vector[CefString]& keys)
        CefString GetStringValue()

        CefRefPtr[CefV8Value] GetValue(CefString& key) # object's property by key
        CefRefPtr[CefV8Value] GetValue(int index) # arrays index value

        c_bool HasValue(CefString& key)
        c_bool HasValue(int index)

        c_bool SetValue(CefString& key, CefRefPtr[CefV8Value] value, cef_types.cef_v8_propertyattribute_t attribute)
        c_bool SetValue(int index, CefRefPtr[CefV8Value] value)

        c_bool IsArray()
        c_bool IsBool()
        c_bool IsDate()
        c_bool IsDouble()
        c_bool IsFunction()
        c_bool IsInt()
        c_bool IsUInt()
        c_bool IsNull()
        c_bool IsObject()
        c_bool IsString()
        c_bool IsUndefined()

        c_bool HasException()
        CefRefPtr[CefV8Exception] GetException()
        c_bool ClearException()

    cdef cppclass CefV8StackTrace(CefBase):

        int GetFrameCount()
        CefRefPtr[CefV8StackFrame] GetFrame(int index)

    cdef cppclass CefV8StackFrame(CefBase):

        CefString GetScriptName()
        CefString GetScriptNameOrSourceURL()
        CefString GetFunctionName()
        int GetLineNumber()
        int GetColumn()
        c_bool IsEval()
        c_bool IsConstructor()

