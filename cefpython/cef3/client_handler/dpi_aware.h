// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

// Windows only

#pragma once

#include <windows.h>
#include "include/cef_app.h"
#include "util.h"

// Duplicated from Win8.1 SDK ShellScalingApi.h
typedef enum PROCESS_DPI_AWARENESS {
    PROCESS_DPI_UNAWARE = 0,
    PROCESS_SYSTEM_DPI_AWARE = 1,
    PROCESS_PER_MONITOR_DPI_AWARE = 2
} PROCESS_DPI_AWARENESS;

/*
bool IsProcessDpiAware();
PROCESS_DPI_AWARENESS GetProcessDpiAwareness();
*/
void SetProcessDpiAware();
void GetSystemDpi(int* outx, int* outy);
void GetDpiAwareWindowSize(int* width, int* height);
void SetBrowserDpiSettings(CefRefPtr<CefBrowser> cefBrowser,
        CefString autoZooming);

