// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#pragma once
#include "include/cef_v8.h"

CefString PutJavascriptCallback(
        CefRefPtr<CefFrame> frame, CefRefPtr<CefV8Value> jsCallback);

bool ExecuteJavascriptCallback(int callbackId, CefRefPtr<CefListValue> args);

void RemoveJavascriptCallbacksForFrame(CefRefPtr<CefFrame> frame);
