// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// CefListValue->SetXxxx() functions need first param to be be cast
// to (int) because GetSize() returns size_t and generates a warning
// when compiling on VS2008 for x64 platform. Issue reported here:
// https://github.com/cztomczak/cefpython/issues/165

#include "v8utils.h"
#include "javascript_callback.h"
#include "include/base/cef_logging.h"
#include "cefpython_app.h"
#include <sstream>

// ----------------------------------------------------------------------------
// V8 values to CEF values.
// ----------------------------------------------------------------------------

CefRefPtr<CefListValue> V8ValueListToCefListValue(
        const CefV8ValueList& v8List) {
    // typedef std::vector<CefRefPtr<CefV8Value> > CefV8ValueList;
    CefRefPtr<CefListValue> listValue = CefListValue::Create();
    for (CefV8ValueList::const_iterator it = v8List.begin(); it != v8List.end(); \
            ++it) {
        CefRefPtr<CefV8Value> v8Value = *it;
        V8ValueAppendToCefListValue(v8Value, listValue);
    }
    return listValue;
}

void V8ValueAppendToCefListValue(CefRefPtr<CefV8Value> v8Value,
                                 CefRefPtr<CefListValue> listValue,
                                 int nestingLevel) {
    if (!v8Value->IsValid()) {
        LOG(ERROR) << "[Renderer process] V8ValueAppendToCefListValue():"
                      " IsValid() failed";
        return;
    }
    if (nestingLevel > 8) {
        LOG(ERROR) << "[Renderer process] V8ValueAppendToCefListValue():"
                      " max nesting level (8) exceeded";
        return;
    }
    if (v8Value->IsUndefined() || v8Value->IsNull()) {
        listValue->SetNull((int)listValue->GetSize());
    } else if (v8Value->IsBool()) {
        listValue->SetBool((int)listValue->GetSize(), v8Value->GetBoolValue());
    } else if (v8Value->IsInt()) {
        listValue->SetInt((int)listValue->GetSize(), v8Value->GetIntValue());
    } else if (v8Value->IsUInt()) {
        uint32_t uint32_value = v8Value->GetUIntValue();
        CefRefPtr<CefBinaryValue> binaryValue = CefBinaryValue::Create(
            &uint32_value, sizeof(uint32_value));
        listValue->SetBinary((int)listValue->GetSize(), binaryValue);
    } else if (v8Value->IsDouble()) {
        listValue->SetDouble((int)listValue->GetSize(),
                             v8Value->GetDoubleValue());
    } else if (v8Value->IsDate()) {
        // TODO: in time_utils.pyx there are already functions for
        // converting cef_time_t to python DateTime, we could easily
        // add a new function for converting the python DateTime to
        // string and then to CefString and expose the function using
        // the "public" keyword. But how do we get the cef_time_t
        // structure from the CefTime class? GetDateValue() returns
        // CefTime class.
        listValue->SetNull((int)listValue->GetSize());
    } else if (v8Value->IsString()) {
        listValue->SetString((int)listValue->GetSize(), v8Value->GetStringValue());
    } else if (v8Value->IsArray()) {
        // Check for IsArray() must happen before the IsObject() check.
        int length = v8Value->GetArrayLength();
        CefRefPtr<CefListValue> newListValue = CefListValue::Create();
        for (int i = 0; i < length; ++i) {
            V8ValueAppendToCefListValue(v8Value->GetValue(i), newListValue,
                    nestingLevel + 1);
        }
        listValue->SetList((int)listValue->GetSize(), newListValue);
    } else if (v8Value->IsFunction()) {
        // Check for IsFunction() must happen before the IsObject() check.
        if (CefV8Context::InContext()) {
            CefRefPtr<CefV8Context> context = \
                    CefV8Context::GetCurrentContext();
            CefRefPtr<CefFrame> frame = context->GetFrame();
            std::string strCallbackId = PutJavascriptCallback(frame, v8Value);
            /* strCallbackId = '####cefpython####' \
                               '{"what"=>"javascript-callback", ..}' */
            listValue->SetString((int)listValue->GetSize(), strCallbackId);
        } else {
            listValue->SetNull((int)listValue->GetSize());
            LOG(ERROR) << "[Renderer process] V8ValueAppendToCefListValue():"
                          " not in V8 context";
            return;
        }
    } else if (v8Value->IsObject()) {
        // Check for IsObject() must happen after the IsArray()
        // and IsFunction() checks.
        listValue->SetDictionary((int)listValue->GetSize(),
                V8ObjectToCefDictionaryValue(v8Value, nestingLevel + 1));
    } else {
        listValue->SetNull((int)listValue->GetSize());
        LOG(ERROR) << "[Renderer process] V8ValueAppendToCefListValue():"
                      " unknown V8 type";
    }
}

