# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

IF CEF_VERSION == 1:
    # cef_key_type_t, SendKeyEvent().
    KEYTYPE_KEYUP = cef_types.KT_KEYUP
    KEYTYPE_KEYDOWN = cef_types.KT_KEYDOWN
    KEYTYPE_CHAR = cef_types.KT_CHAR

    # cef_mouse_button_type_t, SendMouseClickEvent().
    MOUSEBUTTON_LEFT = cef_types.MBT_LEFT
    MOUSEBUTTON_MIDDLE = cef_types.MBT_MIDDLE
    MOUSEBUTTON_RIGHT = cef_types.MBT_RIGHT

# If you try to keep PyBrowser() objects inside cpp_vector you will
# get segmentation faults, as they will be garbage collected.

cdef dict g_pyBrowsers = {}

cdef PyBrowser GetPyBrowser(CefRefPtr[CefBrowser] cefBrowser):
    global g_pyBrowsers
    if <void*>cefBrowser == NULL or not cefBrowser.get():
        Debug("GetPyBrowser(): returning None")
        return None

    cdef PyBrowser pyBrowser
    cdef int browserId
    cdef int id

    browserId = cefBrowser.get().GetIdentifier()
    if browserId in g_pyBrowsers:
        return g_pyBrowsers[browserId]

    for id, pyBrowser in g_pyBrowsers.items():
        if not pyBrowser.cefBrowser.get():
            Debug("GetPyBrowser(): removing an empty CefBrowser reference, "
                  "browserId=%s" % id)
            del g_pyBrowsers[id]

    Debug("GetPyBrowser(): creating new PyBrowser, browserId=%s" % browserId)
    pyBrowser = PyBrowser()
    pyBrowser.cefBrowser = cefBrowser
    g_pyBrowsers[browserId] = pyBrowser

    # Inherit client callbacks and javascript bindings
    # from parent browser.

    # Checking __outerWindowHandle as we should not inherit
    # client callbacks and javascript bindings if the browser
    # was created explicitily by calling CreateBrowserSync().

    # Popups inherit client callbacks by default.

    # Popups inherit javascript bindings only when "bindToPopups"
    # constructor param was set to True.

    cdef WindowHandle openerHandle
    cdef dict clientCallbacks
    cdef JavascriptBindings javascriptBindings
    cdef PyBrowser tempPyBrowser

    if pyBrowser.IsPopup() and \
            not pyBrowser.GetUserData("__outerWindowHandle"):
        openerHandle = pyBrowser.GetOpenerWindowHandle()
        for id, tempPyBrowser in g_pyBrowsers.items():
            if tempPyBrowser.GetWindowHandle() == openerHandle:
                clientCallbacks = tempPyBrowser.GetClientCallbacksDict()
                if clientCallbacks:
                    pyBrowser.SetClientCallbacksDict(clientCallbacks)
                javascriptBindings = tempPyBrowser.GetJavascriptBindings()
                if javascriptBindings:
                    if javascriptBindings.GetBindToPopups():
                        pyBrowser.SetJavascriptBindings(javascriptBindings)
    return pyBrowser

cpdef PyBrowser GetBrowserByWindowHandle(WindowHandle windowHandle):
    cdef PyBrowser pyBrowser
    for browserId in g_pyBrowsers:
        pyBrowser = g_pyBrowsers[browserId]
        if (pyBrowser.GetWindowHandle() == windowHandle or
                pyBrowser.GetUserData("__outerWindowHandle") == long(windowHandle)):
            return pyBrowser
    return None

IF CEF_VERSION == 3:

    cdef CefRefPtr[CefBrowserHost] GetCefBrowserHost(
            CefRefPtr[CefBrowser] cefBrowser) except *:
        cdef CefRefPtr[CefBrowserHost] cefBrowserHost = (
                cefBrowser.get().GetHost())
        if <void*>cefBrowserHost != NULL and cefBrowserHost.get():
            return cefBrowserHost
        raise Exception("GetCefBrowserHost() failed: this method of "
                        "Browser object can only be called in the "
                        "browser process.")

