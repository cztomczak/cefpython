# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef CefRect PyToCefRect(list windowRect) except *:
    # [left, top, right, bottom] -> CefRect(x, y, width, height)
    return CefRect(int(windowRect[0]), int(windowRect[1]),
                   int(windowRect[2] - windowRect[0]),
                   int(windowRect[3] - windowRect[1]))

cdef py_bool HasWindowSize(list windowRect):
    # A top-level window rect must have a positive width and height. On
    # Windows a size of 0 is not CW_USEDEFAULT and makes a window with no
    # content area, and on Linux CEF replaces only a size of 0 with 800x600.
    return bool(windowRect and windowRect[2] > windowRect[0]
                and windowRect[3] > windowRect[1])

cdef void SetCefWindowInfo(
        CefWindowInfo& cefWindowInfo,
        WindowInfo windowInfo
        ) except *:
    # Note on runtime_style = CEF_RUNTIME_STYLE_ALLOY (set below in every
    # windowed branch):
    #
    # The cef_window_info_t.runtime_style field was added in CEF
    # commit dca0435d2 "chrome: Add support for Alloy style browsers
    # and windows" (issue #3681, 2024-04-17, first shipping in CEF
    # branch 6422 / Chromium 125).  See the enum doc in
    # include/internal/cef_types_runtime.h: Chrome style provides the
    # full Chrome UI; Alloy style provides the content-layer view with
    # additional client callbacks and windowless (OSR) rendering.
    #
    # The chrome bootstrap (default since CEF branch 6478 / Chromium
    # 125) makes a windowed parent window default to Chrome style, so
    # cefpython opts back into Alloy explicitly.  Alloy is required (not
    # just preferred) for cefpython's use case:
    #   - Windowless / off-screen rendering is Alloy-only
    #     (cef_types_runtime.h).
    #   - cefpython's JavaScript bindings do not work under Chrome style:
    #     verified on CEF 147 that window.<binding> is never injected for
    #     a Chrome-style browser while Alloy injects it.  cefpython's JS
    #     integration (bindings, Python callbacks, V8) rides on the Alloy
    #     renderer path.
    #   - On macOS an embedded (native-parent) browser cannot use Chrome
    #     style at all (CEF issue #3294; see chrome_child_window.cc
    #     GetParentWidget()).
    # Note: embedding itself is NOT the blocker - a Chrome-style browser
    # CAN be parented into a foreign host window on Linux/Windows via
    # CefBrowserPlatformDelegateChromeChildWindow (verified: SetAsChild
    # parents it correctly).  The blockers are the missing JS integration
    # and OSR above.
    if not windowInfo.windowType:
        raise Exception("WindowInfo: windowType is not set")

    # It is allowed to pass 0 as parentWindowHandle in OSR mode, but then
    # some things like context menus and plugins may not display correctly.
    if windowInfo.windowType != "offscreen":
        if not windowInfo.parentWindowHandle:
            # raise Exception("WindowInfo: parentWindowHandle is not set")
            pass

    IF UNAME_SYSNAME == "Windows":
        cdef CefRect windowRect
        cdef CefString windowName
        cdef RECT rect

    # CHILD WINDOW
    if windowInfo.windowType == "child":
        IF UNAME_SYSNAME == "Windows":
            if windowInfo.windowRect:
                rect.left = int(windowInfo.windowRect[0])
                rect.top = int(windowInfo.windowRect[1])
                rect.right = int(windowInfo.windowRect[2])
                rect.bottom = int(windowInfo.windowRect[3])
            else:
                GetClientRect(<CefWindowHandle>windowInfo.parentWindowHandle,
                              &rect)
            windowRect = CefRect(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top)
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    windowRect)
            cefWindowInfo.runtime_style = CEF_RUNTIME_STYLE_ALLOY
        ELSE:
            if windowInfo.parentWindowHandle:
                # Embed into the host toolkit window, like upstream cefclient
                # (browser_window_std_gtk.cc, browser_window_std_mac.mm).
                cefWindowInfo.SetAsChild(
                        <CefWindowHandle>windowInfo.parentWindowHandle,
                        PyToCefRect(windowInfo.windowRect))
            elif HasWindowSize(windowInfo.windowRect):
                # Without a size, keep the bounds CEF already set: for a
                # popup, the size from its window.open() features.
                cefWindowInfo.bounds = PyToCefRect(windowInfo.windowRect)
            cefWindowInfo.runtime_style = CEF_RUNTIME_STYLE_ALLOY

    # POPUP WINDOW - Windows only
    IF UNAME_SYSNAME == "Windows":
        if windowInfo.windowType == "popup":
            PyToCefString(windowInfo.windowName, windowName)
            cefWindowInfo.SetAsPopup(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    windowName)
            # SetAsPopup() sets the bounds to CW_USEDEFAULT (chosen by
            # Windows), so set the rect after it.
            if HasWindowSize(windowInfo.windowRect):
                cefWindowInfo.bounds = PyToCefRect(windowInfo.windowRect)
            cefWindowInfo.runtime_style = CEF_RUNTIME_STYLE_ALLOY

    if windowInfo.windowType == "offscreen":
        cefWindowInfo.SetAsWindowless(
                <CefWindowHandle>windowInfo.parentWindowHandle)