CefRefPtr<CefDictionaryValue> V8ObjectToCefDictionaryValue(
                                    CefRefPtr<CefV8Value> v8Object,
                                    int nestingLevel) {
    if (!v8Object->IsValid()) {
        LOG(ERROR) << "[Renderer process] V8ObjectToCefDictionaryValue():"
                      " IsValid() failed";
        return CefDictionaryValue::Create();
    }
    if (nestingLevel > 8) {
        LOG(ERROR) << "[Renderer process] V8ObjectToCefDictionaryValue():"
                      " max nesting level (8) exceeded";
        return CefDictionaryValue::Create();
    }
    if (!v8Object->IsObject()) {
        LOG(ERROR) << "[Renderer process] V8ObjectToCefDictionaryValue():"
                      " IsObject() failed";
        return CefDictionaryValue::Create();
    }
    CefRefPtr<CefDictionaryValue> ret = CefDictionaryValue::Create();
    std::vector<CefString> keys;
    if (!v8Object->GetKeys(keys)) {
        LOG(ERROR) << "[Renderer process] V8ObjectToCefDictionaryValue():"
                      " GetKeys() failed";
        return ret;
    }
    for (std::vector<CefString>::iterator it = keys.begin(); \
            it != keys.end(); ++it) {
        CefString key = *it;
        CefRefPtr<CefV8Value> v8Value = v8Object->GetValue(key);
        if (v8Value->IsUndefined() || v8Value->IsNull()) {
            ret->SetNull(key);
        } else if (v8Value->IsBool()) {
            ret->SetBool(key, v8Value->GetBoolValue());
        } else if (v8Value->IsInt()) {
            ret->SetInt(key, v8Value->GetIntValue());
        } else if (v8Value->IsUInt()) {
            uint32_t uint32_value = v8Value->GetUIntValue();
            CefRefPtr<CefBinaryValue> binaryValue = CefBinaryValue::Create(
                &uint32_value, sizeof(uint32_value));
            ret->SetBinary(key, binaryValue);
        } else if (v8Value->IsDouble()) {
            ret->SetDouble(key, v8Value->GetDoubleValue());
        } else if (v8Value->IsDate()) {
            // TODO: in time_utils.pyx there are already functions for
            // converting cef_time_t to python DateTime, we could easily
            // add a new function for converting the python DateTime to
            // string and then to CefString and expose the function using
            // the "public" keyword. But how do we get the cef_time_t
            // structure from the CefTime class? GetDateValue() returns
            // CefTime class.
            ret->SetNull(key);
        } else if (v8Value->IsString()) {
            ret->SetString(key, v8Value->GetStringValue());
        } else if (v8Value->IsArray()) {
            // Check for IsArray() must happen before the IsObject() check.
            int length = v8Value->GetArrayLength();
            CefRefPtr<CefListValue> newListValue = CefListValue::Create();
            for (int i = 0; i < length; ++i) {
                V8ValueAppendToCefListValue(v8Value->GetValue(i), newListValue,
                        nestingLevel + 1);
            }
            ret->SetList(key, newListValue);
        } else if (v8Value->IsFunction()) {
            // Check for IsFunction() must happen before the IsObject() check.
            if (CefV8Context::InContext()) {
                CefRefPtr<CefV8Context> context = \
                        CefV8Context::GetCurrentContext();
                CefRefPtr<CefFrame> frame = context->GetFrame();
                std::string strCallbackId = PutJavascriptCallback(
                        frame, v8Value);
                /* strCallbackId = '####cefpython####' \
                                   '{"what"=>"javascript-callback", ..}' */
                ret->SetString(key, strCallbackId);
            } else {
                ret->SetNull(key);
                LOG(ERROR) << "[Renderer process]"
                              " V8ObjectToCefDictionaryValue():"
                              " not in V8 context";
            }
        } else if (v8Value->IsObject()) {
            // Check for IsObject() must happen after the IsArray()
            // and IsFunction() checks.
            ret->SetDictionary(key,
                    V8ObjectToCefDictionaryValue(v8Value, nestingLevel + 1));
        } else {
            ret->SetNull(key);
            LOG(ERROR) << "[Renderer process] V8ObjectToCefDictionaryValue():"
                          " unknown V8 type";
        }
    }
    return ret;
}

