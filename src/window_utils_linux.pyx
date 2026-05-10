# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

# Set to True when native Wayland mode is active (ozone-platform=wayland).
# Initialised by _linux_apply_initialize_defaults() inside Initialize().
_g_linux_wayland_mode = False

# GMainLoop* pointer (raw integer) used by _linux_wayland_message_loop().
# Stored here so QuitMessageLoop() can call g_main_loop_quit() on it.
_g_wayland_main_loop = None

# Default size for auto-created top-level windows (X11 and Wayland paths).
_LINUX_DEFAULT_WIDTH = 800
_LINUX_DEFAULT_HEIGHT = 600


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
# Linux platform helpers — called from Initialize(), MessageLoop(), and the
# WindowInfo / browser-process-handler embedding machinery.
# ---------------------------------------------------------------------------

def _linux_gtk_init():
    """Initialize GTK so GDK has an open display connection before CEF."""
    try:
        import os as _os, ctypes as _ct
        # Must be set before gtk_init() so GDK opens an X11/Xwayland display.
        _os.environ.setdefault("GDK_BACKEND", "x11")
        _gtk = _ct.CDLL("libgtk-3.so.0")
        _gtk.gtk_disable_setlocale()
        _gtk.gtk_init(None, None)
    except Exception as _e:
        Debug("_linux_gtk_init() failed: " + str(_e))


def _linux_get_root_xid():
    """Return the X11 root window XID for the default display (int)."""
    import ctypes as _ct
    _x11 = _ct.CDLL("libX11.so.6")
    _gdk = _ct.CDLL("libgdk-3.so.0")
    _gdk.gdk_display_get_default.restype = _ct.c_void_p
    _gdk.gdk_x11_display_get_xdisplay.restype = _ct.c_void_p
    _xdisp = _ct.c_void_p(_gdk.gdk_x11_display_get_xdisplay(
        _ct.c_void_p(_gdk.gdk_display_get_default())))
    _x11.XDefaultRootWindow.restype = _ct.c_ulong
    return int(_x11.XDefaultRootWindow(_xdisp))


