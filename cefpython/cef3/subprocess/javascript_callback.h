// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once
#include "include/cef_v8.h"

CefString PutJavascriptCallback(
        CefRefPtr<CefFrame> frame, CefRefPtr<CefV8Value> jsCallback);

bool ExecuteJavascriptCallback(int callbackId, CefRefPtr<CefListValue> args);

void RemoveJavascriptCallbacksForFrame(CefRefPtr<CefFrame> frame);