cdef class PyBrowser:
    cdef CefRefPtr[CefBrowser] cefBrowser

    cdef public dict clientCallbacks
    cdef public list allowedClientCallbacks
    cdef public JavascriptBindings javascriptBindings
    cdef public dict userData

    # Properties used by ToggleFullscreen().
    cdef public int isFullscreen
    cdef public int maximized
    cdef public int gwlStyle
    cdef public int gwlExStyle
    cdef public tuple windowRect

    # C-level attributes are initialized to 0 automatically.
    cdef void* imageBuffer

    cdef CefRefPtr[CefBrowser] GetCefBrowser(self) except *:
        if <void*>self.cefBrowser != NULL and self.cefBrowser.get():
            return self.cefBrowser
        raise Exception("PyBrowser.GetCefBrowser() failed: CefBrowser "
                        "was destroyed")

    IF CEF_VERSION == 3:

        cdef CefRefPtr[CefBrowserHost] GetCefBrowserHost(self) except *:
            cdef CefRefPtr[CefBrowserHost] cefBrowserHost = (
                    self.GetCefBrowser().get().GetHost())
            if <void*>cefBrowserHost != NULL and cefBrowserHost.get():
                return cefBrowserHost
            raise Exception("PyBrowser.GetCefBrowserHost() failed: this "
                            "method can only be called in the browser "
                            "process.")

    def __init__(self):
        self.clientCallbacks = {}
        self.allowedClientCallbacks = []
        self.userData = {}

    def __dealloc__(self):
        if self.imageBuffer:
            free(self.imageBuffer)

    cpdef py_void SetClientCallback(self, py_string name, object callback):
        if not self.allowedClientCallbacks:
            # CefLoadHandler.
            self.allowedClientCallbacks += ["OnLoadEnd", "OnLoadError",
                    "OnLoadStart"]

            # CefKeyboardHandler.
            self.allowedClientCallbacks += ["OnKeyEvent"]

            # CefV8ContextHandler.
            self.allowedClientCallbacks += ["OnContextCreated",
                    "OnContextReleased" ,"OnUncaughtException"]

            # CefRequestHandler.
            self.allowedClientCallbacks += ["OnBeforeBrowse",
                    "OnBeforeResourceLoad", "OnResourceRedirect",
                    "OnResourceResponse", "OnProtocolExecution",
                    "GetDownloadHandler", "GetAuthCredentials",
                    "GetCookieManager"]

            # CefDisplayHandler.
            self.allowedClientCallbacks += ["OnAddressChange",
                    "OnConsoleMessage", "OnContentsSizeChange",
                    "OnNavStateChange", "OnStatusMessage", "OnTitleChange",
                    "OnTooltip"]

            # LifespanHandler.
            self.allowedClientCallbacks += ["DoClose", "OnAfterCreated",
                    "OnBeforeClose", "RunModal"]

            # RenderHandler
            self.allowedClientCallbacks += ["GetViewRect", "GetScreenRect",
                    "GetScreenPoint", "OnPopupShow", "OnPopupSize",
                    "OnPaint", "OnCursorChange"]

            # DragHandler
            self.allowedClientCallbacks += ["OnDragStart", "OnDragEnter"]

        if name not in self.allowedClientCallbacks:
            raise Exception("Browser.SetClientCallback() failed: unknown "
                            "callback: %s" % name)

        self.clientCallbacks[name] = callback

    cpdef py_void SetClientHandler(self, object clientHandler):
        if not hasattr(clientHandler, "__class__"):
            raise Exception("Browser.SetClientHandler() failed: __class__ "
                            "attribute missing")
        cdef dict methods = {}
        cdef py_string key
        cdef object method
        cdef tuple value
        for value in inspect.getmembers(clientHandler,
                predicate=inspect.ismethod):
            key = value[0]
            method = value[1]
            if key and key[0] != '_':
                self.SetClientCallback(key, method)

    cpdef object GetClientCallback(self, py_string name):
        if name in self.clientCallbacks:
            return self.clientCallbacks[name]

    cpdef py_void SetClientCallbacksDict(self, dict clientCallbacks):
        self.clientCallbacks = clientCallbacks

    cpdef dict GetClientCallbacksDict(self):
        return self.clientCallbacks

    cpdef py_void SetJavascriptBindings(self, JavascriptBindings bindings):
        self.javascriptBindings = bindings
        IF CEF_VERSION == 1:
            if self.GetUserData("__v8ContextCreated"):
                Debug("Browser.SetJavascriptBindings(): v8 context already"
                        "created, calling Rebind()")
                self.javascriptBindings.Rebind()
        ELIF CEF_VERSION == 3:
            self.javascriptBindings.Rebind()

    cpdef JavascriptBindings GetJavascriptBindings(self):
        return self.javascriptBindings

    # --------------
    # CEF API.
    # --------------

    cpdef py_bool CanGoBack(self):
        return self.GetCefBrowser().get().CanGoBack()

    cpdef py_bool CanGoForward(self):
        return self.GetCefBrowser().get().CanGoForward()

    IF CEF_VERSION == 1:

        cpdef object ClearHistory(self):
            self.GetCefBrowser().get().ClearHistory()

    cpdef py_void CloseBrowser(self, py_bool forceClose=False):
        # In cefclient/cefclient_win.cpp there is only
        # ParentWindowWillClose() called. CloseBrowser() is called
        # only for popups.
        if self.GetUserData("__outerWindowHandle"):
            IF CEF_VERSION == 1:
                Debug("CefBrowser::ParentWindowWillClose()")
                self.GetCefBrowser().get().ParentWindowWillClose()
            ELIF CEF_VERSION == 3:
                Debug("CefBrowserHost::ParentWindowWillClose()")
                self.GetCefBrowserHost().get().ParentWindowWillClose()
        else:
            IF CEF_VERSION == 1:
                Debug("CefBrowser::CloseBrowser()")
                self.GetCefBrowser().get().CloseBrowser()
            ELIF CEF_VERSION == 3:
                Debug("CefBrowserHost::CloseBrowser()")
                self.GetCefBrowserHost().get().CloseBrowser(bool(forceClose))

    IF CEF_VERSION == 1:

        cpdef py_void CloseDevTools(self):
            self.GetCefBrowser().get().CloseDevTools()

        cpdef py_void Find(self, int searchId, py_string searchText,
                           py_bool forward, py_bool matchCase,
                           py_bool findNext):
            cdef CefString cefSearchText
            PyToCefString(searchText, cefSearchText)
            self.GetCefBrowser().get().Find(searchId, cefSearchText,
                    bool(forward), bool(matchCase), bool(findNext))

    cpdef PyFrame GetFocusedFrame(self):
        assert IsThread(TID_UI), (
                "Browser.GetFocusedFrame() may only be called on UI thread")
        return GetPyFrame(self.GetCefBrowser().get().GetFocusedFrame())

    cpdef PyFrame GetFrame(self, py_string name):
        assert IsThread(TID_UI), (
                "Browser.GetFrame() may only be called on the UI thread")
        cdef CefString cefName
        PyToCefString(name, cefName)
        return GetPyFrame(self.GetCefBrowser().get().GetFrame(cefName))

    IF CEF_VERSION == 3:
        cpdef object GetFrameByIdentifier(self, object identifier):
            return GetPyFrame(self.GetCefBrowser().get().GetFrame(
                    <long long>long(identifier)))

    cpdef list GetFrameNames(self):
        assert IsThread(TID_UI), (
                "Browser.GetFrameNames() may only be called on the UI thread")
        cdef cpp_vector[CefString] cefNames
        self.GetCefBrowser().get().GetFrameNames(cefNames)
        cdef list names = []
        cdef cpp_vector[CefString].iterator iterator = cefNames.begin()
        cdef CefString cefString
        while iterator != cefNames.end():
            cefString = deref(iterator)
            names.append(CefToPyString(cefString))
            preinc(iterator)
        return names

    cpdef list GetFrames(self):
        cdef list names = self.GetFrameNames()
        cdef PyFrame frame
        cdef list frames = []
        for name in names:
            frame = self.GetFrame(name)
            frames.append(frame)
        return frames

    cpdef int GetIdentifier(self) except *:
        return self.GetCefBrowser().get().GetIdentifier()

    cpdef PyFrame GetMainFrame(self):
        return GetPyFrame(self.GetCefBrowser().get().GetMainFrame())

    cpdef WindowHandle GetOpenerWindowHandle(self) except *:
        cdef WindowHandle hwnd
        IF CEF_VERSION == 1:
            hwnd = <WindowHandle>self.GetCefBrowser().get().GetOpenerWindowHandle()
        ELIF CEF_VERSION == 3:
            hwnd = <WindowHandle>self.GetCefBrowserHost().get().GetOpenerWindowHandle()
        return hwnd

    cpdef WindowHandle GetOuterWindowHandle(self) except *:
        if self.GetUserData("__outerWindowHandle"):
            return <WindowHandle>self.GetUserData("__outerWindowHandle")
        else:
            return self.GetWindowHandle()

    cpdef object GetUserData(self, object key):
        if key in self.userData:
            return self.userData[key]
        return None

    cpdef WindowHandle GetWindowHandle(self) except *:
        cdef WindowHandle hwnd
        IF CEF_VERSION == 1:
            hwnd = <WindowHandle>self.GetCefBrowser().get().GetWindowHandle()
        ELIF CEF_VERSION == 3:
            hwnd = <WindowHandle>self.GetCefBrowserHost().get().GetWindowHandle()
        return hwnd

    cpdef double GetZoomLevel(self) except *:
        IF CEF_VERSION == 1:
            assert IsThread(TID_UI), (
                    "Browser.GetZoomLevel() may only be called on UI thread")
        cdef double zoomLevel
        IF CEF_VERSION == 1:
            zoomLevel = self.GetCefBrowser().get().GetZoomLevel()
        ELIF CEF_VERSION == 3:
            zoomLevel = self.GetCefBrowserHost().get().GetZoomLevel()
        return zoomLevel

    cpdef py_void GoBack(self):
        self.GetCefBrowser().get().GoBack()

    cpdef py_void GoForward(self):
        self.GetCefBrowser().get().GoForward()

    cpdef py_bool HasDocument(self):
        return self.GetCefBrowser().get().HasDocument()

    IF CEF_VERSION == 1:
        cpdef py_void HidePopup(self):
            self.GetCefBrowser().get().HidePopup()

    cpdef py_bool IsFullscreen(self):
        return bool(self.isFullscreen)

    cpdef py_bool IsPopup(self):
        return self.GetCefBrowser().get().IsPopup()

    IF CEF_VERSION == 1:
        cpdef py_bool IsPopupVisible(self):
            assert IsThread(TID_UI), (
                    "Browser.IsPopupVisible() may only be called on UI thread")
            return self.GetCefBrowser().get().IsPopupVisible()

    cpdef py_bool IsWindowRenderingDisabled(self):
        IF CEF_VERSION == 1:
            return self.GetCefBrowser().get().IsWindowRenderingDisabled()
        ELIF CEF_VERSION == 3:
            return self.GetCefBrowserHost().get().IsWindowRenderingDisabled()

    cpdef py_void Navigate(self, py_string url):
        self.GetMainFrame().LoadUrl(url)

    cpdef py_void Reload(self):
        self.GetCefBrowser().get().Reload()

    cpdef py_void ReloadIgnoreCache(self):
        self.GetCefBrowser().get().ReloadIgnoreCache()

    cpdef py_void SetFocus(self, enable):
        IF CEF_VERSION == 1:
            self.GetCefBrowser().get().SetFocus(bool(enable))
        ELIF CEF_VERSION == 3:
            self.GetCefBrowserHost().get().SetFocus(bool(enable))

    cpdef py_void SetUserData(self, object key, object value):
        self.userData[key] = value

    cpdef py_void SetZoomLevel(self, double zoomLevel):
        IF CEF_VERSION == 1:
            self.GetCefBrowser().get().SetZoomLevel(zoomLevel)
        ELIF CEF_VERSION == 3:
            self.GetCefBrowserHost().get().SetZoomLevel(zoomLevel)

    IF CEF_VERSION == 1:

        cpdef py_void ShowDevTools(self):
            self.GetCefBrowser().get().ShowDevTools()

    cpdef py_void StopLoad(self):
        self.GetCefBrowser().get().StopLoad()

    IF CEF_VERSION == 1:

        cpdef py_void StopFinding(self, py_bool clearSelection):
            self.GetCefBrowser().get().StopFinding(bool(clearSelection))

    cpdef py_void ToggleFullscreen(self):
        IF UNAME_SYSNAME == "Windows":
            self.ToggleFullscreen_Windows()

    IF UNAME_SYSNAME == "Windows":

        cpdef py_void ToggleFullscreen_Windows(self):
            cdef WindowHandle windowHandle
            if self.GetUserData("__outerWindowHandle"):
                windowHandle = <WindowHandle>self.GetUserData("__outerWindowHandle")
            else:
                windowHandle = self.GetWindowHandle()

            # Offscreen browser will have an empty window handle.
            assert windowHandle, (
                    "Browser.ToggleFullscreen() failed: no window handle "
                    "found")

            cdef HWND hwnd = <HWND><int>int(windowHandle)
            cdef RECT rect
            cdef HMONITOR monitor
            cdef MONITORINFO monitorInfo
            monitorInfo.cbSize = sizeof(monitorInfo)

            # Logic copied from chromium > fullscreen_handler.cc >
            # FullscreenHandler::SetFullscreenImpl:
            # http://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/
            # fullscreen_handler.cc

            cdef py_bool for_metro = False

            if not self.isFullscreen:
                self.maximized = IsZoomed(hwnd)
                if self.maximized:
                    SendMessage(hwnd, WM_SYSCOMMAND, SC_RESTORE, 0)
                self.gwlStyle = GetWindowLong(hwnd, GWL_STYLE)
                self.gwlExStyle = GetWindowLong(hwnd, GWL_EXSTYLE)
                GetWindowRect(hwnd, &rect)
                self.windowRect = (rect.left, rect.top,
                                  rect.right, rect.bottom)

            cdef int removeStyle, removeExStyle
            cdef int left, top, right, bottom

            if not self.isFullscreen:
                removeStyle = WS_CAPTION | WS_THICKFRAME
                removeExStyle = (WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE
                        | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE)
                SetWindowLong(hwnd, GWL_STYLE,
                              self.gwlStyle & ~(removeStyle))
                SetWindowLong(hwnd, GWL_EXSTYLE,
                              self.gwlExStyle & ~(removeExStyle))

                if not for_metro:
                    # MONITOR_DEFAULTTONULL, MONITOR_DEFAULTTOPRIMARY,
                    # MONITOR_DEFAULTTONEAREST
                    monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST)
                    GetMonitorInfo(monitor, &monitorInfo)
                    left = monitorInfo.rcMonitor.left
                    top = monitorInfo.rcMonitor.top
                    right = monitorInfo.rcMonitor.right
                    bottom = monitorInfo.rcMonitor.bottom
                    SetWindowPos(hwnd, NULL,
                            left, top, right-left, bottom-top,
                            SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
            else:
                SetWindowLong(hwnd, GWL_STYLE, int(self.gwlStyle))
                SetWindowLong(hwnd, GWL_EXSTYLE, int(self.gwlExStyle))

                if not for_metro:
                    (left, top, right, bottom) = self.windowRect
                    SetWindowPos(hwnd, NULL,
                            int(left), int(top),
                            int(right-left), int(bottom-top),
                            SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)

                if self.maximized:
                    SendMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0)

            self.isFullscreen = int(not bool(self.isFullscreen))

    # Off-screen rendering.

    IF CEF_VERSION == 1:

        cpdef tuple GetSize(self, PaintElementType paintElementType):
            assert IsThread(TID_UI), (
                    "Browser.GetSize(): this method should only be called "
                    "on the UI thread")
            cdef int width = 0
            cdef int height = 0
            cdef cpp_bool ret = self.GetCefBrowser().get().GetSize(
                    paintElementType, width, height)
            if ret:
                return (width, height)
            else:
                return (0, 0)

        cpdef py_void SetSize(self, PaintElementType paintElementType,
                              int width, int height):
            self.GetCefBrowser().get().SetSize(paintElementType, width, height)

        cpdef py_void Invalidate(self, list dirtyRect):
            assert len(dirtyRect) == 4, (
                    "Browser.Invalidate() failed, dirtyRect is invalid")
            cdef CefRect cefRect = CefRect(
                    dirtyRect[0], dirtyRect[1], dirtyRect[2], dirtyRect[3])
            self.GetCefBrowser().get().Invalidate(cefRect)

    IF CEF_VERSION == 1 and UNAME_SYSNAME == "Windows":

        cpdef PaintBuffer GetImage(self, PaintElementType paintElementType,
                               int width, int height):
            assert IsThread(TID_UI), (
                    "Browser.GetImage(): this method should only be called "
                    "on the UI thread")

            IF UNAME_SYSNAME == "Windows":
                return self.GetImage_Windows(paintElementType, width, height)
            ELSE:
                return None

        cdef PaintBuffer GetImage_Windows(self,
                PaintElementType paintElementType, int width, int height):
            if not self.imageBuffer:
                self.imageBuffer = <void*>malloc(width*height*4)
            cdef cpp_bool ret = self.GetCefBrowser().get().GetImage(
                    paintElementType, width, height, self.imageBuffer)
            cdef PaintBuffer paintBuffer
            if ret:
                paintBuffer = CreatePaintBuffer(
                        self.imageBuffer, width, height)
                return paintBuffer
            else:
                return None

    # Sending mouse/key events.

    IF CEF_VERSION == 1:

        cpdef py_void SendKeyEvent(self, cef_types.cef_key_type_t keyType,
                tuple keyInfo, int modifiers):
            cdef CefKeyInfo cefKeyInfo
            IF UNAME_SYSNAME == "Windows":
                assert len(keyInfo) == 3, "Invalid keyInfo param"
                cefKeyInfo.key = keyInfo[0]
                cefKeyInfo.sysChar = keyInfo[1]
                cefKeyInfo.imeChar = keyInfo[2]
            ELIF UNAME_SYSNAME == "Darwin":
                cefKeyInfo.keyCode = keyInfo[0]
                cefKeyInfo.character = keyInfo[1]
                cefKeyInfo.characterNoModifiers = keyInfo[2]
            ELIF UNAME_SYSNAME == "Linux":
                cefKeyInfo.key = keyInfo[0]
            ELSE:
                raise Exception("Invalid UNAME_SYSNAME")

            self.GetCefBrowser().get().SendKeyEvent(keyType, cefKeyInfo,
                    modifiers)

        cpdef py_void SendMouseClickEvent(self, int x, int y,
                cef_types.cef_mouse_button_type_t mouseButtonType,
                py_bool mouseUp, int clickCount):
            self.GetCefBrowser().get().SendMouseClickEvent(x, y,
                    mouseButtonType, bool(mouseUp), clickCount)

        cpdef py_void SendMouseMoveEvent(self, int x, int y,
                py_bool mouseLeave):
            self.GetCefBrowser().get().SendMouseMoveEvent(x, y,
                    bool(mouseLeave))

        cpdef py_void SendMouseWheelEvent(self, int x, int y,
                int deltaX, int deltaY):
            self.GetCefBrowser().get().SendMouseWheelEvent(x, y,
                    deltaX, deltaY)

        cpdef py_void SendFocusEvent(self, py_bool setFocus):
            self.GetCefBrowser().get().SendFocusEvent(bool(setFocus))

        cpdef py_void SendCaptureLostEvent(self):
            self.GetCefBrowser().get().SendCaptureLostEvent()

    IF CEF_VERSION == 3:
        cpdef py_void StartDownload(self, py_string url):
            self.GetCefBrowserHost().get().StartDownload(PyToCefStringValue(
                    url))

        cpdef py_void SetMouseCursorChangeDisabled(self, py_bool disabled):
            self.GetCefBrowserHost().get().SetMouseCursorChangeDisabled(
                    bool(disabled))

        cpdef py_bool IsMouseCursorChangeDisabled(self):
            return self.GetCefBrowserHost().get().IsMouseCursorChangeDisabled()

        cpdef py_void WasResized(self):
            self.GetCefBrowserHost().get().WasResized()

        cpdef py_void WasHidden(self, py_bool hidden):
            self.GetCefBrowserHost().get().WasHidden(bool(hidden))

        cpdef py_void NotifyScreenInfoChanged(self):
            self.GetCefBrowserHost().get().NotifyScreenInfoChanged()

        # virtual CefTextInputContext GetNSTextInputContext() =0;
        # virtual void HandleKeyEventBeforeTextInputClient(CefEventHandle keyEvent) =0;
        # virtual void HandleKeyEventAfterTextInputClient(CefEventHandle keyEvent) =0;

        cdef void SendProcessMessage(self, cef_process_id_t targetProcess, 
                py_string messageName, list pyArguments
                ) except *:
            cdef CefRefPtr[CefProcessMessage] message = \
                    CefProcessMessage_Create(PyToCefStringValue(messageName))
            # This does not work, no idea why, the CEF implementation
            # seems not to allow it, both Assign() and swap() do not work:
            # | message.get().GetArgumentList().Assign(arguments.get())
            # | message.get().GetArgumentList().swap(arguments)
            cdef CefRefPtr[CefListValue] messageArguments = \
                    message.get().GetArgumentList()
            PyListToExistingCefListValue(pyArguments, messageArguments)
            Debug("SendProcessMessage(): message=%s, arguments size=%d" % (
                    messageName, 
                    message.get().GetArgumentList().get().GetSize()))
            cdef cpp_bool success = \
                    self.GetCefBrowser().get().SendProcessMessage(
                            targetProcess, message)
            if not success:
                raise Exception("Browser.SendProcessMessage() failed: "\
                        "messageName=%s" % messageName)