cdef class WindowInfo:
    cdef public str windowType
    cdef public WindowHandle parentWindowHandle
    cdef public list windowRect # [left, top, right, bottom]
    cdef public py_string windowName

    def __init__(self, title=""):
        self.windowName = ""
        if title:
            self.windowName = title

    cpdef py_void SetAsChild(self, WindowHandle parentWindowHandle,
                             list windowRect=None):
        # Allow parent window handle to be 0, in such case CEF will
        # create top window automatically as in hello_world.py example.
        if parentWindowHandle != 0\
                and not WindowUtils.IsWindowHandle(parentWindowHandle):
            raise Exception("Invalid parentWindowHandle: %s"\
                    % parentWindowHandle)
        self.windowType = "child"
        self.parentWindowHandle = parentWindowHandle
        IF UNAME_SYSNAME == "Darwin" or UNAME_SYSNAME == "Linux":
            if not windowRect:
                windowRect = [0,0,0,0]
        if windowRect:
            if type(windowRect) == list and len(windowRect) == 4:
                self.windowRect = [windowRect[0], windowRect[1],
                                   windowRect[2], windowRect[3]]
            else:
                raise Exception("WindowInfo.SetAsChild() failed: "
                        "windowRect: invalid value")
        else:
            self.windowRect = None
        IF UNAME_SYSNAME == "Windows":
            # On Windows when parent window handle is 0 then SetAsPopup()
            # must be called instead. windowRect then sets the window
            # bounds, so keep it.
            if parentWindowHandle == 0:
                windowRect = self.windowRect
                self.SetAsPopup(parentWindowHandle, "")
                self.windowRect = windowRect

    cpdef py_void SetAsPopup(self, WindowHandle parentWindowHandle,
                             py_string windowName):
        # Allow parent window handle to be 0, in such case CEF will
        # create top window automatically as in hello_world.py example.
        if parentWindowHandle != 0\
                and not WindowUtils.IsWindowHandle(parentWindowHandle):
            raise Exception("Invalid parentWindowHandle: %s"\
                    % parentWindowHandle)
        self.parentWindowHandle = parentWindowHandle
        self.windowType = "popup"
        self.windowRect = None
        if windowName:
            self.windowName = str(windowName)

    cpdef py_void SetAsOffscreen(self,
            WindowHandle parentWindowHandle):
        # It is allowed to pass 0 as parentWindowHandle in OSR mode
        if parentWindowHandle and \
                not WindowUtils.IsWindowHandle(parentWindowHandle):
            raise Exception("Invalid parentWindowHandle: %s" \
                    % parentWindowHandle)
        self.parentWindowHandle = parentWindowHandle
        self.windowType = "offscreen"

    cpdef py_void SetTransparentPainting(self,
            py_bool transparentPainting):
        """Deprecated."""
        if transparentPainting:
            # Do nothing, since v66 OSR windows are transparent by default
            pass
        else:
            raise Exception("This method is deprecated since v66, see "
                            "Migration Guide document.")

