// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// NOTE: This file is also used by "subprocess" and "libcefpythonapp"
//       targets during build.

#include "x11.h"
#include "util.h"
#include "include/base/cef_logging.h"

int XErrorHandlerImpl(Display *display, XErrorEvent *event) {
    LOG(INFO) << ""
        << "X error received: "
        << "type " << event->type << ", "
        << "serial " << event->serial << ", "
        << "error_code " << static_cast<int>(event->error_code) << ", "
        << "request_code " << static_cast<int>(event->request_code) << ", "
        << "minor_code " << static_cast<int>(event->minor_code);
    return 0;
}

int XIOErrorHandlerImpl(Display *display) {
    return 0;
}

void InstallX11ErrorHandlers() {
    // Copied from upstream cefclient.
    // Install xlib error handlers so that the application won't be terminated
    // on non-fatal errors. Must be done after initializing GTK.
    LOG(INFO) << "Install X11 error handlers";
    XSetErrorHandler(XErrorHandlerImpl);
    XSetIOErrorHandler(XIOErrorHandlerImpl);
}

unsigned long GetX11DefaultVisualId(int screen_number) {
    REQUIRE_UI_THREAD();
    // See SetX11WindowBounds: NULL off the UI thread or on a non-X11 Ozone
    // backend.
    ::Display* xdisplay = cef_get_xdisplay();
    if (!xdisplay) {
        LOG(WARNING) << "GetX11DefaultVisualId: no X11 "
                        "display (wrong thread or non-X11 backend)";
        return 0;
    }
    if (screen_number < 0 || screen_number >= ScreenCount(xdisplay)) {
        LOG(WARNING) << "GetX11DefaultVisualId: invalid "
                        "screen number " << screen_number;
        return 0;
    }
    return XVisualIDFromVisual(DefaultVisual(xdisplay, screen_number));
}

void SetX11WindowBounds(CefRefPtr<CefBrowser> browser,
                        int x, int y, int width, int height) {
    REQUIRE_UI_THREAD();
    // xwindow is 0 for windowless (OSR) browsers - nothing to resize, and no
    // need to touch X11 at all, so check this first. Callers should not get
    // here for OSR (use WasResized() instead), so warn.
    ::Window xwindow = browser->GetHost()->GetWindowHandle();
    if (!xwindow) {
        LOG(WARNING) << "SetX11WindowBounds: no X11 window "
                        "handle (windowless browser?), skipping";
        return;
    }
    // cef_get_xdisplay() is NULL off the UI thread (cef_types_linux.h; the
    // assert above is compiled out in release builds) and on any thread when
    // the app selects a non-X11 Ozone backend with no X server.
    // XConfigureWindow(NULL, ...) segfaults (verified), so no-op instead.
    ::Display* xdisplay = cef_get_xdisplay();
    if (!xdisplay) {
        LOG(INFO) << "SetX11WindowBounds: no X11 display "
                     "(wrong thread or non-X11 backend), skipping";
        return;
    }
    XWindowChanges changes = {0};
    changes.x = x;
    changes.y = y;
    changes.width = static_cast<int>(width);
    changes.height = static_cast<int>(height);
    XConfigureWindow(xdisplay, xwindow,
                     CWX | CWY | CWHeight | CWWidth, &changes);
    XFlush(xdisplay);
}

void SetX11WindowTitle(CefRefPtr<CefBrowser> browser, char* title) {
    REQUIRE_UI_THREAD();
    // xwindow is 0 for windowless (OSR) browsers - no title bar to set. The
    // only caller is for windowed browsers, so this indicates a bug.
    ::Window xwindow = browser->GetHost()->GetWindowHandle();
    if (!xwindow) {
        LOG(WARNING) << "SetX11WindowTitle: no X11 window "
                        "handle (windowless browser?), skipping";
        return;
    }
    // See SetX11WindowBounds: NULL off the UI thread or on a non-X11 Ozone
    // backend; XStoreName(NULL, ...) would segfault.
    ::Display* xdisplay = cef_get_xdisplay();
    if (!xdisplay) {
        LOG(INFO) << "SetX11WindowTitle: no X11 display "
                     "(wrong thread or non-X11 backend), skipping";
        return;
    }
    XStoreName(xdisplay, xwindow, title);
}

XImage* CefBrowser_GetImage(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    // See SetX11WindowBounds: NULL off the UI thread or on a non-X11 Ozone
    // backend.
    ::Display* display = cef_get_xdisplay();
    if (!display) {
        LOG(ERROR) << "cef_get_xdisplay() returned NULL in CefBrowser_GetImage"
                      " (wrong thread or non-X11 backend)";
        return NULL;
    }
    ::Window browser_window = browser->GetHost()->GetWindowHandle();
    XWindowAttributes attrs;
    if (!XGetWindowAttributes(display, browser_window, &attrs)) {
        LOG(ERROR) << "XGetWindowAttributes failed in CefBrowser_GetImage";
        return NULL;
    }
    XImage* image = XGetImage(display, browser_window,
                              0, 0, attrs.width, attrs.height,
                              AllPlanes, ZPixmap);
    if (!image) {
        LOG(ERROR) << "XGetImage failed in CefBrowser_GetImage";
        return NULL;
    }
    return image;
}
