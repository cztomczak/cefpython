// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

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

bool IsProcessDpiAware();
PROCESS_DPI_AWARENESS GetProcessDpiAwareness();
void SetProcessDpiAware();
void GetSystemDpi(int* outx, int* outy);
void GetDpiAwareWindowSize(int* width, int* height);
void SetBrowserDpiSettings(CefRefPtr<CefBrowser> cefBrowser,
        CefString autoZooming);