// ----------------------------------------------------------------------------
// CEF values to V8 values.
// ----------------------------------------------------------------------------

// TODO: send callbackId using CefBinaryNamedValue, see:
// http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10881
struct PythonCallback {
    int callbackId;
    char uniqueCefBinaryValueSize[16];
};

template<typename T>
inline std::string AnyToString(const T& value)
{
    std::ostringstream oss;
    oss << value;
    return oss.str();
}

CefV8ValueList CefListValueToCefV8ValueList(
        CefRefPtr<CefListValue> listValue) {
    // CefV8ValueList = typedef std::vector<CefRefPtr<CefV8Value> >
    CefV8ValueList v8ValueVector;
    CefRefPtr<CefV8Value> v8List = CefListValueToV8Value(listValue);
    int v8ListLength = v8List->GetArrayLength();
    for (int i = 0; i < v8ListLength; ++i) {
        v8ValueVector.push_back(v8List->GetValue(i));
    }
    return v8ValueVector;
}

CefRefPtr<CefV8Value> CefListValueToV8Value(
        CefRefPtr<CefListValue> listValue,
        int nestingLevel) {
    if (!listValue->IsValid()) {
        LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                      " CefDictionaryValue is invalid";
        return CefV8Value::CreateNull();
    }
    if (nestingLevel > 8) {
        LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                      " max nesting level (8) exceeded";
        return CefV8Value::CreateNull();
    }
    int listSize = (int)listValue->GetSize();
    CefRefPtr<CefV8Value> ret = CefV8Value::CreateArray(listSize);
    CefRefPtr<CefBinaryValue> binaryValue;
    PythonCallback pyCallback;
    CefRefPtr<CefV8Handler> v8FunctionHandler;
    for (int key = 0; key < listSize; ++key) {
        cef_value_type_t valueType = listValue->GetType(key);
        bool success;
        std::string callbackName = "python_callback_";
        if (valueType == VTYPE_NULL) {
            success = ret->SetValue(key,
                    CefV8Value::CreateNull());
        } else if (valueType == VTYPE_BOOL) {
            success = ret->SetValue(key,
                    CefV8Value::CreateBool(listValue->GetBool(key)));
        } else if (valueType == VTYPE_INT) {
            success = ret->SetValue(key,
                    CefV8Value::CreateInt(listValue->GetInt(key)));
        } else if (valueType == VTYPE_DOUBLE) {
            success = ret->SetValue(key,
                    CefV8Value::CreateDouble(listValue->GetDouble(key)));
        } else if (valueType == VTYPE_STRING) {
            success = ret->SetValue(key,
                    CefV8Value::CreateString(listValue->GetString(key)));
        } else if (valueType == VTYPE_BINARY) {
            binaryValue = listValue->GetBinary(key);
            if (binaryValue->GetSize() == sizeof(pyCallback)) {
                binaryValue->GetData(&pyCallback, sizeof(pyCallback), 0);
                v8FunctionHandler = new V8FunctionHandler(
                        nullptr, pyCallback.callbackId);
                // You must provide a function name to
                // CefV8Value::CreateFunction(), otherwise it fails.
                callbackName.append(AnyToString(pyCallback.callbackId));
                success = ret->SetValue(key,
                                CefV8Value::CreateFunction(
                                        callbackName, v8FunctionHandler));
            } else {
                LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                              " unknown binary value, setting value to null";
                success = ret->SetValue(key, CefV8Value::CreateNull());
            }
        } else if (valueType == VTYPE_DICTIONARY) {
            success = ret->SetValue(key,
                    CefDictionaryValueToV8Value(
                            listValue->GetDictionary(key),
                            nestingLevel + 1));
        } else if (valueType == VTYPE_LIST) {
            success = ret->SetValue(key,
                    CefListValueToV8Value(
                            listValue->GetList(key),
                            nestingLevel + 1));
        } else {
            LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                          " unknown type, setting value to null";
            success = ret->SetValue(key,
                    CefV8Value::CreateNull());
        }
        if (!success) {
            LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                          " ret->SetValue() failed";
        }
    }
    return ret;
}

