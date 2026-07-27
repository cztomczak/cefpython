// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// NOTE: This file is also used by "subprocess" and "libcefpythonapp"
//       targets during build.

#include "x11.h"
#include "include/base/cef_logging.h"

int XErrorHandlerImpl(Display *display, XErrorEvent *event) {
    LOG(INFO) << "[Browser process] "
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
    LOG(INFO) << "[Browser process] Install X11 error handlers";
    XSetErrorHandler(XErrorHandlerImpl);
    XSetIOErrorHandler(XIOErrorHandlerImpl);
}

void SetX11WindowBounds(CefRefPtr<CefBrowser> browser,
                        int x, int y, int width, int height) {
    // xwindow is 0 for windowless (OSR) browsers - nothing to resize, and no
    // need to touch X11 at all, so check this first.
    ::Window xwindow = browser->GetHost()->GetWindowHandle();
    if (!xwindow) return;
    // cefpython forces ozone-platform=x11 by default (window_utils_linux.pyx),
    // so cef_get_xdisplay() is normally valid. It can be NULL when no X server
    // is reachable (e.g. a pure-Wayland session with no XWayland) - without
    // this guard XConfigureWindow(NULL, ...) segfaults (verified). This is an
    // X11-only helper, so no-op there.
    ::Display* xdisplay = cef_get_xdisplay();
    if (!xdisplay) {
        LOG(INFO) << "[Browser process] SetX11WindowBounds: no X11 display "
                     "(non-X11 Ozone backend?), skipping";
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
    // xwindow is 0 for windowless (OSR) browsers - no title bar to set.
    ::Window xwindow = browser->GetHost()->GetWindowHandle();
    if (!xwindow) return;
    // See SetX11WindowBounds: xdisplay can be NULL on a non-X11 Ozone backend
    // (e.g. pure Wayland with no XWayland); XStoreName(NULL, ...) would segfault.
    ::Display* xdisplay = cef_get_xdisplay();
    if (!xdisplay) {
        LOG(INFO) << "[Browser process] SetX11WindowTitle: no X11 display "
                     "(non-X11 Ozone backend?), skipping";
        return;
    }
    XStoreName(xdisplay, xwindow, title);
}

GtkWindow* CefBrowser_GetGtkWindow(CefRefPtr<CefBrowser> browser) {
  // TODO: Should return NULL when using the Views framework
  // -- REWRITTEN FOR CEF PYTHON USE CASE --
  //
  // Returns a GtkWindow* to use as the transient parent for GTK dialogs (the
  // file-chooser and print handlers); it is never used for browser embedding.
  //
  // Upstream cefclient gets this parent from its own top-level GtkWindow, via
  // RootWindow::GetForBrowser(id)->GetWindowHandle() - see GetWindow() in CEF's
  // tests/cefclient/browser/dialog_handler_gtk.cc. cefpython has no such
  // GtkWindow: the browser is embedded with CefWindowInfo::SetAsChild() into a
  // foreign toolkit's X11 window (Qt/GTK/wx/tk), not a cefclient RootWindow.
  // So instead we wrap the browser's own X11 window - CefBrowserHost::
  // GetWindowHandle(), which is the XID on Linux (include/cef_browser.h) - as a
  // GtkWindow using gtk_plug_new_for_display().
  //
  // The browser window is not a real GtkSocket, so GTK may log
  // "Can't create GtkPlug as child of non-GtkSocket" (harmless; the dialog
  // still works - see the note further down).
  //
  // X11 window handle
  ::Window xwindow = browser->GetHost()->GetWindowHandle();
  // X11 display
  ::Display* xdisplay = cef_get_xdisplay();
  // GDK display
  GdkDisplay* gdk_display = NULL;
  if (xdisplay) {
    // See if we can find GDK display using X11 display
    gdk_display = gdk_x11_lookup_xdisplay(xdisplay);
  }
  if (!gdk_display) {
    // If not then get the default display
    gdk_display = gdk_display_get_default();
  }
  if (!gdk_display) {
    // The tkinter_.py and hello_world.py examples do not use GTK
    // internally, so GTK wasn't yet initialized and must do it
    // now, so that display is available. Also must install X11
    // error handlers to avoid 'BadWindow' errors.
    // --
    // A similar code is in cefpython_app.cpp and it might already
    // been executed. If making changes here, make changes there
    // as well.
    LOG(INFO) << "[Browser process] Initialize GTK";
    gtk_init(0, NULL);
    InstallX11ErrorHandlers();
    // Now the display is available
    gdk_display = gdk_display_get_default();
  }
  // In kivy_.py example getting error message:
  // > Can't create GtkPlug as child of non-GtkSocket
  // However dialog handler works just fine.
  GtkWidget* widget = gtk_plug_new_for_display(gdk_display, xwindow);
  // Getting top level widget doesn't seem to be required.
  // OFF: GtkWidget* toplevel = gtk_widget_get_toplevel(widget);
  GtkWindow* window = GTK_WINDOW(widget);
  if (!window) {
    LOG(ERROR) << "No GtkWindow for browser";
  }
  return window;
}

XImage* CefBrowser_GetImage(CefRefPtr<CefBrowser> browser) {
    ::Display* display = cef_get_xdisplay();
    if (!display) {
        LOG(ERROR) << "cef_get_xdisplay() returned NULL in CefBrowser_GetImage";
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
