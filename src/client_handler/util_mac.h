// Copyright (c) 2013 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#ifndef CEFPYTHON_UTIL_MAC_H_
#define CEFPYTHON_UTIL_MAC_H_

#include <string>
#include "include/cef_base.h"
#include "include/cef_app.h"
#include "include/cef_browser.h"

void MacInitialize();
void MacShutdown();
void MacSetWindowTitle(CefRefPtr<CefBrowser> browser, char* title);

#endif  // CEFPYTHON_UTIL_MAC_H_
