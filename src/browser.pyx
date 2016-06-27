# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "cefpython.pyx"

cimport cef_types
IF UNAME_SYSNAME == "Linux":
    cimport x11

# cef_mouse_button_type_t, SendMouseClickEvent().
MOUSEBUTTON_LEFT = cef_types.MBT_LEFT
MOUSEBUTTON_MIDDLE = cef_types.MBT_MIDDLE
MOUSEBUTTON_RIGHT = cef_types.MBT_RIGHT

# If you try to keep PyBrowser() objects inside cpp_vector you will
# get segmentation faults, as they will be garbage collected.

cdef dict g_pyBrowsers = {}

cdef PyBrowser GetPyBrowserById(int browserId):
    if browserId in g_pyBrowsers:
        return g_pyBrowsers[browserId]
    return None

cdef PyBrowser GetPyBrowser(CefRefPtr[CefBrowser] cefBrowser):
    global g_pyBrowsers
    if <void*>cefBrowser == NULL or not cefBrowser.get():
        # noinspection PyUnresolvedReferences
        Debug("GetPyBrowser(): returning None")
        return None

    cdef PyBrowser pyBrowser
    cdef int browserId
    cdef int identifier

    browserId = cefBrowser.get().GetIdentifier()
    if browserId in g_pyBrowsers:
        return g_pyBrowsers[browserId]

    for identifier, pyBrowser in g_pyBrowsers.items():
        if not pyBrowser.cefBrowser.get():
            # noinspection PyUnresolvedReferences
            Debug("GetPyBrowser(): removing an empty CefBrowser reference, "
                  "browserId=%s" % identifier)
            del g_pyBrowsers[identifier]

    # noinspection PyUnresolvedReferences
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
        for identifier, tempPyBrowser in g_pyBrowsers.items():
            if tempPyBrowser.GetWindowHandle() == openerHandle:
                clientCallbacks = tempPyBrowser.GetClientCallbacksDict()
                if clientCallbacks:
                    pyBrowser.SetClientCallbacksDict(clientCallbacks)
                javascriptBindings = tempPyBrowser.GetJavascriptBindings()
                if javascriptBindings:
                    if javascriptBindings.GetBindToPopups():
                        pyBrowser.SetJavascriptBindings(javascriptBindings)
    return pyBrowser

cdef void RemovePyBrowser(int browserId) except *:
    # Called from LifespanHandler_OnBeforeClose().
    global g_pyBrowsers
    if browserId in g_pyBrowsers:
        if len(g_pyBrowsers) == 1:
            # This is the last browser remaining.
            if g_sharedRequestContext.get():
                # A similar release is done in Shutdown and CloseBrowser.
                # noinspection PyUnresolvedReferences
                Debug("RemovePyBrowser: releasing shared request context")
                g_sharedRequestContext.Assign(NULL)
        # noinspection PyUnresolvedReferences
        Debug("del g_pyBrowsers[%s]" % browserId)
        del g_pyBrowsers[browserId]
    else:
        # noinspection PyUnresolvedReferences
        Debug("RemovePyBrowser() FAILED: browser not found, id = %s" \
                % browserId)

cpdef PyBrowser GetBrowserByWindowHandle(WindowHandle windowHandle):
    cdef PyBrowser pyBrowser
    for browserId in g_pyBrowsers:
        pyBrowser = g_pyBrowsers[browserId]
        if (pyBrowser.GetWindowHandle() == windowHandle or
                pyBrowser.GetUserData("__outerWindowHandle") == long(windowHandle)):
            return pyBrowser
    return None

