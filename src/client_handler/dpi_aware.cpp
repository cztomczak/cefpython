// Copyright (c) 2014 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// Windows only

#pragma comment(lib, "Gdi32.lib")
#include <math.h>

#include "dpi_aware.h"
#include "include/wrapper/cef_closure_task.h"
#include "include/base/cef_bind.h"
#include "include/base/cef_logging.h"
#include "include/base/cef_callback.h"

const int DEFAULT_DPIX = 96;

bool IsProcessDpiAware() {
    typedef BOOL(WINAPI *IsProcessDPIAwarePtr)(VOID);
    IsProcessDPIAwarePtr is_process_dpi_aware_func =
            reinterpret_cast<IsProcessDPIAwarePtr>(
                GetProcAddress(GetModuleHandleA("user32.dll"), 
                    "IsProcessDPIAware"));
    BOOL is_aware = FALSE;
    if (is_process_dpi_aware_func) {
        is_aware = is_process_dpi_aware_func();
        if (is_aware == TRUE) {
            return true;
        }
    }
    // GetProcessDpiAwareness is available only on Win8. So it
    // should be called only as a back-up plan after IsProcessDPIAware
    // was called. Also if IsProcessDPIAware returned false,
    // then GetProcessDpiAwareness is called as well.
    if (GetProcessDpiAwareness() != PROCESS_DPI_UNAWARE) {
        return true;
    }
    return false;
}

PROCESS_DPI_AWARENESS GetProcessDpiAwareness() {
    // Win8.1 supports monitor-specific DPI scaling, so it is
    // recommended to use GetProcessDPIAwareness instead of the
    // deprecated IsProcessDPIAware.
    typedef HRESULT(WINAPI *GetProcessDpiAwarenessPtr)
            (HANDLE,PROCESS_DPI_AWARENESS*);
    GetProcessDpiAwarenessPtr get_process_dpi_awareness_func =
            reinterpret_cast<GetProcessDpiAwarenessPtr>(
                GetProcAddress(GetModuleHandleA("user32.dll"),
                    "GetProcessDpiAwarenessInternal"));
    if (get_process_dpi_awareness_func) {
        HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, false,
                GetCurrentProcessId());
        PROCESS_DPI_AWARENESS result;
        HRESULT hr = get_process_dpi_awareness_func(hProcess, &result);
        if (SUCCEEDED(hr)) {
            return result;
        }
        // Possible failures include E_INVALIDARG or E_ACCESSDENIED.
        LOG(INFO) << "[Browser process] GetProcessDpiAwareness():"
                     " hr=" << hr;
    }
    return PROCESS_DPI_UNAWARE;
}

void SetProcessDpiAware() {
    // Win8.1 supports monitor-specific DPI scaling, so it is
    // recommended to use SetProcessDPIAwareness instead of the
    // deprecated SetProcessDPIAware. SetProcessDpiAwareness is
    // only available on Win8. So as a back-up plan SetProcessDPIAware
    // is called.

    // If DPI aware manifest was embedded in executable, or
    // "Disable display scaling on high DPI settings" was checked
    // on the executable properties (Compatibility tab), then
    // DPI awareness is already set.
    /*
        What if GetProcessDpiAwareness returned
        PROCESS_PER_MONITOR_DPI_AWARE? The code below sets awareness
        to PROCESS_SYSTEM_DPI_AWARE, so it should be called either way.
        --OFF:
        if (IsProcessDpiAware()) {
            return;
        }
    */

    typedef BOOL(WINAPI *SetProcessDpiAwarenessPtr)(PROCESS_DPI_AWARENESS);
    SetProcessDpiAwarenessPtr set_process_dpi_awareness_func =
            reinterpret_cast<SetProcessDpiAwarenessPtr>(
                GetProcAddress(GetModuleHandleA("user32.dll"),
                    "SetProcessDpiAwarenessInternal"));
    if (set_process_dpi_awareness_func) {
        LOG(INFO) << "[Browser process] SetProcessDpiAware():"
                     " calling user32.dll SetProcessDpiAwareness";
        HRESULT hr = set_process_dpi_awareness_func(PROCESS_SYSTEM_DPI_AWARE);
        if (SUCCEEDED(hr)) {
            LOG(INFO) << "[Browser process]: SetBrowserDpiAware():"
                         " SetProcessDpiAwareness succeeded";
            return;
        } else if (hr == E_ACCESSDENIED) {
            LOG(ERROR) << "[Browser process] SetBrowserDpiAware():"
                          " SetProcessDpiAwareness failed:"
                          " The DPI awareness is already set, either by calling"
                          " this API previously or through the application"
                          " (.exe) manifest.";
            // Do not return here, let's try to call SetProcessDPIAware.
        } else {
            LOG(ERROR) << "[Browser process] SetBrowserDpiAware():"
                          " SetProcessDpiAwareness failed";
            // Do not return here, let's try to call SetProcessDPIAware.
        }
    }

    // SetProcessDpiAwareness not found in user32.dll or the call failed.
    typedef BOOL(WINAPI *SetProcessDPIAwarePtr)(VOID);
    SetProcessDPIAwarePtr set_process_dpi_aware_func =
            reinterpret_cast<SetProcessDPIAwarePtr>(
                GetProcAddress(GetModuleHandleA("user32.dll"),
                    "SetProcessDPIAware"));
    if (set_process_dpi_aware_func) {
        // If cefpython.Initialize() wasn't yet called, then
        // this log message won't be written, as g_debug is
        // is set during CEF initialization.
        LOG(INFO) << "[Browser process] SetProcessDpiAware():"
                     " calling user32.dll SetProcessDPIAware";
        set_process_dpi_aware_func();
    }
}

