# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# If you try to keep PyBrowser() objects inside c_vector you will
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
            Debug("GetPyBrowser(): removing an empty CefBrowser reference, browserId=%s" % id)
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

    if pyBrowser.IsPopup() and (
    not pyBrowser.GetUserData("__outerWindowHandle")):
        openerHandle = pyBrowser.GetOpenerWindowHandle()
        for id, tempPyBrowser in g_pyBrowsers.items():
            if tempPyBrowser.GetWindowHandle() == openerHandle:
                clientCallbacks = tempPyBrowser.GetClientCallbacksDict()
                if clientCallbacks:
                    pyBrowser.SetClientCallbacksDict(clientCallbacks)
                javascriptBindings = tempPyBrowser.GetJavascriptBindings()
                if javascriptBindings.GetBindToPopups():
                    pyBrowser.SetJavascriptBindings(javascriptBindings)

    return pyBrowser

cpdef PyBrowser GetBrowserByWindowHandle(int windowHandle):
    cdef PyBrowser pyBrowser
    for browserId in g_pyBrowsers:
        pyBrowser = g_pyBrowsers[browserId]
        if (pyBrowser.GetWindowHandle() == windowHandle or
                pyBrowser.GetUserData("__outerWindowHandle") == windowHandle):
            return pyBrowser
    return None

IF CEF_VERSION == 3:

    cdef CefRefPtr[CefBrowserHost] GetCefBrowserHost(
            CefRefPtr[CefBrowser] cefBrowser) except *:
        cdef CefRefPtr[CefBrowserHost] cefBrowserHost = cefBrowser.get().GetHost()
        if <void*>cefBrowserHost != NULL and cefBrowserHost.get():
            return cefBrowserHost
        raise Exception("GetCefBrowserHost() failed: this method of Browser object "
                        "can only be called in the browser process.")

