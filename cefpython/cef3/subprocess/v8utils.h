// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once
#include "include/cef_v8.h"
#include "include/cef_values.h"
#include "v8function_handler.h"

// ----------------------------------------------------------------------------
// V8 values to CEF values.
// ----------------------------------------------------------------------------

CefRefPtr<CefListValue> V8ValueListToCefListValue(
        const CefV8ValueList& v8List);

void V8ValueAppendToCefListValue(const CefRefPtr<CefV8Value> v8Value, 
                           CefRefPtr<CefListValue> listValue,
                           int nestingLevel=0);

CefRefPtr<CefDictionaryValue> V8ObjectToCefDictionaryValue(
                                    const CefRefPtr<CefV8Value> v8Object,
                                    int nestingLevel=0);

// ----------------------------------------------------------------------------
// CEF values to V8 values.
// ----------------------------------------------------------------------------

CefV8ValueList CefListValueToCefV8ValueList(
        CefRefPtr<CefListValue> listValue);

CefRefPtr<CefV8Value> CefListValueToV8Value(
        CefRefPtr<CefListValue> listValue,
        int nestingLevel=0);

CefRefPtr<CefV8Value> CefDictionaryValueToV8Value(
        CefRefPtr<CefDictionaryValue> dictValue,
        int nestingLevel=0);
