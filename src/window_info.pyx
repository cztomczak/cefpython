# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef void SetCefWindowInfo(
        CefWindowInfo& cefWindowInfo,
        WindowInfo windowInfo
        ) except *:
    if not windowInfo.windowType:
        raise Exception("WindowInfo: windowType is not set")

    # It is allowed to pass 0 as parentWindowHandle in OSR mode, but then
    # some things like context menus and plugins may not display correctly.
    if windowInfo.windowType != "offscreen":
        if not windowInfo.parentWindowHandle:
            # raise Exception("WindowInfo: parentWindowHandle is not set")
            pass

    IF UNAME_SYSNAME == "Windows":
        cdef RECT windowRect
        cdef CefString windowName
    ELIF UNAME_SYSNAME == "Linux":
        cdef CefRect windowRect

    # CHILD WINDOW
    if windowInfo.windowType == "child":
        IF UNAME_SYSNAME == "Windows":
            if windowInfo.windowRect:
                windowRect.left = int(windowInfo.windowRect[0])
                windowRect.top = int(windowInfo.windowRect[1])
                windowRect.right = int(windowInfo.windowRect[2])
                windowRect.bottom = int(windowInfo.windowRect[3])
            else:
                GetClientRect(<CefWindowHandle>windowInfo.parentWindowHandle,
                              &windowRect)
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    windowRect)
        ELIF UNAME_SYSNAME == "Darwin":
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    int(windowInfo.windowRect[0]),
                    int(windowInfo.windowRect[1]),
                    int(windowInfo.windowRect[2]),
                    int(windowInfo.windowRect[3]))
        ELIF UNAME_SYSNAME == "Linux":
            x = int(windowInfo.windowRect[0])
            y = int(windowInfo.windowRect[1])
            width = int(windowInfo.windowRect[2] - windowInfo.windowRect[0])
            height = int(windowInfo.windowRect[3] - windowInfo.windowRect[1])
            windowRect = CefRect(x, y, width, height)
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    windowRect)

    # POPUP WINDOW - Windows only
    IF UNAME_SYSNAME == "Windows":
        if windowInfo.windowType == "popup":
            PyToCefString(windowInfo.windowName, windowName)
            cefWindowInfo.SetAsPopup(
                    <CefWindowHandle>windowInfo.parentWindowHandle,
                    windowName)

    cdef cpp_bool transparent = bool(windowInfo.transparentPainting)
    if windowInfo.windowType == "offscreen":
        cefWindowInfo.SetAsWindowless(
                <CefWindowHandle>windowInfo.parentWindowHandle)

cdef class WindowInfo:
    cdef public str windowType
    cdef public WindowHandle parentWindowHandle
    cdef public list windowRect # [left, top, right, bottom]
    cdef public py_string windowName
    cdef public py_bool transparentPainting

    def __init__(self, title=""):
        self.transparentPainting = False
        self.windowName = ""
        if title:
            self.windowName = title

    cpdef py_void SetAsChild(self, WindowHandle parentWindowHandle,
                             list windowRect=None):
        # Allow parent window handle to be 0, in such case CEF will
        # create top window automatically as in hello_world.py example.
        IF UNAME_SYSNAME == "Windows":
            # On Windows when parent window handle is 0 then SetAsPopup()
            # must be called instead.
            if parentWindowHandle == 0:
                self.SetAsPopup(parentWindowHandle, "")
                return
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

    IF UNAME_SYSNAME == "Windows":
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
        self.transparentPainting = transparentPainting