void GetSystemDpi(int* dpix, int* dpiy) {
    // Win7 DPI (Control Panel > Appearance and Personalization > Display):
    // text size Larger 150% => dpix/dpiy 144
    // text size Medium 125% => dpix/dpiy 120
    // text size Smaller 100% => dpix/dpiy 96
    //
    // DPI settings should not be cached. When SetProcessDpiAware
    // is not yet called, then OS returns 96 DPI, even though it
    // is set to 144 DPI. After DPI Awareness is enabled for the
    // running process it will return the correct 144 DPI.
    HDC hdc = GetDC(HWND_DESKTOP);
    *dpix = GetDeviceCaps(hdc, LOGPIXELSX);
    *dpiy = GetDeviceCaps(hdc, LOGPIXELSY);
    ReleaseDC(HWND_DESKTOP, hdc);
}

void GetDpiAwareWindowSize(int* width, int* height) {
    int dpix = 0;
    int dpiy = 0;
    GetSystemDpi(&dpix, &dpiy);
    double newZoomLevel = 0.0;
    // 1. Using only "dpix" value to calculate zoom level. All
    //    modern displays have equal horizontal and vertical resolution.
    // 2. Calculation for DPI < 96 is not yet supported (newZoomLevel<0.0).
    newZoomLevel = (dpix - DEFAULT_DPIX) / 24;
    if (newZoomLevel > 0.0) {
        *width = *width + (int)ceil(newZoomLevel * 0.25 * (*width));
        *height = *height + (int)ceil(newZoomLevel * 0.25 * (*height));
        LOG(INFO) << "[Browser process] GetDpiAwareWindowSize():"
                     " enlarged by " << ceil(newZoomLevel * 0.25 * 100) << "%"
                     " new size = " << *width << "/" << *height;
    }
}

void SetBrowserDpiSettings(CefRefPtr<CefBrowser> cefBrowser,
        CefString autoZooming) {
    // Setting zoom level immediately after browser was created
    // won't work. We need to wait a moment before we can set it.
    REQUIRE_UI_THREAD();

    double oldZoomLevel = cefBrowser->GetHost()->GetZoomLevel();
    double newZoomLevel = 0.0;

    int dpix = 0;
    int dpiy = 0;
    GetSystemDpi(&dpix, &dpiy);

    if (autoZooming.ToString() == "system_dpi") {
        // Using only "dpix" value to calculate zoom level. All
        // modern displays have equal horizontal/vertical resolution.
        // Examples:
        //   dpix=96 zoom=0.0
        //   dpix=120 zoom=1.0
        //   dpix=144 zoom=2.0
        //   dpix=72 zoom=-1.0
        newZoomLevel = (dpix - DEFAULT_DPIX) / 24;
    } else {
        // When atof() fails converting string to double, then
        // 0.0 is returned.
        newZoomLevel = atof(autoZooming.ToString().c_str());
    }

    if (oldZoomLevel != newZoomLevel) {
        cefBrowser->GetHost()->SetZoomLevel(newZoomLevel);
        if (cefBrowser->GetHost()->GetZoomLevel() != oldZoomLevel) {
            // OK succes.
            LOG(INFO) << "[Browser process] SetBrowserDpiSettings():"
                         " DPI=" << dpix << ""
                         " zoom=" << cefBrowser->GetHost()->GetZoomLevel();
        }
    } else {
        // This code block running can also be a result of executing
        // SetZoomLevel(), as GetZoomLevel() didn't return the new
        // value that was set. Documentation says that if SetZoomLevel
        // is called on the UI thread, then GetZoomLevel should
        // immediately return the same value that was set. Unfortunately
        // this seems not to be true.
        static bool already_logged = false;
        if (!already_logged) {
            already_logged = true;
            // OK success.
            LOG(INFO) << "[Browser process] SetBrowserDpiSettings():"
                         " DPI=" << dpix << ""
                         " zoom=" << cefBrowser->GetHost()->GetZoomLevel();
        }
    }
    // We need to check zooming constantly, during loading of pages.
    // If we set zooming to 2.0 for localhost/ and then it navigates
    // to google.com, then the zomming is back at 0.0 and needs to
    // be set again.
    CefPostDelayedTask(
            TID_UI,
            CefCreateClosureTask(
                    base::BindOnce(&SetBrowserDpiSettings,
                               cefBrowser, autoZooming)
            ),
            50
    );
}

