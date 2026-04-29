# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"

cdef public void BrowserProcessHandler_OnContextInitialized() noexcept with gil:
    try:
        global g_context_initialized
        Debug("BrowserProcessHandler_OnContextInitialized()")
        g_context_initialized = True
        # Browser creation is handled by BrowserProcessHandler_CreatePendingBrowsers,
        # posted as a separate task in C++ so it runs at the outer message-loop level.
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_CreatePendingBrowsers() noexcept with gil:
    try:
        Debug("BrowserProcessHandler_CreatePendingBrowsers()")
        if g_pending_browsers:
            pending = list(g_pending_browsers)
            del g_pending_browsers[:]
            for params in pending:
                browser = CreateBrowserSync(**params)
                # _linux_schedule_xembed is called inside CreateBrowserSync.
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


IF UNAME_SYSNAME == "Linux":
    def _linux_schedule_xembed(browser, embed_info):
        """Schedule deferred XUnmap+XReparentWindow for Xwayland embedding.

        WindowInfo.SetAsChild() substituted root as CEF's parent to avoid the
        Xwayland cross-client MatchError.  This function performs the reparent:
          1. Poll (10 ms) until browser.GetWindowHandle() returns non-zero.
          2. Poll (10 ms) until Chrome's window becomes IsViewable.
          3. XUnmapWindow  — Mutter withdraws its decoration frame.
          4. 100 ms GLib timer — Mutter processes UnmapNotify (race-free).
          5. XReparentWindow(chrome -> real_parent, 0, 0)
          6. XMoveResizeWindow(0, 0, width, height)
          7. XMapRaised
        """
        import ctypes as _ct

        real_parent_xid = embed_info['real_parent']
        width  = embed_info['width']
        height = embed_info['height']
        if not real_parent_xid:
            return

        _x11  = _ct.CDLL("libX11.so.6")
        _gdk  = _ct.CDLL("libgdk-3.so.0")
        _glib = _ct.CDLL("libglib-2.0.so.0")

        _gdk.gdk_display_get_default.restype = _ct.c_void_p
        _gdk.gdk_x11_display_get_xdisplay.restype = _ct.c_void_p
        _xdisp = _ct.c_void_p(_gdk.gdk_x11_display_get_xdisplay(
            _ct.c_void_p(_gdk.gdk_display_get_default())))

        _x11.XGetWindowAttributes.restype = _ct.c_int

        # Full XWindowAttributes struct (LP64 layout, 136 bytes).
        # All fields must be declared; omitting trailing fields truncates the
        # buffer to 96 bytes and XGetWindowAttributes writes all_event_masks
        # (offset 96) past the end, corrupting adjacent heap memory.
        class _XWA(_ct.Structure):
            _fields_ = [
                ("x", _ct.c_int), ("y", _ct.c_int),
                ("width", _ct.c_int), ("height", _ct.c_int),
                ("border_width", _ct.c_int), ("depth", _ct.c_int),
                ("visual", _ct.c_void_p), ("root", _ct.c_ulong),
                ("c_class", _ct.c_int), ("bit_gravity", _ct.c_int),
                ("win_gravity", _ct.c_int), ("backing_store", _ct.c_int),
                ("backing_planes", _ct.c_ulong), ("backing_pixel", _ct.c_ulong),
                ("save_under", _ct.c_int), ("colormap", _ct.c_ulong),
                ("map_installed", _ct.c_int), ("map_state", _ct.c_int),
                ("all_event_masks", _ct.c_long),
                ("your_event_mask", _ct.c_long),
                ("do_not_propagate_mask", _ct.c_long),
                ("override_redirect", _ct.c_int),
                ("screen", _ct.c_void_p),
            ]

        _browser_ref = [browser]
        # Discovered once GetWindowHandle() returns non-zero; shared into
        # the reparent closure via a one-element list so it can be set
        # inside _wait_for_map and read inside _do_reparent.
        _chrome_xid = [0]
        _poll_count = [0]

        # Steps 5-7: reparent callback — fired 100 ms after the unmap.
        _ReparentCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p)
        def _do_reparent(_ud, _pxid=real_parent_xid, _w=width, _h=height,
                          _xd=_xdisp):
            _cxid = _chrome_xid[0]
            try:
                # width/height were captured at schedule time and may be 0
                # if the parent window had not yet been laid out (e.g. the
                # Qt container hadn't been sized by the layout manager yet).
                # Query the parent's current size so the browser is resized
                # to whatever the container actually is now.
                _wa_p = _XWA()
                if _x11.XGetWindowAttributes(_xd, _ct.c_ulong(_pxid),
                                             _ct.byref(_wa_p)):
                    if _wa_p.width > 0 and _wa_p.height > 0:
                        _w, _h = _wa_p.width, _wa_p.height
                _x11.XReparentWindow(_xd, _ct.c_ulong(_cxid),
                                     _ct.c_ulong(_pxid),
                                     _ct.c_int(0), _ct.c_int(0))
                _x11.XMoveResizeWindow(_xd, _ct.c_ulong(_cxid),
                                       _ct.c_int(0), _ct.c_int(0),
                                       _ct.c_uint(_w), _ct.c_uint(_h))
                _x11.XMapRaised(_xd, _ct.c_ulong(_cxid))
                _x11.XSync(_xd, _ct.c_int(0))
                _b = _browser_ref[0]
                if _b:
                    _b.SetBounds(0, 0, _w, _h)
                    _b.NotifyMoveOrResizeStarted()
                    _b.SetFocus(True)
            except Exception as _e:
                Debug("_linux_schedule_xembed reparent error: " + str(_e))
            return False  # one-shot timer
        _rep_cb = _ReparentCb(_do_reparent)
        g_linux_reparent_callbacks.append(_rep_cb)

        # Steps 1-4: poll until handle is available and window is IsViewable,
        # then unmap to drop Mutter's frame and schedule the reparent.
        _PollCb = _ct.CFUNCTYPE(_ct.c_bool, _ct.c_void_p)
        def _wait_for_map(_ud, _xd=_xdisp):
            _poll_count[0] += 1
            # Step 1: wait for a valid native window handle.
            if not _chrome_xid[0]:
                _b = _browser_ref[0]
                if _b:
                    _chrome_xid[0] = _b.GetWindowHandle()
                if not _chrome_xid[0]:
                    if _poll_count[0] > 300:  # 3 s timeout
                        Debug("_linux_schedule_xembed: timeout waiting for handle")
                        return False
                    return True  # keep polling
            # Step 2: wait until Chrome's window is mapped and visible.
            _xwa = _XWA()
            _ok = _x11.XGetWindowAttributes(_xd, _ct.c_ulong(_chrome_xid[0]),
                                            _ct.byref(_xwa))
            _ms = _xwa.map_state if _ok else -1
            if _ok and _ms == 2:  # IsViewable
                _x11.XUnmapWindow(_xd, _ct.c_ulong(_chrome_xid[0]))
                _x11.XSync(_xd, _ct.c_int(0))
                _glib.g_timeout_add(100, _rep_cb, None)
                return False  # stop polling
            if _poll_count[0] > 300:  # 3 s timeout
                Debug("_linux_schedule_xembed: timeout waiting for IsViewable")
                return False
            return True  # keep polling
        _poll_cb = _PollCb(_wait_for_map)
        g_linux_reparent_callbacks.append(_poll_cb)
        _glib.g_timeout_add(10, _poll_cb, None)

