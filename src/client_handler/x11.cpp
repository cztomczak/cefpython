// Copyright (c) 2016 The CEF Python authors. All rights reserved.

#include <X11/Xlib.h>
#include "LOG_DEBUG.h"
#include "include/cef_browser.h"

int XErrorHandlerImpl(Display *display, XErrorEvent *event) {
  LOG_DEBUG
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
    XSetErrorHandler(XErrorHandlerImpl);
    XSetIOErrorHandler(XIOErrorHandlerImpl);
}

void SetXWindowBounds(::Window xwindow,
                      int x, int y, size_t width, size_t height) {
  ::Display* xdisplay = cef_get_xdisplay();
  XWindowChanges changes = {0};
  changes.x = x;
  changes.y = y;
  changes.width = static_cast<int>(width);
  changes.height = static_cast<int>(height);
  XConfigureWindow(xdisplay, xwindow,
                   CWX | CWY | CWHeight | CWWidth, &changes);
}

void SetX11WindowBounds(CefRefPtr<CefBrowser> browser,
                        int x, int y, int width, int height) {
    ::Window xwindow = browser->GetHost()->GetWindowHandle();
    SetXWindowBounds(xwindow, x, y, width, height);
}