CefRefPtr<CefV8Value> CefDictionaryValueToV8Value(
        CefRefPtr<CefDictionaryValue> dictValue,
        int nestingLevel) {
    if (!dictValue->IsValid()) {
        LOG(ERROR) << "[Renderer process] CefDictionaryValueToV8Value():"
                      " CefDictionaryValue is invalid";
        return CefV8Value::CreateNull();
    }
    if (nestingLevel > 8) {
        LOG(ERROR) << "[Renderer process] CefDictionaryValueToV8Value():"
                      " max nesting level (8) exceeded";
        return CefV8Value::CreateNull();
    }
    std::vector<CefString> keys;
    if (!dictValue->GetKeys(keys)) {
        LOG(ERROR) << "[Renderer process] CefDictionaryValueToV8Value():"
                      " dictValue->GetKeys() failed";
        return CefV8Value::CreateNull();
    }
    CefRefPtr<CefV8Value> ret = CefV8Value::CreateObject(nullptr, nullptr);
    CefRefPtr<CefBinaryValue> binaryValue;
    PythonCallback pyCallback;
    CefRefPtr<CefV8Handler> v8FunctionHandler;
    for (std::vector<CefString>::iterator it = keys.begin(); \
            it != keys.end(); ++it) {
        CefString key = *it;
        cef_value_type_t valueType = dictValue->GetType(key);
        bool success;
        std::string callbackName = "python_callback_";
        if (valueType == VTYPE_NULL) {
            success = ret->SetValue(key,
                    CefV8Value::CreateNull(),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_BOOL) {
            success = ret->SetValue(key,
                    CefV8Value::CreateBool(dictValue->GetBool(key)),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_INT) {
            success = ret->SetValue(key,
                    CefV8Value::CreateInt(dictValue->GetInt(key)),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_DOUBLE) {
            success = ret->SetValue(key,
                    CefV8Value::CreateDouble(dictValue->GetDouble(key)),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_STRING) {
            success = ret->SetValue(key,
                    CefV8Value::CreateString(dictValue->GetString(key)),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_BINARY) {
            binaryValue = dictValue->GetBinary(key);
            if (binaryValue->GetSize() == sizeof(pyCallback)) {
                binaryValue->GetData(&pyCallback, sizeof(pyCallback), 0);
                v8FunctionHandler = new V8FunctionHandler(
                        nullptr, pyCallback.callbackId);
                // You must provide a function name to
                // CefV8Value::CreateFunction(), otherwise it fails.
                callbackName.append(AnyToString(pyCallback.callbackId));
                success = ret->SetValue(key,
                                CefV8Value::CreateFunction(
                                        callbackName, v8FunctionHandler),
                                V8_PROPERTY_ATTRIBUTE_NONE);
            } else {
                LOG(ERROR) << "[Renderer process] CefListValueToV8Value():"
                              " unknown binary value, setting value to null";
                success = ret->SetValue(key,
                        CefV8Value::CreateNull(),
                        V8_PROPERTY_ATTRIBUTE_NONE);
            }
        } else if (valueType == VTYPE_DICTIONARY) {
            success = ret->SetValue(key,
                    CefDictionaryValueToV8Value(
                            dictValue->GetDictionary(key),
                            nestingLevel + 1),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else if (valueType == VTYPE_LIST) {
            success = ret->SetValue(key,
                    CefListValueToV8Value(
                            dictValue->GetList(key),
                            nestingLevel + 1),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        } else {
            LOG(ERROR) << "[Renderer process] CefDictionaryValueToV8Value():"
                          " unknown type, setting value to null";
            success = ret->SetValue(key,
                    CefV8Value::CreateNull(),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        }
        if (!success) {
            LOG(ERROR) << "[Renderer process] CefDictionaryValueToV8Value():"
                          " ret->SetValue() failed";
        }
    }
    return ret;
}
