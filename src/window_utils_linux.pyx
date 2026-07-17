# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"


class WindowUtils:
    # You have to overwrite this class and provide implementations
    # for these methods.

    @classmethod
    def OnSetFocus(cls, WindowHandle windowHandle, long msg, long wparam,
                   long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def OnSize(cls, WindowHandle windowHandle, long msg, long wparam,
               long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def OnEraseBackground(cls, WindowHandle windowHandle, long msg,
                          long wparam, long lparam):
        # Available only on Windows, but have it available on other
        # platforms so that PyCharm doesn't warn about unresolved reference.
        pass

    @classmethod
    def GetParentHandle(cls, WindowHandle windowHandle):
        Debug("WindowUtils::GetParentHandle() not implemented (returns 0)")
        return 0

    @classmethod
    def IsWindowHandle(cls, WindowHandle windowHandle):
        Debug("WindowUtils::IsWindowHandle() not implemented (always True)")
        return True

    @classmethod
    def gtk_plug_new(cls, WindowHandle gdkNativeWindow):
        return <WindowHandle>gtk_plug_new(<unsigned long>gdkNativeWindow)

    @classmethod
    def gtk_widget_show(cls, WindowHandle gtkWidgetPtr):
        with nogil:
            gtk_widget_show(<GtkWidget*>gtkWidgetPtr)

    @classmethod
    def InstallX11ErrorHandlers(cls):
        with nogil:
            x11.InstallX11ErrorHandlers()


# ---------------------------------------------------------------------------
# Linux platform helpers — called from Initialize().
# ---------------------------------------------------------------------------

def _linux_apply_initialize_defaults(app_settings, cmd_switches):
    """Auto-apply Linux defaults that every cefpython app needs.

    cefpython embeds the browser via X11 window handles, so Chromium's Ozone
    backend is forced to X11 on all Linux systems, including Wayland sessions
    (where it runs under XWayland).

    Uses setdefault so users can still override any individual entry by passing
    it explicitly to cef.Initialize(switches={...}).  Each setting kept here
    has been individually retested against current CEF/Chromium — anything
    that did not regress when removed has been dropped.
    """
    # Force Chrome's Ozone backend to X11.  This is the *only* thing keeping
    # Chromium off the Wayland display on a Wayland session — cefpython embeds
    # via X11 window handles (CefWindowInfo.SetAsChild) and drives X11 window
    # geometry directly.
    #
    # Root cause (upstream CEF): native windowed embedding into a client
    # parent_window is implemented for X11 only — CreateHostWindow() in CEF's
    # libcef/browser/native/browser_platform_delegate_native_linux.cc is wrapped
    # entirely in `#if BUILDFLAG(SUPPORTS_OZONE_X11)` (creating a CefWindowX11)
    # with no Wayland branch, and there is no window_wayland implementation.
    # Wayland has no cross-process window embedding (no X11-style window IDs /
    # XReparent), so CEF cannot parent the browser into a foreign Wayland
    # surface; embedders must run under X11/XWayland.  Verified on CEF 147:
    # without this switch, a Wayland session selects the Wayland Ozone backend
    # and the embedding path crashes.
    cmd_switches.setdefault("ozone-platform", "x11")

    # Disable Chromium's Linux sandbox.  It is on by default and needs either a
    # SUID-root "chrome-sandbox" helper or an unprivileged user namespace to
    # start; where neither is available CEF aborts during startup.  A pip wheel
    # can guarantee neither — it cannot install a chown-root binary, and many
    # distros and container runtimes block unprivileged user namespaces — so
    # cefpython disables the sandbox on Linux, as it always has.  setdefault
    # leaves an explicit caller-provided value untouched.
    cmd_switches.setdefault("no-sandbox", "")
