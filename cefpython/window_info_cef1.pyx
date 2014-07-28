# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

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
                GetClientRect(
                        <CefWindowHandle>windowInfo.parentWindowHandle, &rect)
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle, rect)
        ELIF UNAME_SYSNAME == "Darwin":
            raise Exception("WindowInfo.SetAsChild() not implemented on Mac")
        ELIF UNAME_SYSNAME == "Linux":
            cefWindowInfo.SetAsChild(
                    <CefWindowHandle>windowInfo.parentWindowHandle)

    IF UNAME_SYSNAME == "Windows":
        if windowInfo.windowType == "popup":
            PyToCefString(windowInfo.windowName, cefString)
            cefWindowInfo.SetAsPopup(
                    <CefWindowHandle>windowInfo.parentWindowHandle, cefString)

    IF not (CEF_VERSION == 1 and UNAME_SYSNAME == "Linux"):
        if windowInfo.windowType == "offscreen":
            cefWindowInfo.SetAsOffScreen(
                    <CefWindowHandle>windowInfo.parentWindowHandle)
        cefWindowInfo.SetTransparentPainting(
                int(windowInfo.transparentPainting))

cdef class WindowInfo:
    cdef public str windowType
    cdef public WindowHandle parentWindowHandle
    cdef public list windowRect
    cdef public py_string windowName
    cdef public py_bool transparentPainting

    def __init__(self):
        self.transparentPainting = False

    cpdef py_void SetAsChild(self, WindowHandle parentWindowHandle,
            list windowRect=None):
        if not WindowUtils.IsWindowHandle(parentWindowHandle):
            raise Exception("Invalid parentWindowHandle: %s" \
                    % parentWindowHandle)
        self.windowType = "child"
        self.parentWindowHandle = parentWindowHandle
        IF UNAME_SYSNAME == "Darwin":
            if not windowRect:
                raise Exception("WindowInfo.SetAsChild() failed: " \
                        "windowRect is required")
        if windowRect:
            if type(windowRect) == list and len(windowRect) == 4:
                self.windowRect = [windowRect[0], windowRect[1], 
                                   windowRect[2], windowRect[3]]
            else:
                raise Exception("WindowInfo.SetAsChild() failed: " \
                        "windowRect: invalid value")

    IF UNAME_SYSNAME == "Windows":
        cpdef py_void SetAsPopup(self, WindowHandle parentWindowHandle, 
                py_string windowName):
            if not WindowUtils.IsWindowHandle(parentWindowHandle):
                raise Exception("Invalid parentWindowHandle: %s" \
                        % parentWindowHandle)
            self.parentWindowHandle = parentWindowHandle
            self.windowType = "popup"
            self.windowName = str(windowName)

    IF not (CEF_VERSION == 1 and UNAME_SYSNAME == "Linux"):
        cpdef py_void SetAsOffscreen(self, 
                WindowHandle parentWindowHandle):
            # It is allowed to pass 0 as parentWindowHandle.
            if parentWindowHandle and \
                    not WindowUtils.IsWindowHandle(parentWindowHandle):
                raise Exception("Invalid parentWindowHandle: %s" \
                        % parentWindowHandle)
            self.parentWindowHandle = parentWindowHandle
            self.windowType = "offscreen"
            
        cpdef py_void SetTransparentPainting(self, 
                py_bool transparentPainting):
            self.transparentPainting = transparentPainting