cdef public void BrowserProcessHandler_OnRenderProcessThreadCreated(
        CefRefPtr[CefListValue] extra_info
        ) noexcept with gil:
    try:
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnBeforeChildProcessLaunch(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) noexcept with gil:
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
        IF UNAME_SYSNAME == "Linux":
            _StripPseudonymizationSaltHandle(cefCommandLine)  # strips crash-inducing switches
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)


IF UNAME_SYSNAME == "Linux":
    # Switches that must be stripped from every child-process command line on
    # Linux to prevent crashes in CEF 146 subprocesses.
    #
    # --pseudonymization-salt-handle (Chrome 130+):
    #   Passed to directly-launched (non-zygote) utility subprocesses,
    #   expecting GlobalDescriptors[key=7] to already be populated.
    #   CEF 146 does not perform this GlobalDescriptors initialization for
    #   the non-zygote path, so the subprocess crashes:
    #     "Failed global descriptor lookup: 7"
    #   Removing the switch causes Chrome to use a per-process random salt.
    #
    # --change-stack-guard-on-fork (Chrome / Linux zygote):
    #   Tells a Zygote-forked child to randomize its stack canary after fork.
    #   ChangeStackGuard() is called from inside the Zygote event-loop stack
    #   frames that the fork() inherited.  Those frames have the pre-fork
    #   canary saved; when they return the canary check fails:
    #     "*** stack smashing detected ***: terminated"
    #   The subprocess exits before Chrome's initialization completes, so
    #   OnContextInitialized never fires.  Removing the switch prevents
    #   ChangeStackGuard() from being called at all; the child keeps the
    #   Zygote's canary (which is still randomized at Zygote startup).
    _STRIP_CHILD_SWITCHES = frozenset([
        "pseudonymization-salt-handle",
        "change-stack-guard-on-fork",
    ])

    cdef void _StripPseudonymizationSaltHandle(
            CefRefPtr[CefCommandLine] cefCommandLine) except * with gil:
        cdef CefString cefSwitchName
        cdef bint needs_strip = False
        for sw in _STRIP_CHILD_SWITCHES:
            cefSwitchName = PyToCefStringValue(sw)
            if cefCommandLine.get().HasSwitch(cefSwitchName):
                needs_strip = True
                break
        if not needs_strip:
            return

        # Capture current state before resetting.
        cdef CefString program
        program = cefCommandLine.get().GetProgram()

        cdef cpp_map[CefString, CefString] switches
        cefCommandLine.get().GetSwitches(switches)

        cdef cpp_vector[CefString] arguments
        cefCommandLine.get().GetArguments(arguments)

        # Rebuild command line omitting the problem switches.
        cefCommandLine.get().Reset()
        cefCommandLine.get().SetProgram(program)

        cdef cpp_map[CefString, CefString].iterator it = switches.begin()
        while it != switches.end():
            if CefToPyString(deref(it).first) not in _STRIP_CHILD_SWITCHES:
                if deref(it).second.empty():
                    cefCommandLine.get().AppendSwitch(deref(it).first)
                else:
                    cefCommandLine.get().AppendSwitchWithValue(
                        deref(it).first, deref(it).second)
            preinc(it)

        cdef size_t i
        for i in range(arguments.size()):
            cefCommandLine.get().AppendArgument(arguments[i])