def _linux_apply_initialize_defaults(app_settings, cmd_switches):
    """Auto-apply Linux defaults that every cefpython app needs.

    X11/XWayland is the default on all Linux systems (even Wayland sessions).
    Native Wayland mode must be requested explicitly by passing
    switches={"ozone-platform": "wayland"} to cef.Initialize().

    Reason: CEF's NativeWidgetDelegate hardcodes params.remove_standard_frame=true
    and params.type=TYPE_CONTROL for the standalone Wayland path, so the
    compositor never adds Server Side Decorations.  In X11/XWayland mode CEF
    parents the browser widget inside the GTK window we create, and the window
    manager decorates the GTK frame window normally.

    Uses setdefault so users can still override any individual entry by passing
    it explicitly to cef.Initialize(switches={...}).  Each setting kept here
    has been individually retested against current CEF/Chromium — anything
    that did not regress when removed has been dropped.
    """
    global _g_linux_wayland_mode
    import os as _os

    # Native Wayland mode only when the caller explicitly opts in via
    # switches={"ozone-platform": "wayland"}.  Otherwise default to X11/Xwayland.
    _g_linux_wayland_mode = (cmd_switches.get("ozone-platform") == "wayland")

    if not _g_linux_wayland_mode:
        # X11/Xwayland mode: force Chrome's Ozone backend to X11.  This is
        # the *only* thing keeping Chromium off the Wayland display on a
        # Wayland session — we cannot embed a Wayland xdg_surface inside
        # the GTK X11 window we create in _linux_create_toplevel().
        # GDK_BACKEND=x11 is set separately in _linux_gtk_init() before
        # gtk_init().
        cmd_switches.setdefault("ozone-platform", "x11")
    # Native Wayland branch: "ozone-platform" is already in cmd_switches
    # (the only way to reach this branch), so nothing to do here.

    # Vulkan ICD fallback for systems with no system-installed driver.
    #
    # On systems with no Vulkan ICD (typical for VMs and minimal containers),
    # Chromium's GPU process fails its Vulkan probe and the renderer logs a
    # transient
    #   ContextResult::kTransientFailure: Failed to send
    #     GpuControl.CreateCommandBuffer
    # before falling back to software rendering.  Pointing VK_ICD_FILENAMES
    # at the SwiftShader manifest bundled with CEF makes the probe succeed
    # immediately and silences the line.
    #
    # Only apply the fallback when no system ICD is present in the standard
    # loader search paths — overriding a working Mesa/NVIDIA/AMD ICD with
    # SwiftShader would force software rendering for no reason on real GPUs.
    # Honors a pre-set VK_ICD_FILENAMES (setdefault) so users can override.
    import glob as _glob
    _system_icds = (_glob.glob("/usr/share/vulkan/icd.d/*.json") +
                    _glob.glob("/etc/vulkan/icd.d/*.json") +
                    _glob.glob("/usr/local/share/vulkan/icd.d/*.json"))
    if not _system_icds:
        import cefpython3 as _cef3_pkg
        _cef3_dir = _os.path.dirname(_cef3_pkg.__file__)
        _vk_icd = _os.path.join(_cef3_dir, "vk_swiftshader_icd.json")
        if _os.path.exists(_vk_icd):
            _os.environ.setdefault("VK_ICD_FILENAMES", _vk_icd)

    # _linux_message_loop / _linux_wayland_message_loop drive CEF by calling
    # CefDoMessageLoopWork() from a GLib timer.  external_message_pump tells
    # CEF not to run its own internal loop, so the two don't conflict.
    app_settings.setdefault("external_message_pump", True)

    # Allow per-browser opt-in to off-screen rendering.  Required by examples
    # that pass WindowInfo.SetAsOffscreen() (e.g. pysdl2.py) and by JS-created
    # popup browsers, which are destroyed immediately when DoClose returns
    # False — no delete_event would be dispatched on a windowed popup.
    app_settings.setdefault("windowless_rendering_enabled", True)

    # Disable Chromium's Linux sandbox.
    #
    # History:
    #   * CEF defaulted sandbox-OFF until 2013-11-15 (commit f5bc72b23,
    #     SVN trunk@1518, "Add sandbox support, issue #524").  The
    #     commit message stated explicitly: "Linux: For binary
    #     distributions a new chrome-sandbox executable with SUID
    #     permissions must be placed next to the CEF executable."
    #   * The earliest release branch carrying that change is branch
    #     2357 (created 2015-08-21, ~Chromium 44).  From 2357 onward,
    #     every CEF Linux build defaults sandbox-ON and refuses to start
    #     unless either a SUID-root chrome-sandbox helper is installed
    #     or this --no-sandbox switch is passed.
    #   * For ~2017-2023, most distros enabled
    #     kernel.unprivileged_userns_clone=1, so Chromium's namespace
    #     sandbox could substitute for the SUID helper and many
    #     embedders quietly avoided either step.
    #   * Ubuntu 23.10 (Oct 2023) set
    #     kernel.apparmor_restrict_unprivileged_userns=1 by default;
    #     Debian 12 followed.  This re-broke the namespace-only path:
    #     without the SUID helper Chromium aborts with
    #     FATAL: No usable sandbox!  (zygote_host_impl_linux.cc:128)
    #   * cefpython is distributed as a pip wheel, and pip cannot
    #     chown root + chmod 4755 a binary (it runs as the user, not
    #     root, and has no postinst hook).  Distro packages such as
    #     google-chrome and chromium handle this in their .deb/.rpm
    #     postinst scripts; cefpython has no equivalent install path.
    #
    # Effect of this line: cefpython works out of the box on every
    # Linux distro at the cost of running Chromium subprocesses
    # without the chromium namespace sandbox (seccomp-bpf still
    # applies).  See docs/Knowledge-Base.md "Linux: enabling the
    # Chromium sandbox" for the manual opt-in path.
    cmd_switches.setdefault("no-sandbox", "")