cdef class PyBrowser:
    cdef CefRefPtr[CefBrowser] cefBrowser

    cdef public dict clientCallbacks
    cdef public list allowedClientCallbacks
    IF CEF_VERSION == 1:
        cdef public JavascriptBindings javascriptBindings
    cdef public dict userData

    # Properties used by ToggleFullscreen().
    cdef public int isFullscreen
    cdef public int maximized
    cdef public int gwlStyle
    cdef public int gwlExStyle
    cdef public tuple windowRect

    cdef CefRefPtr[CefBrowser] GetCefBrowser(self) except *:
        if <void*>self.cefBrowser != NULL and self.cefBrowser.get():
            return self.cefBrowser
        raise Exception("PyBrowser.GetCefBrowser() failed: CefBrowser was destroyed")

    IF CEF_VERSION == 3:

        cdef CefRefPtr[CefBrowserHost] GetCefBrowserHost(self) except *:
            cdef CefRefPtr[CefBrowserHost] cefBrowserHost = self.GetCefBrowser().get().GetHost()
            if <void*>cefBrowserHost != NULL and cefBrowserHost.get():
                return cefBrowserHost
            raise Exception("PyBrowser.GetCefBrowserHost() failed: this method "
                            "can only be called in the browser process.")

    def __init__(self):
        self.clientCallbacks = {}
        self.allowedClientCallbacks = []
        self.userData = {}

    cpdef py_void SetClientCallback(self, py_string name, object callback):
        if not self.allowedClientCallbacks:
            # CefLoadHandler.
            self.allowedClientCallbacks += ["OnLoadEnd", "OnLoadError", "OnLoadStart"]

            # CefKeyboardHandler.
            self.allowedClientCallbacks += ["OnKeyEvent"]

            # CefV8ContextHandler.
            self.allowedClientCallbacks += ["OnUncaughtException"]

            # CefRequestHandler.
            self.allowedClientCallbacks += ["OnBeforeBrowse", "OnBeforeResourceLoad",
                    "OnResourceRedirect", "OnResourceResponse", "OnProtocolExecution",
                    "GetDownloadHandler", "GetAuthCredentials", "GetCookieManager"]

            # CefDisplayHandler.
            self.allowedClientCallbacks += ["OnAddressChange", "OnConsoleMessage",
                    "OnContentsSizeChange", "OnNavStateChange", "OnStatusMessage",
                    "OnTitleChange", "OnTooltip"]

            # LifespanHandler.
            self.allowedClientCallbacks += ["DoClose", "OnAfterCreated", "OnBeforeClose",
                    "RunModal"]

        if name not in self.allowedClientCallbacks:
            raise Exception("Browser.SetClientCallback() failed: unknown callback: %s" % name)

        self.clientCallbacks[name] = callback

    cpdef py_void SetClientHandler(self, object clientHandler):
        if not hasattr(clientHandler, "__class__"):
            raise Exception("Browser.SetClientHandler() failed: __class__ attribute missing")
        cdef dict methods = {}
        cdef py_string key
        cdef object method
        cdef tuple value
        for value in inspect.getmembers(clientHandler, predicate=inspect.ismethod):
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

    IF CEF_VERSION == 1:

        cpdef py_void SetJavascriptBindings(self, JavascriptBindings bindings):
            self.javascriptBindings = bindings

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

    cpdef py_void CloseBrowser(self):
        # In cefclient/cefclient_win.cpp there is only ParentWindowWillClose() called.
        # CloseBrowser() is called only for popups.
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
                self.GetCefBrowserHost().get().CloseBrowser()

    IF CEF_VERSION == 1:

        cpdef py_void CloseDevTools(self):
            self.GetCefBrowser().get().CloseDevTools()

        cpdef py_void Find(self, int searchId, py_string searchText, py_bool forward,
                          py_bool matchCase, py_bool findNext):
            cdef CefString cefSearchText
            PyToCefString(searchText, cefSearchText)
            self.GetCefBrowser().get().Find(searchId, cefSearchText, bool(forward),
                                            bool(matchCase), bool(findNext))

    cpdef PyFrame GetFocusedFrame(self):
        assert IsCurrentThread(TID_UI), "Browser.GetFocusedFrame() may only be called on the UI thread"
        return GetPyFrame(self.GetCefBrowser().get().GetFocusedFrame())

    cpdef PyFrame GetFrame(self, py_string name):
        assert IsCurrentThread(TID_UI), "Browser.GetFrame() may only be called on the UI thread"
        cdef CefString cefName
        PyToCefString(name, cefName)
        return GetPyFrame(self.GetCefBrowser().get().GetFrame(cefName))

    cpdef list GetFrameNames(self):
        assert IsCurrentThread(TID_UI), "Browser.GetFrameNames() may only be called on the UI thread"
        cdef c_vector[CefString] cefNames
        self.GetCefBrowser().get().GetFrameNames(cefNames)
        cdef list names = []
        cdef c_vector[CefString].iterator iterator = cefNames.begin()
        cdef CefString cefString
        while iterator != cefNames.end():
            cefString = deref(iterator)
            names.append(CefToPyString(cefString))
            preinc(iterator)
        return names

    cpdef PyFrame GetMainFrame(self):
        return GetPyFrame(self.GetCefBrowser().get().GetMainFrame())

    cpdef int GetOpenerWindowHandle(self) except *:
        cdef HWND hwnd
        IF CEF_VERSION == 1:
            hwnd = self.GetCefBrowser().get().GetOpenerWindowHandle()
        ELIF CEF_VERSION == 3:
            hwnd = self.GetCefBrowserHost().get().GetOpenerWindowHandle()
        return <int>hwnd

    cpdef int GetOuterWindowHandle(self) except *:
        if self.GetUserData("__outerWindowHandle"):
            return int(self.GetUserData("__outerWindowHandle"))
        else:
            return self.GetWindowHandle()

    cpdef object GetUserData(self, object key):
        if key in self.userData:
            return self.userData[key]
        return None

    cpdef int GetWindowHandle(self) except *:
        cdef HWND hwnd
        IF CEF_VERSION == 1:
            hwnd = self.GetCefBrowser().get().GetWindowHandle()
        ELIF CEF_VERSION == 3:
            hwnd = self.GetCefBrowserHost().get().GetWindowHandle()
        return <int>hwnd

    cpdef double GetZoomLevel(self) except *:
        IF CEF_VERSION == 1:
            assert IsCurrentThread(TID_UI), "Browser.GetZoomLevel() may only be called on the UI thread"
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
            assert IsCurrentThread(TID_UI), "Browser.IsPopupVisible() may only be called on the UI thread"
            return self.GetCefBrowser().get().IsPopupVisible()

        cpdef py_bool IsWindowRenderingDisabled(self):
            return self.GetCefBrowser().get().IsWindowRenderingDisabled()

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

    cpdef py_void ToggleFullscreen_Windows(self):
        cdef int windowHandle
        if self.GetUserData("__outerWindowHandle"):
            windowHandle = self.GetUserData("__outerWindowHandle")
        else:
            windowHandle = self.GetWindowHandle()

        # Offscreen browser will have an empty window handle.
        assert windowHandle, "Browser.ToggleFullscreen() failed: no window handle found"

        cdef HWND hwnd = <HWND><int>int(windowHandle)
        cdef RECT rect
        cdef HMONITOR monitor
        cdef MONITORINFO monitorInfo
        monitorInfo.cbSize = sizeof(monitorInfo)

        # Logic copied from chromium > fullscreen_handler.cc >
        # FullscreenHandler::SetFullscreenImpl:
        # http://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc

        cdef py_bool for_metro = False

        if not self.isFullscreen:
            self.maximized = IsZoomed(hwnd)
            if self.maximized:
                SendMessage(hwnd, WM_SYSCOMMAND, SC_RESTORE, 0)
            self.gwlStyle = GetWindowLong(hwnd, GWL_STYLE)
            self.gwlExStyle = GetWindowLong(hwnd, GWL_EXSTYLE)
            GetWindowRect(hwnd, &rect)
            self.windowRect = (rect.left, rect.top, rect.right, rect.bottom)

        cdef int removeStyle, removeExStyle
        cdef int left, top, right, bottom

        if not self.isFullscreen:
            removeStyle = WS_CAPTION | WS_THICKFRAME
            removeExStyle = (WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE
                    | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE)
            SetWindowLong(hwnd, GWL_STYLE, self.gwlStyle & ~(removeStyle))
            SetWindowLong(hwnd, GWL_EXSTYLE, self.gwlExStyle & ~(removeExStyle))

            if not for_metro:
                # MONITOR_DEFAULTTONULL, MONITOR_DEFAULTTOPRIMARY, MONITOR_DEFAULTTONEAREST
                monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST)
                GetMonitorInfo(monitor, &monitorInfo)
                left = monitorInfo.rcMonitor.left
                top = monitorInfo.rcMonitor.top
                right = monitorInfo.rcMonitor.right
                bottom = monitorInfo.rcMonitor.bottom
                SetWindowPos(hwnd, NULL, left, top, right-left, bottom-top,
                        SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
        else:
            SetWindowLong(hwnd, GWL_STYLE, int(self.gwlStyle))
            SetWindowLong(hwnd, GWL_EXSTYLE, int(self.gwlExStyle))

            if not for_metro:
                (left, top, right, bottom) = self.windowRect
                SetWindowPos(hwnd, NULL, int(left), int(top), int(right-left), int(bottom-top),
                        SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)

            if self.maximized:
                SendMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0)

        self.isFullscreen = int(not bool(self.isFullscreen))