cdef public void PyBrowser_ShowDevTools(CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    # Called from ClientHandler::OnContextMenuCommand
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyBrowser.ShowDevTools()
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

# -----------------------------------------------------------------------------

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
            # DisplayHandler
            self.allowedClientCallbacks += [
                    "OnAddressChange", "OnTitleChange", "OnTooltip",
                    "OnStatusMessage", "OnConsoleMessage"]
            # KeyboardHandler
            self.allowedClientCallbacks += ["OnPreKeyEvent", "OnKeyEvent"]
            # RequestHandler
            # NOTE: OnCertificateError and OnBeforePluginLoad are not
            #       included as they must be set using
            #       cefpython.SetGlobalClientCallback().
            self.allowedClientCallbacks += ["OnBeforeResourceLoad",
                    "OnResourceRedirect", "GetAuthCredentials",
                    "OnQuotaRequest", "OnProtocolExecution",
                    "GetResourceHandler",
                    "OnBeforeBrowse", "OnRendererProcessTerminated",
                    "OnPluginCrashed"]
            # RequestContextHandler
            self.allowedClientCallbacks += ["GetCookieManager"]
            # LoadHandler
            self.allowedClientCallbacks += ["OnLoadingStateChange",
                    "OnLoadStart", "OnLoadEnd", "OnLoadError"]
            # LifespanHandler
            # NOTE: OnAfterCreated not included as it must be set using
            #       cefpython.SetGlobalClientCallback().
            self.allowedClientCallbacks += ["OnBeforePopup",
                    "DoClose", "OnBeforeClose"]
            # RenderHandler
            self.allowedClientCallbacks += ["GetRootScreenRect",
                    "GetViewRect", "GetScreenPoint", "GetScreenInfo",
                    "OnPopupShow", "OnPopupSize", "OnPaint", "OnCursorChange",
                    "OnScrollOffsetChanged"]
            # JavascriptDialogHandler
            self.allowedClientCallbacks += ["OnJavascriptDialog",
                    "OnBeforeUnloadJavascriptDialog",
                    "OnResetJavascriptDialogState",
                    "OnJavascriptDialogClosed"]

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

    cpdef py_void ParentWindowWillClose(self):
        # Method removed in upstream CEF, keeping for BC
        pass

    cpdef py_void CloseBrowser(self, py_bool forceClose=False):
        if len(g_pyBrowsers) == 1:
            # This is the last browser remaining.
            if g_sharedRequestContext.get():
                # A similar release is done in Shutdown
                # and RemovePyBrowser.
                Debug("CloseBrowser: releasing shared request context")
                g_sharedRequestContext.Assign(NULL)
        Debug("CefBrowser::CloseBrowser(%s)" % forceClose)
        self.GetCefBrowserHost().get().CloseBrowser(bool(forceClose))

    cpdef py_void CloseDevTools(self):
        self.GetCefBrowserHost().get().CloseDevTools()

    def ExecuteFunction(self, *args):
        self.GetMainFrame().ExecuteFunction(*args)

    cpdef py_void ExecuteJavascript(self, py_string jsCode,
            py_string scriptUrl="", int startLine=0):
        self.GetMainFrame().ExecuteJavascript(jsCode, scriptUrl, startLine)

    cpdef py_void Find(self, int searchId, py_string searchText,
                       py_bool forward, py_bool matchCase,
                       py_bool findNext):
        cdef CefString cefSearchText
        PyToCefString(searchText, cefSearchText)
        self.GetCefBrowserHost().get().Find(searchId, cefSearchText,
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
        hwnd = <WindowHandle> \
                self.GetCefBrowserHost().get().GetOpenerWindowHandle()
        return hwnd

    cpdef WindowHandle GetOuterWindowHandle(self) except *:
        if self.GetUserData("__outerWindowHandle"):
            return <WindowHandle>self.GetUserData("__outerWindowHandle")
        else:
            return self.GetWindowHandle()

    cpdef py_string GetUrl(self):
        return self.GetMainFrame().GetUrl()

    cpdef object GetUserData(self, object key):
        if key in self.userData:
            return self.userData[key]
        return None

    cpdef WindowHandle GetWindowHandle(self) except *:
        cdef WindowHandle hwnd
        hwnd = <WindowHandle>self.GetCefBrowserHost().get().GetWindowHandle()
        return hwnd

    cpdef double GetZoomLevel(self) except *:
        cdef double zoomLevel
        zoomLevel = self.GetCefBrowserHost().get().GetZoomLevel()
        return zoomLevel

    cpdef py_void GoBack(self):
        self.GetCefBrowser().get().GoBack()

    cpdef py_void GoForward(self):
        self.GetCefBrowser().get().GoForward()

    cpdef py_bool HasDocument(self):
        return self.GetCefBrowser().get().HasDocument()

    cpdef py_bool IsFullscreen(self):
        return bool(self.isFullscreen)

    cpdef py_bool IsPopup(self):
        return self.GetCefBrowser().get().IsPopup()

    cpdef py_bool IsWindowRenderingDisabled(self):
        return self.GetCefBrowserHost().get().IsWindowRenderingDisabled()

    cpdef py_string LoadUrl(self, py_string url):
        self.GetMainFrame().LoadUrl(url)

    cpdef py_void Navigate(self, py_string url):
        self.LoadUrl(url)

    cpdef py_void NotifyMoveOrResizeStarted(self):
        self.GetCefBrowserHost().get().NotifyMoveOrResizeStarted()

    cpdef py_void Print(self):
        self.GetCefBrowserHost().get().Print()

    cpdef py_void Reload(self):
        self.GetCefBrowser().get().Reload()

    cpdef py_void ReloadIgnoreCache(self):
        self.GetCefBrowser().get().ReloadIgnoreCache()

    cpdef py_void SetBounds(self, int x, int y, int width, int height):
        if platform.system() == "Linux":
            x11.SetX11WindowBounds(self.GetCefBrowser(), x, y, width, height)
        else:
            raise Exception("SetBounds() not impplemented on this platform")

    cpdef py_void SetFocus(self, enable):
        self.GetCefBrowserHost().get().SetFocus(bool(enable))

    cpdef py_void SetUserData(self, object key, object value):
        self.userData[key] = value

    cpdef py_void SetZoomLevel(self, double zoomLevel):
        self.GetCefBrowserHost().get().SetZoomLevel(zoomLevel)

    cpdef py_void ShowDevTools(self):
        cdef CefWindowInfo windowInfo
        cdef CefRefPtr[ClientHandler] clientHandler =\
                <CefRefPtr[ClientHandler]?>new ClientHandler()
        cdef CefBrowserSettings settings
        cdef CefPoint inspect_element_at
        self.GetCefBrowserHost().get().ShowDevTools(
                windowInfo, <CefRefPtr[CefClient]?>clientHandler, settings,
                inspect_element_at)

    cpdef py_void StopLoad(self):
        self.GetCefBrowser().get().StopLoad()

    cpdef py_void StopFinding(self, py_bool clearSelection):
        self.GetCefBrowserHost().get().StopFinding(bool(clearSelection))

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
                              self.gwlStyle & ~removeStyle)
                SetWindowLong(hwnd, GWL_EXSTYLE,
                              self.gwlExStyle & ~removeExStyle)

                if not for_metro:
                    # MONITOR_DEFAULTTONULL, MONITOR_DEFAULTTOPRIMARY,
                    # MONITOR_DEFAULTTONEAREST
                    monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST)
                    GetMonitorInfo(monitor, &monitorInfo)
                    left = monitorInfo.rcMonitor.left
                    top = monitorInfo.rcMonitor.top
                    right = monitorInfo.rcMonitor.right
                    bottom = monitorInfo.rcMonitor.bottom
                    # noinspection PyUnresolvedReferences
                    SetWindowPos(hwnd, NULL,
                            left, top, right-left, bottom-top,
                            SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
            else:
                SetWindowLong(hwnd, GWL_STYLE, int(self.gwlStyle))
                SetWindowLong(hwnd, GWL_EXSTYLE, int(self.gwlExStyle))

                if not for_metro:
                    (left, top, right, bottom) = self.windowRect
                    # noinspection PyUnresolvedReferences
                    SetWindowPos(hwnd, NULL,
                            int(left), int(top),
                            int(right-left), int(bottom-top),
                            SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)

                if self.maximized:
                    SendMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0)

            self.isFullscreen = int(not bool(self.isFullscreen))

    cpdef py_void SendKeyEvent(self, dict pyEvent):
        cdef CefKeyEvent cefEvent
        if "type" in pyEvent:
            cefEvent.type = int(pyEvent["type"])
        if "modifiers" in pyEvent:
            cefEvent.modifiers = long(pyEvent["modifiers"])
        if ("windows_key_code" in pyEvent) and UNAME_SYSNAME == "Windows":
            cefEvent.windows_key_code = int(pyEvent["windows_key_code"])
        if "native_key_code" in pyEvent:
            cefEvent.native_key_code = int(pyEvent["native_key_code"])
        if "is_system_key" in pyEvent:
            cefEvent.is_system_key = int(pyEvent["is_system_key"])
        if "character" in pyEvent:
            cefEvent.character = int(pyEvent["character"])
        if "unmodified_character" in pyEvent:
            cefEvent.unmodified_character = \
                    int(pyEvent["unmodified_character"])
        if "focus_on_editable_field" in pyEvent:
            cefEvent.focus_on_editable_field = \
                    int(pyEvent["focus_on_editable_field"])
        self.GetCefBrowserHost().get().SendKeyEvent(cefEvent)

    cpdef py_void SendMouseClickEvent(self, int x, int y,
            cef_types.cef_mouse_button_type_t mouseButtonType,
            py_bool mouseUp, int clickCount, int modifiers=0):
        cdef CefMouseEvent mouseEvent
        mouseEvent.x = x
        mouseEvent.y = y
        mouseEvent.modifiers = modifiers
        self.GetCefBrowserHost().get().SendMouseClickEvent(mouseEvent,
                mouseButtonType, bool(mouseUp), clickCount)

    cpdef py_void SendMouseMoveEvent(self, int x, int y,
            py_bool mouseLeave, int modifiers=0):
        cdef CefMouseEvent mouseEvent
        mouseEvent.x = x
        mouseEvent.y = y
        mouseEvent.modifiers = modifiers
        self.GetCefBrowserHost().get().SendMouseMoveEvent(mouseEvent,
                bool(mouseLeave))

    cpdef py_void SendMouseWheelEvent(self, int x, int y,
            int deltaX, int deltaY, int modifiers=0):
        cdef CefMouseEvent mouseEvent
        mouseEvent.x = x
        mouseEvent.y = y
        mouseEvent.modifiers = modifiers
        self.GetCefBrowserHost().get().SendMouseWheelEvent(mouseEvent,
                deltaX, deltaY)

    cpdef py_void SendFocusEvent(self, py_bool setFocus):
        self.GetCefBrowserHost().get().SendFocusEvent(bool(setFocus))

    cpdef py_void SendCaptureLostEvent(self):
        self.GetCefBrowserHost().get().SendCaptureLostEvent()

    cpdef py_void StartDownload(self, py_string url):
        self.GetCefBrowserHost().get().StartDownload(PyToCefStringValue(
                url))

    cpdef py_void SetMouseCursorChangeDisabled(self, py_bool disabled):
        self.GetCefBrowserHost().get().SetMouseCursorChangeDisabled(
                bool(disabled))

    cpdef py_bool IsMouseCursorChangeDisabled(self):
        return self.GetCefBrowserHost().get().IsMouseCursorChangeDisabled()

    cpdef py_bool TryCloseBrowser(self):
        return self.GetCefBrowserHost().get().TryCloseBrowser()

    cpdef py_void WasResized(self):
        self.GetCefBrowserHost().get().WasResized()

    cpdef py_void WasHidden(self, py_bool hidden):
        self.GetCefBrowserHost().get().WasHidden(bool(hidden))

    cpdef py_void NotifyScreenInfoChanged(self):
        self.GetCefBrowserHost().get().NotifyScreenInfoChanged()

    cdef void SendProcessMessage(self, cef_process_id_t targetProcess,
            object frameId, py_string messageName, list pyArguments
            ) except *:
        cdef CefRefPtr[CefProcessMessage] message = \
                CefProcessMessage_Create(PyToCefStringValue(messageName))
        # This does not work, no idea why, the CEF implementation
        # seems not to allow it, both Assign() and swap() do not work:
        # | message.get().GetArgumentList().Assign(arguments.get())
        # | message.get().GetArgumentList().swap(arguments)
        cdef CefRefPtr[CefListValue] messageArguments = \
                message.get().GetArgumentList()
        PyListToExistingCefListValue(self.GetIdentifier(), frameId,
                pyArguments, messageArguments)
        Debug("SendProcessMessage(): message=%s, arguments size=%d" % (
                messageName,
                message.get().GetArgumentList().get().GetSize()))
        cdef cpp_bool success = \
                self.GetCefBrowser().get().SendProcessMessage(
                        targetProcess, message)
        if not success:
            raise Exception("Browser.SendProcessMessage() failed: "\
                    "messageName=%s" % messageName)