def _linux_create_toplevel(title, width=_LINUX_DEFAULT_WIDTH, height=_LINUX_DEFAULT_HEIGHT):
    """Create a standalone GTK toplevel window for embedded browser use.

    Called from CreateBrowserSync when no parent window handle is given on
    Linux, so hello_world.py needs no GTK-specific code.  Returns a state
    dict consumed by _linux_register_window_callbacks.
    """
    import ctypes as _ct
    _gtk     = _ct.CDLL("libgtk-3.so.0")
    _gdk     = _ct.CDLL("libgdk-3.so.0")
    _x11     = _ct.CDLL("libX11.so.6")
    _gobject = _ct.CDLL("libgobject-2.0.so.0")

    _gtk.gtk_window_new.restype           = _ct.c_void_p
    _gtk.gtk_widget_get_window.restype    = _ct.c_void_p
    _gdk.gdk_x11_window_get_xid.restype         = _ct.c_ulong
    _gdk.gdk_display_get_default.restype         = _ct.c_void_p
    _gdk.gdk_x11_display_get_xdisplay.restype    = _ct.c_void_p

    _win = _ct.c_void_p(_gtk.gtk_window_new(0))  # GTK_WINDOW_TOPLEVEL
    _gtk.gtk_window_set_title(_win, title.encode("utf-8"))
    _gtk.gtk_window_resize(_win, width, height)
    _gtk.gtk_widget_realize(_win)
    _gtk.gtk_widget_show_all(_win)

    _gdk_win = _ct.c_void_p(_gtk.gtk_widget_get_window(_win))
    _xid     = int(_gdk.gdk_x11_window_get_xid(_gdk_win))
    _xdisp   = _ct.c_void_p(_gdk.gdk_x11_display_get_xdisplay(
                   _ct.c_void_p(_gdk.gdk_display_get_default())))

    return {
        'win': _win, 'xid': _xid, 'xdisp': _xdisp,
        'width': width, 'height': height,
        'gtk': _gtk, 'x11': _x11, 'gobject': _gobject,
    }


def _linux_close_popup_browsers(main_id):
    """Queue CloseBrowser(True) for every tracked browser except main_id.

    Called when the main GTK window delete-event fires so that popup browsers
    are shut down in the same event-loop pass.  Without this, cef.Shutdown()
    can be called while popups are still alive, hitting the emergency
    force-close path in Shutdown() and producing a spurious gtk_main_quit()
    assertion warning when QuitMessageLoop fires later.
    """
    for bid in list(g_pyBrowsers.keys()):
        if bid != main_id:
            pb = GetPyBrowserById(bid)
            if pb:
                try:
                    pb.CloseBrowser(True)
                except Exception:
                    pass


def _linux_register_window_callbacks(browser, ws):
    """Register resize and close callbacks for a standalone GTK toplevel.

    ws is the dict returned by _linux_create_toplevel.  Called from
    CreateBrowserSync after the browser object is available.
    """
    import ctypes as _ct
    _gtk     = ws['gtk']
    _x11     = ws['x11']
    _gobject = ws['gobject']
    _win     = ws['win']
    _xdisp   = ws['xdisp']
    _w_ref   = _ct.c_int(0)
    _h_ref   = _ct.c_int(0)
    _browser_ref = [browser]

    # Resize Chrome's X11 window to match GTK window on configure-event.
    _ConfigureCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p,
                                 _ct.c_void_p, _ct.c_void_p)
    def _on_configure(_w, _ev, _ud):
        _gtk.gtk_window_get_size(_win, _ct.byref(_w_ref), _ct.byref(_h_ref))
        nw, nh = _w_ref.value, _h_ref.value
        if nw > 0 and nh > 0:
            _b = _browser_ref[0]
            if _b:
                _chrome_xid = _b.GetWindowHandle()
                if _chrome_xid:
                    # Notify CEF of the incoming resize before applying it so
                    # the compositor can prepare (avoids blank frames).
                    # SetBounds calls XConfigureWindow + XFlush internally;
                    # the redundant XResizeWindow+XSync was removed because
                    # XSync blocks the GIL and can make the WM consider the
                    # window unresponsive (triggering spurious WM_DELETE_WINDOW).
                    _b.NotifyMoveOrResizeStarted()
                    _b.SetBounds(0, 0, nw, nh)
        return False
    _conf_cb = _ConfigureCb(_on_configure)
    g_linux_reparent_callbacks.append(_conf_cb)
    _gobject.g_signal_connect_data(_win, b"configure-event",
                                   _conf_cb, None, None, 0)

    # Close browser and quit message loop when the GTK window is closed.
    _DeleteCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p,
                              _ct.c_void_p, _ct.c_void_p)
    def _on_delete(_w, _ev, _ud):
        _b = _browser_ref[0]
        if _b:
            # Close any open popup browsers so the drain loop in
            # _linux_message_loop() can clean them up without hitting the
            # emergency force-close path in Shutdown().
            _linux_close_popup_browsers(_b.GetIdentifier())
            _b.CloseBrowser(True)
        # Always call gtk_main_quit() here.  When _on_delete returns False,
        # GTK destroys the X11 parent window, which also destroys CEF's
        # embedded child window via X11's parent-child relationship.  CEF
        # does not fire OnBeforeClose through its normal path after the X11
        # window is destroyed externally, so QuitMessageLoop() would never be
        # called and the GTK main loop would spin at 100% CPU.  The drain
        # loop in _linux_message_loop() handles remaining CEF cleanup after
        # gtk_main() returns.
        _gtk.gtk_main_quit()
        return False
    _del_cb = _DeleteCb(_on_delete)
    g_linux_reparent_callbacks.append(_del_cb)
    _gobject.g_signal_connect_data(_win, b"delete-event",
                                   _del_cb, None, None, 0)


