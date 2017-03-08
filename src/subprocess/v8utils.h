// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

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
