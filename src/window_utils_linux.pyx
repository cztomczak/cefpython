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
    """Auto-apply Linux/Xwayland CEF 146 defaults that every embedding app needs.

    Uses setdefault so users can still override any individual entry by passing
    it explicitly to cef.Initialize(switches={...}).
    """
    import os as _os

    # Must be set before GTK is first initialized (gtk_init).  Belt-and-
    # suspenders: also set it here in case the user forgot to set it before
    # the cefpython3 import.
    _os.environ.setdefault("GDK_BACKEND", "x11")

    # Force X11 mode in Chrome's Ozone platform selection.
    _os.environ.pop("WAYLAND_DISPLAY", None)

    # Point the Vulkan loader at the SwiftShader ICD shipped with CEF.
    import cefpython3 as _cef3_pkg
    _cef3_dir = _os.path.dirname(_cef3_pkg.__file__)
    _vk_icd = _os.path.join(_cef3_dir, "vk_swiftshader_icd.json")
    if _os.path.exists(_vk_icd):
        _os.environ.setdefault("VK_ICD_FILENAMES", _vk_icd)

    # CEF 146 on Ozone X11 requires a running GLib main loop for
    # OnContextInitialized to fire.  external_message_pump integrates
    # CefDoMessageLoopWork() as a GLib source.
    app_settings.setdefault("external_message_pump", True)

    # Chromium switches required for stable embedded operation on CEF 146.
    sw = cmd_switches
    # Force X11 backend (not Wayland) — cefpython uses raw X11 window handles.
    sw.setdefault("ozone-platform", "x11")
    # Bypass Zygote to avoid stack-smash crash from --change-stack-guard-on-fork.
    sw.setdefault("disable-zygote", "")
    # Belt-and-suspenders sandbox suppression.
    sw.setdefault("no-sandbox", "")
    # /dev/shm may be too small in VMs and containers.
    sw.setdefault("disable-dev-shm-usage", "")
    # Suppress GNOME Keyring unlock prompt.
    sw.setdefault("password-store", "basic")
    # Skip 3× GPU subprocess crash cycle; go straight to software rendering.
    sw.setdefault("disable-gpu", "")
    # Startup / sync / background noise suppression.
    sw.setdefault("no-first-run", "")
    sw.setdefault("disable-sync", "")
    sw.setdefault("no-startup-window", "")
    sw.setdefault("disable-background-networking", "")
    # Profile subdirectory — prevents ShouldShowProfilePickerAtLaunch() from
    # returning True and adding a kProfileCreationFlow keepalive that would
    # permanently block OnContextInitialized in embedded apps.
    sw.setdefault("profile-directory", "Default")
    # Disable UI features that add their own keepalives or block init.
    if "disable-features" not in sw:
        sw["disable-features"] = (
            "WebGPU,"
            "ProfilePicker,"
            "ProfilePickerIPH,"
            "ForYouFre,"
            "SyncPromoFRE,"
            "ChromeSigninIphExperiment,"
            "ChromeWhatsNewUI,"
            "DefaultBrowserPrompt,"
            "ProfileManagementFlowController"
        )


def _linux_setup_profile(cache_path):
    """Pre-create Chrome profile files to skip profile-picker keepalive.

    Chrome 146 adds a kProfileCreationFlow keepalive when it creates a new
    profile from scratch and only removes it after the wizard UI completes.
    Writing seed files before cef.Initialize() makes Chrome treat the
    profile as already configured, skipping the keepalive entirely.
    """
    import os as _os, json as _json, glob as _glob

    default_dir = _os.path.join(cache_path, "Default")
    _os.makedirs(default_dir, exist_ok=True)

    for _pat in ("Singleton*", "*.lock", "LOCK"):
        for _f in _glob.glob(_os.path.join(cache_path, _pat)):
            try: _os.unlink(_f)
            except OSError: pass
        for _f in _glob.glob(_os.path.join(default_dir, _pat)):
            try: _os.unlink(_f)
            except OSError: pass

    first_run = _os.path.join(cache_path, "First Run")
    if not _os.path.exists(first_run):
        open(first_run, "w").close()

    local_state = _os.path.join(cache_path, "Local State")
    if not _os.path.exists(local_state):
        with open(local_state, "w") as _f:
            _json.dump({"profile": {
                "info_cache": {"Default": {
                    "active_time": 1704067200.0,
                    "avatar_icon": "chrome://theme/IDR_PROFILE_AVATAR_0",
                    "is_using_default_avatar": True,
                    "is_using_default_name": True,
                    "is_new_profile": False,
                    "managed_user_id": "",
                    "name": "Default",
                }},
                "last_used": "Default",
                "profiles_created": 1,
            }}, _f)

    prefs = _os.path.join(default_dir, "Preferences")
    if not _os.path.exists(prefs):
        with open(prefs, "w") as _f:
            _json.dump({
                "profile": {
                    "creation_time": "13328563200000000",
                    "is_using_default_name": True,
                    "name": "Default",
                },
                "browser": {"has_seen_welcome_page": True},
                "privacy_sandbox": {
                    "m1.consent_decision_made": True,
                    "m1.notice_acknowledged": True,
                    "m1.restricted_notice_acknowledged": True,
                    "consent_decision_made": True,
                    "notice_acknowledged": True,
                    "first_run_consent_required": False,
                    "first_run_setup_complete": True,
                },
            }, _f)


def _linux_create_toplevel(title, width=800, height=600):
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
                    _x11.XResizeWindow(_xdisp, _ct.c_ulong(_chrome_xid),
                                       _ct.c_uint(nw), _ct.c_uint(nh))
                    _x11.XSync(_xdisp, _ct.c_int(0))
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
            _b.CloseBrowser(True)
        _gtk.gtk_main_quit()
        return False
    _del_cb = _DeleteCb(_on_delete)
    g_linux_reparent_callbacks.append(_del_cb)
    _gobject.g_signal_connect_data(_win, b"delete-event",
                                   _del_cb, None, None, 0)


def _linux_message_loop():
    """Run gtk_main() with a GLib timer driving CefDoMessageLoopWork().

    Used by cef.MessageLoop() on Linux.  CEF's Ozone X11 backend requires a
    running GLib main loop; gtk_main() provides that while the timer pumps
    CEF's internal work queue every 10 ms.  After gtk_main() returns, pump
    CEF briefly so browsers can close cleanly before cef.Shutdown().
    """
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
