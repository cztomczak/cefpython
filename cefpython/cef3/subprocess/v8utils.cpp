// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "v8utils.h"

// Defined as "inline" to get rid of the "already defined" errors
// when linking.
inline void DebugLog(const char* szString)
{
  // TODO: get the log_file option from CefSettings.
  printf("cefpython: %s\n", szString);
  FILE* pFile = fopen("debug.log", "a");
  fprintf(pFile, "cefpython_app: %s\n", szString);
  fclose(pFile);
}

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

void V8ValueAppendToCefListValue(const CefRefPtr<CefV8Value> v8Value, 
                                 CefRefPtr<CefListValue> listValue,
                                 int nestingLevel) {
    if (!v8Value->IsValid()) {
        DebugLog("V8ValueAppendToCefListValue(): IsValid() FAILED");
        return;
    }
    if (nestingLevel > 8) {
        DebugLog("V8ValueAppendToCefListValue(): WARNING: max nesting level (8) " \
                "exceeded");
        return;
    }    
    if (v8Value->IsUndefined() || v8Value->IsNull()) {
        listValue->SetNull(listValue->GetSize());
    } else if (v8Value->IsBool()) {
        listValue->SetBool(listValue->GetSize(), v8Value->GetBoolValue());
    } else if (v8Value->IsInt()) {
        listValue->SetInt(listValue->GetSize(), v8Value->GetIntValue());
    } else if (v8Value->IsUInt()) {
        uint32 uint32_value = v8Value->GetUIntValue();
        CefRefPtr<CefBinaryValue> binaryValue = CefBinaryValue::Create(
            &uint32_value, sizeof(uint32_value));
        listValue->SetBinary(listValue->GetSize(), binaryValue);
    } else if (v8Value->IsDouble()) {
        listValue->SetDouble(listValue->GetSize(), v8Value->GetDoubleValue());
    } else if (v8Value->IsDate()) {
        // TODO: in time_utils.pyx there are already functions for
        // converting cef_time_t to python DateTime, we could easily
        // add a new function for converting the python DateTime to
        // string and then to CefString and expose the function using
        // the "public" keyword. But how do we get the cef_time_t
        // structure from the CefTime class? GetDateValue() returns
        // CefTime class.
        listValue->SetNull(listValue->GetSize());
    } else if (v8Value->IsString()) {
        listValue->SetString(listValue->GetSize(), v8Value->GetStringValue());
    } else if (v8Value->IsArray()) {
        // Check for IsArray() must happen before the IsObject() check.
        int length = v8Value->GetArrayLength();
        CefRefPtr<CefListValue> newListValue = CefListValue::Create();
        for (int i = 0; i < length; ++i) {
            V8ValueAppendToCefListValue(v8Value->GetValue(i), newListValue,
                    nestingLevel + 1);
        }
        listValue->SetList(listValue->GetSize(), newListValue);
    } else if (v8Value->IsObject()) {
        // Check for IsObject() must happen after the IsArray() check.
        listValue->SetDictionary(listValue->GetSize(), V8ObjectToCefDictionaryValue(
                v8Value, nestingLevel + 1));
    } else if (v8Value->IsFunction()) {
        listValue->SetNull(listValue->GetSize());
    } else {
        DebugLog("V8ValueAppendToCefListValue() FAILED: unknown V8 type");
    }
}

CefRefPtr<CefDictionaryValue> V8ObjectToCefDictionaryValue(
                                    const CefRefPtr<CefV8Value> v8Object,
                                    int nestingLevel) {
    if (!v8Object->IsValid()) {
        DebugLog("V8ObjectToCefDictionaryValue(): IsValid() FAILED");
        return CefDictionaryValue::Create();
    }
    if (nestingLevel > 8) {
        DebugLog("V8ObjectToCefDictionaryValue(): WARNING: " \
            "max nesting level (8) exceeded");
        return CefDictionaryValue::Create();
    }
    if (!v8Object->IsObject()) {
        DebugLog("V8ObjectToCefDictionaryValue(): IsObject() FAILED");
        return CefDictionaryValue::Create();
    }
    CefRefPtr<CefDictionaryValue> ret = CefDictionaryValue::Create();
    std::vector<CefString> keys;
    if (!v8Object->GetKeys(keys)) {
        DebugLog("V8ObjectToCefDictionaryValue(): GetKeys() FAILED");
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
            uint32 uint32_value = v8Value->GetUIntValue();
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
        } else if (v8Value->IsObject()) {
            // Check for IsObject() must happen after the IsArray() check.
            ret->SetDictionary(key, 
                    V8ObjectToCefDictionaryValue(v8Value, nestingLevel + 1));
        } else if (v8Value->IsFunction()) {
            ret->SetNull(key);
        } else {
            DebugLog("V8ObjectToCefDictionaryValue() FAILED: unknown V8 type");
        }
    }
    return ret;
}

CefRefPtr<CefV8Value> CefDictionaryValueToV8Value(
        CefRefPtr<CefDictionaryValue> dictValue,
        int nestingLevel) {
    if (!dictValue->IsValid()) {
        DebugLog("CefDictionaryValueToV8Value() FAILED: " \
                "CefDictionaryValue is invalid");
        return CefV8Value::CreateNull();
    }
    if (nestingLevel > 8) {
        DebugLog("CefDictionaryValueToV8Value(): WARNING: " \
            "max nesting level (8) exceeded");
        return CefV8Value::CreateNull();
    }
    std::vector<CefString> keys;
    if (!dictValue->GetKeys(keys)) {
        DebugLog("CefDictionaryValueToV8Value() FAILED: " \
            "dictValue->GetKeys() failed");
        return CefV8Value::CreateNull();
    }
    CefRefPtr<CefV8Value> ret = CefV8Value::CreateObject(NULL);
    for (std::vector<CefString>::iterator it = keys.begin(); \
            it != keys.end(); ++it) {
        CefString key = *it;
        cef_value_type_t valueType = dictValue->GetType(key);
        bool success;
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
            DebugLog("CefDictionaryValueToV8Value() WARNING: " \
                    "unknown type, setting value to null");
            success = ret->SetValue(key,
                    CefV8Value::CreateNull(),
                    V8_PROPERTY_ATTRIBUTE_NONE);
        }
        if (!success) {
            DebugLog("CefDictionaryValueToV8Value() WARNING: " \
                    "ret->SetValue() failed");
        }
    }
    return ret;
}

CefRefPtr<CefV8Value> CefListValueToV8Value(
        CefRefPtr<CefListValue> listValue,
        int nestingLevel) {
    if (!listValue->IsValid()) {
        DebugLog("CefListValueToV8Value() FAILED: " \
                "CefDictionaryValue is invalid");
        return CefV8Value::CreateNull();
    }
    if (nestingLevel > 8) {
        DebugLog("CefListValueToV8Value(): WARNING: " \
            "max nesting level (8) exceeded");
        return CefV8Value::CreateNull();
    }
    int listSize = listValue->GetSize();
    CefRefPtr<CefV8Value> ret = CefV8Value::CreateArray(listSize);
    for (int key = 0; key < listSize; ++key) {
        cef_value_type_t valueType = listValue->GetType(key);
        bool success;
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
            DebugLog("CefListValueToV8Value() WARNING: " \
                    "unknown type, setting value to null");
            success = ret->SetValue(key,
                    CefV8Value::CreateNull());
        }
        if (!success) {
            DebugLog("CefListValueToV8Value() WARNING: " \
                    "ret->SetValue() failed");
        }
    }
    return ret;
}
