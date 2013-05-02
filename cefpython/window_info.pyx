# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef void SetCefWindowInfo(
        CefWindowInfo& cefWindowInfo,
        WindowInfo windowInfo
        ) except *:
    if not windowInfo.windowType:
        raise Exception("WindowInfo: windowType is not set")
    if not windowInfo.parentWindowHandle:
        raise Exception("WindowInfo: parentWindowHandle is not set")

    IF UNAME_SYSNAME == "Windows":
        cdef RECT rect
    cdef CefString cefString

    if windowInfo.windowType == "child":
        IF UNAME_SYSNAME == "Windows":
            if windowInfo.windowRect:
                rect.left = int(windowInfo.windowRect[0])
                rect.top = int(windowInfo.windowRect[1])
                rect.right = int(windowInfo.windowRect[2])
                rect.bottom = int(windowInfo.windowRect[3])
            else:
                GetClientRect(<HWND><int>windowInfo.parentWindowHandle, &rect)
            cefWindowInfo.SetAsChild(<HWND><int>windowInfo.parentWindowHandle, rect)
        ELIF UNAME_SYSNAME == "Darwin":
            raise Exception("WindowInfo.SetAsChild() not yet implemented on Mac")
        ELIF UNAME_SYSNAME == "Linux":
            cefWindowInfo.SetAsChild(<CefWindowHandle><int>windowInfo.parentWindowHandle)

    IF UNAME_SYSNAME == "Windows":
        if windowInfo.windowType == "popup":
            PyToCefString(windowInfo.windowName, cefString)
            cefWindowInfo.SetAsPopup(<HWND><int>windowInfo.parentWindowHandle, cefString)

    IF CEF_VERSION == 1:
        IF UNAME_SYSNAME == "Windows" or UNAME_SYSNAME == "Darwin":
            if windowInfo.windowType == "offscreen":
                cefWindowInfo.SetAsOffScreen(<HWND><int>windowInfo.parentWindowHandle)

    IF CEF_VERSION == 1:
        IF UNAME_SYSNAME == "Windows" or UNAME_SYSNAME == "Darwin":
            cefWindowInfo.SetTransparentPainting(int(windowInfo.transparentPainting))
    ELIF CEF_VERSION == 3:
        IF UNAME_SYSNAME == "Windows":
            cefWindowInfo.SetTransparentPainting(int(windowInfo.transparentPainting))

cdef class WindowInfo:
    cdef public str windowType
    cdef public WindowHandle parentWindowHandle
    cdef public list windowRect
    cdef public py_string windowName
    cdef public py_bool transparentPainting

    def __init__(self):
        self.transparentPainting = False

    cpdef py_void SetAsChild(self, WindowHandle parentWindowHandle, list windowRect=None):
        if not WindowUtils.IsWindowHandle(parentWindowHandle):
            raise Exception("Invalid parentWindowHandle: %s" % parentWindowHandle)

        self.windowType = "child"
        self.parentWindowHandle = parentWindowHandle

        IF UNAME_SYSNAME == "Darwin":
            if not windowRect:
                raise Exception("WindowInfo.SetAsChild() failed: windowRect is required")

        if windowRect:
            if type(windowRect) == list and len(windowRect) == 4:
                self.windowRect = [windowRect[0], windowRect[1], windowRect[2], windowRect[3]]
            else:
                raise Exception("WindowInfo.SetAsChild() failed: windowRect: invalid value")

    IF UNAME_SYSNAME == "Windows":

        cpdef py_void SetAsPopup(self, WindowHandle parentWindowHandle, py_string windowName):
            if not WindowUtils.IsWindowHandle(parentWindowHandle):
                raise Exception("Invalid parentWindowHandle: %s" % parentWindowHandle)
            self.parentWindowHandle = parentWindowHandle
            self.windowType = "popup"
            self.windowName = str(windowName)

    IF CEF_VERSION == 1:
        IF UNAME_SYSNAME == "Windows" or UNAME_SYSNAME == "Darwin":

            cpdef py_void SetAsOffscreen(self, WindowHandle parentWindowHandle):
                if not WindowUtils.IsWindowHandle(parentWindowHandle):
                    raise Exception("Invalid parentWindowHandle: %s" % parentWindowHandle)
                self.parentWindowHandle = parentWindowHandle
                self.windowType = "offscreen"

    IF CEF_VERSION == 1:
        IF UNAME_SYSNAME == "Windows" or UNAME_SYSNAME == "Darwin":

            cpdef py_void SetTransparentPainting(self, py_bool transparentPainting):
                self.transparentPainting = transparentPainting

    ELIF CEF_VERSION == 3:
        IF UNAME_SYSNAME == "Windows":

            cpdef py_void SetTransparentPainting(self, py_bool transparentPainting):
                self.transparentPainting = transparentPainting