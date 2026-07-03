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

def _linux_gtk_init():
    """Initialize GTK so GDK has an open display connection before CEF.

    cefpython provides GTK-based dialogs (file open/save, print) through the
    native client-handler layer (dialog_handler_gtk.cpp).  Like upstream
    cefclient, GTK must be initialised in the browser process before
    CefInitialize().  GTK runs on Chromium's own GLib-based UI message loop
    (base::MessagePumpGlib) once cef.MessageLoop() / CefRunMessageLoop()
    starts, so no separate gtk_main() is needed.
    """
    try:
        import os as _os, ctypes as _ct
        # Must be set before gtk_init() so GDK opens an X11/Xwayland display.
        _os.environ.setdefault("GDK_BACKEND", "x11")
        _gtk = _ct.CDLL("libgtk-3.so.0")
        _gtk.gtk_disable_setlocale()
        _gtk.gtk_init(None, None)
    except Exception as _e:
        Debug("_linux_gtk_init() failed: " + str(_e))


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
    import os as _os

    # Force Chrome's Ozone backend to X11.  This is the *only* thing keeping
    # Chromium off the Wayland display on a Wayland session — cefpython embeds
    # via X11 window handles (CefWindowInfo.SetAsChild) and drives X11 window
    # geometry directly.  GDK_BACKEND=x11 is set separately in
    # _linux_gtk_init() before gtk_init().
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

    # NOTE: external_message_pump is intentionally NOT forced here.  On Linux
    # cef.MessageLoop() runs CefRunMessageLoop() (same as Windows/macOS and
    # upstream cefsimple/cefclient), and Chromium's UI loop is GLib-based so
    # GTK works without a separate pump.  Apps that integrate CEF into their
    # own GUI loop via cef.MessageLoopWork() may still opt in explicitly.

    # Allow per-browser opt-in to off-screen rendering.  Required by examples
    # that pass WindowInfo.SetAsOffscreen() (e.g. pysdl2.py) and by JS-created
    # popup browsers, which are destroyed immediately when DoClose returns
    # False — no delete_event would be dispatched on a windowed popup.
    app_settings.setdefault("windowless_rendering_enabled", True)

    # Chromium's Linux sandbox — keep it when possible, disable only if unusable.
    #
    # CEF Linux builds default sandbox-ON and refuse to start unless either a
    # SUID-root chrome-sandbox helper is installed or --no-sandbox is passed.
    # A pip wheel cannot install a chown-root + chmod-4755 helper, so cefpython
    # relies on Chromium's unprivileged-user-namespace sandbox instead.  That
    # path works on most systems, but modern distros (Ubuntu 23.10+, Debian 12+)
    # set kernel.apparmor_restrict_unprivileged_userns=1 by default, and
    # containers often block the unshare() syscall via seccomp — in those cases
    # Chromium aborts with "FATAL: No usable sandbox!" unless --no-sandbox is
    # passed.
    #
    # So probe for a usable sandbox and only fall back to --no-sandbox when none
    # is available, keeping renderers confined wherever the namespace sandbox
    # works.  Historically cefpython passed --no-sandbox unconditionally, which
    # silently disabled the sandbox even on capable systems.  A user can force
    # the sandbox off by passing switches={"no-sandbox": ""} explicitly, or
    # enable it on a restricted system by installing the SUID helper and setting
    # CHROME_DEVEL_SANDBOX (see docs/Knowledge-Base.md "Linux: enabling the
    # Chromium sandbox").
    if "no-sandbox" not in cmd_switches:
        # Some switches turn off the zygote / multiprocess model, which
        # Chromium requires for the sandbox — it refuses to start otherwise
        # with "Zygote cannot be disabled if sandbox is enabled".  When the
        # caller has opted into any of these, pair them with --no-sandbox.
        _needs_no_sandbox = any(
            _sw in cmd_switches
            for _sw in ("no-zygote", "disable-zygote", "single-process"))
        if _needs_no_sandbox:
            cmd_switches["no-sandbox"] = ""
        elif not sandbox_linux.LinuxSandboxAvailable():
            cmd_switches["no-sandbox"] = ""
            import warnings
            warnings.warn(
                "cefpython: Chromium sandbox disabled (--no-sandbox). No usable "
                "sandbox was detected — unprivileged user namespaces appear to "
                "be restricted (e.g. kernel.apparmor_restrict_unprivileged_userns"
                "=1 on Ubuntu 23.10+/Debian 12+, or a container seccomp policy) "
                "and no CHROME_DEVEL_SANDBOX helper is configured. Renderer "
                "processes will run without the sandbox. See "
                "docs/Knowledge-Base.md 'Linux: enabling the Chromium sandbox' "
                "to enable it.",
                stacklevel=2,
            )