def _linux_register_wayland_close_handler(browser):
    """Register a DoClose callback for a native Wayland auto-created top-level window.

    On Wayland with the Alloy runtime, CloseHostWindow() is a compile-time no-op
    (guarded by #if BUILDFLAG(SUPPORTS_OZONE_X11)), so WindowDestroyed() is never
    called and OnBeforeClose never fires through the normal CEF destroy chain.

    This callback bridges the gap: when the user closes the native Wayland window
    (xdg_toplevel.close) or when CloseBrowser(True) is called, DoClose fires.
    We quit the GLib main loop so MessageLoop() returns and the caller can proceed
    to cef.Shutdown().  Returning False tells CEF to proceed with the close;
    CloseHostWindow() then no-ops, but the drain loop in
    _linux_wayland_message_loop() handles final CEF cleanup.
    """
    _existing = browser.GetClientCallback("DoClose")

    def _wayland_do_close(browser, **_kw):
        suppress = False
        if _existing:
            try:
                suppress = bool(_existing(browser=browser))
            except Exception:
                pass
        if not suppress:
            QuitMessageLoop()
        return suppress

    browser.SetClientCallback("DoClose", _wayland_do_close)


def _linux_wayland_message_loop():
    """Run a GLib main loop driving CefDoMessageLoopWork() for native Wayland.

    No GTK window is involved; CEF's Ozone Wayland backend creates and owns its
    own wl_surface.  The GLib main loop is used only as a portable timer source
    to pump the CEF message queue every 10 ms.  QuitMessageLoop() calls
    g_main_loop_quit() on the stored loop pointer to stop it.
    """
    global _g_wayland_main_loop
    import ctypes as _ct, time as _t

    _glib = _ct.CDLL("libglib-2.0.so.0")
    _glib.g_main_loop_new.restype = _ct.c_void_p

    _loop = _glib.g_main_loop_new(None, False)
    _g_wayland_main_loop = _loop

    _WorkCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p)
    def _cef_work(_ud):
        MessageLoopWork()
        return True
    _cb = _WorkCb(_cef_work)
    g_linux_reparent_callbacks.append(_cb)
    _glib.g_timeout_add(10, _cb, None)

    _glib.g_main_loop_run(_ct.c_void_p(_loop))

    for _ in range(50):
        MessageLoopWork()
        _t.sleep(0.01)

    _glib.g_main_loop_unref(_ct.c_void_p(_loop))
    _g_wayland_main_loop = None


def _linux_message_loop():
    """Run the appropriate message loop for the active platform backend.

    Dispatches to the Wayland GLib loop or the GTK/X11 loop depending on
    whether native Wayland mode was detected during Initialize().
    """
    if _g_linux_wayland_mode:
        _linux_wayland_message_loop()
        return

    import ctypes as _ct, time as _t

    _gtk = _ct.CDLL("libgtk-3.so.0")
    _glib = _ct.CDLL("libglib-2.0.so.0")

    _WorkCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p)
    def _cef_work(_ud):
        MessageLoopWork()
        return True
    _cb = _WorkCb(_cef_work)
    # Keep the callback alive for the lifetime of the GTK main loop.
    g_linux_reparent_callbacks.append(_cb)
    _glib.g_timeout_add(10, _cb, None)

    _gtk.gtk_main()

    # Drain CEF after gtk_main() returns so CloseBrowser() completes.
    for _ in range(50):
        MessageLoopWork()
        _t.sleep(0.01)
