# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cimport cef_types
from libc.stdint cimport uint32_t, int64_t
from libcpp cimport nullptr
from cef_types cimport cef_state_t
IF UNAME_SYSNAME == "Linux":
    cimport x11

# cef_mouse_button_type_t, SendMouseClickEvent().
MOUSEBUTTON_LEFT = cef_types.MBT_LEFT
MOUSEBUTTON_MIDDLE = cef_types.MBT_MIDDLE
MOUSEBUTTON_RIGHT = cef_types.MBT_RIGHT

# If you try to keep PyBrowser() objects inside cpp_vector you will
# get segmentation faults, as they will be garbage collected.

cdef dict g_pyBrowsers = {}

# See also g_browser_settings defined in cefpython.pyx

# Unreferenced browsers are added to this list in OnBeforeClose().
# Must keep a list of unreferenced browsers so that a new reference
# is not created in GetPyBrowser() when browser was closed.
cdef list g_unreferenced_browsers = []  # [int identifier, ..]

# Browsers that are about to be closed are added to this list in
# CloseBrowser().
cdef list g_closed_browsers = []  # [int identifier, ..]

cdef PyBrowser GetPyBrowserById(int browserId):
    """May return None value so always check returned value."""
    if browserId in g_pyBrowsers:
        return g_pyBrowsers[browserId]
    return None

cdef py_bool IsBrowserClosed(CefRefPtr[CefBrowser] cefBrowser):
    """Possibly fix Issue #455 by using this helper function to detect
    if browser is closing/closed."""
    # CefBrowser may sometimes be NULL e.g. Issue #429, Issue #454.
    if not cefBrowser.get():
        return True
    if not cefBrowser.get().GetHost().get():
        return True
    cdef int browserId = cefBrowser.get().GetIdentifier()
    if browserId in g_unreferenced_browsers \
            or browserId in g_closed_browsers:
        return True
    return False

cdef PyBrowser GetPyBrowser(CefRefPtr[CefBrowser] cefBrowser,
                                    callerIdStr="GetPyBrowser"):
    """The second argument 'callerIdStr' is so that a debug
    message can be displayed informing which CEF handler callback
    is being called to which an incomplete PyBrowser instance is
    provided."""

    global g_pyBrowsers

    if not cefBrowser or not cefBrowser.get():
        raise Exception("{caller}: CefBrowser reference is NULL"
                        .format(caller=callerIdStr))

    cdef PyBrowser pyBrowser
    cdef int browserId
    browserId = cefBrowser.get().GetIdentifier()

    if browserId in g_pyBrowsers:
        return g_pyBrowsers[browserId]

    # This code probably ain't needed.
    # ----
    cdef list toRemove = []
    cdef int identifier
    for identifier, pyBrowser in g_pyBrowsers.items():
        if not pyBrowser.cefBrowser.get():
            toRemove.append(identifier)
    for identifier in toRemove:
        Debug("GetPyBrowser(): removing an empty CefBrowser reference,"
              " browserId=%s" % identifier)
        RemovePyBrowser(identifier)
    # ----

    pyBrowser = PyBrowser()
    pyBrowser.cefBrowser = cefBrowser

    cdef WindowHandle openerHandle
    cdef dict clientCallbacks
    cdef JavascriptBindings javascriptBindings
    cdef PyBrowser tempPyBrowser

    if browserId in g_unreferenced_browsers \
            or browserId in g_closed_browsers:
        # This browser was already unreferenced due to OnBeforeClose
        # was already called. An incomplete new instance of Browser
        # object is created. This instance doesn't have the client
        # callbacks, javascript bindings or user data that was already
        # available in the original Browser object.
        Debug("{caller}: Browser was already globally unreferenced"
              ", a new incomplete instance is created, browser id={id}"
              .format(caller=callerIdStr, id=str(browserId)))
    else:
        # This is first creation of browser. Store a reference globally
        # and inherit client callbacks and javascript bindings from
        # parent browsers.
        Debug("GetPyBrowser(): create new PyBrowser, browserId=%s"
              % browserId)

        g_pyBrowsers[browserId] = pyBrowser

        # Inherit client callbacks and javascript bindings
        # from parent browser.
        # - Checking __outerWindowHandle as we should not inherit
        #   client callbacks and javascript bindings if the browser
        #   was created explicitily by calling CreateBrowserSync().
        # - Popups inherit client callbacks by default.
        # - Popups inherit javascript bindings only when "bindToPopups"
        #   constructor param was set to True.

        if pyBrowser.IsPopup()\
                and not pyBrowser.GetUserData("__outerWindowHandle"):
            openerHandle = pyBrowser.GetOpenerWindowHandle()
            for identifier, tempPyBrowser in g_pyBrowsers.items():
                if tempPyBrowser.GetWindowHandle() == openerHandle:
                    # tempPyBrowser is a parent browser
                    if tempPyBrowser.GetSetting("inherit_client_handlers_for_popups"):
                        if pyBrowser.GetIdentifier() not in g_browser_settings:
                            g_browser_settings[pyBrowser.GetIdentifier()] = {}
                        g_browser_settings[pyBrowser.GetIdentifier()]["inherit_client_handlers_for_popups"] =\
                            tempPyBrowser.GetSetting("inherit_client_handlers_for_popups")
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
    global g_pyBrowsers, g_unreferenced_browsers
    cdef PyBrowser pyBrowser
    if browserId in g_pyBrowsers:
        # noinspection PyUnresolvedReferences
        Debug("del g_pyBrowsers[%s]" % browserId)
        pyBrowser = g_pyBrowsers[browserId]
        pyBrowser.cefBrowser.Assign(nullptr)
        del pyBrowser
        del g_pyBrowsers[browserId]
        g_unreferenced_browsers.append(browserId)
    else:
        # noinspection PyUnresolvedReferences
        Debug("RemovePyBrowser() FAILED: browser not found, id = %s" \
                % browserId)

cpdef PyBrowser GetBrowserByWindowHandle(WindowHandle windowHandle):
    cdef PyBrowser pyBrowser
    for browserId in g_pyBrowsers:
        pyBrowser = g_pyBrowsers[browserId]
        if (pyBrowser.GetWindowHandle() == windowHandle or
                pyBrowser.GetUserData("__outerWindowHandle") == windowHandle):
            return pyBrowser
    return None


cpdef PyBrowser GetBrowserByIdentifier(int identifier):
    cdef PyBrowser pyBrowser
    for browserId in g_pyBrowsers:
        pyBrowser = g_pyBrowsers[browserId]
        if pyBrowser.GetIdentifier() == identifier:
            return pyBrowser
    return None

cdef public void PyBrowser_ShowDevTools(CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    # Called from ClientHandler::OnContextMenuCommand
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "ShowDevTools")
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
        if self.cefBrowser and self.cefBrowser.get():
            return self.cefBrowser
        raise Exception("PyBrowser.GetCefBrowser() failed: CefBrowser "
                        "was destroyed")

    cdef CefRefPtr[CefBrowserHost] GetCefBrowserHost(self) except *:
        cdef CefRefPtr[CefBrowserHost] cefBrowserHost = (
                self.GetCefBrowser().get().GetHost())
        if cefBrowserHost and cefBrowserHost.get():
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
                    "OnStatusMessage", "OnConsoleMessage", "OnAutoResize",
                    "OnLoadingProgressChange"]
            # KeyboardHandler
            self.allowedClientCallbacks += ["OnPreKeyEvent", "OnKeyEvent"]
            # RequestHandler
            # NOTE: OnCertificateError and OnBeforePluginLoad are not
            #       included as they must be set using
            #       cefpython.SetGlobalClientCallback().
            self.allowedClientCallbacks += ["OnBeforeResourceLoad",
                    "OnResourceRedirect", "GetAuthCredentials",
                    "OnQuotaRequest", "OnProtocolExecution",
                    "GetResourceHandler", "OnBeforeBrowse", 
                    "OnRendererProcessTerminated",
                    "CanSendCookie", "CanSaveCookie"]
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
                    "GetScreenRect",
                    "OnPopupShow", "OnPopupSize", "OnPaint", "OnCursorChange",
                    "OnScrollOffsetChanged",
                    "StartDragging", "UpdateDragCursor",
                    "OnTextSelectionChanged"]
            # V8ContextHandler
            self.allowedClientCallbacks += ["OnContextCreated",
                    "OnContextReleased"]
            # JavascriptDialogHandler
            self.allowedClientCallbacks += ["OnJavascriptDialog",
                    "OnBeforeUnloadJavascriptDialog",
                    "OnResetJavascriptDialogState",
                    "OnJavascriptDialogClosed"]
            # FocusHandler
            self.allowedClientCallbacks += ["OnTakeFocus", "OnSetFocus",
                                            "OnGotFocus"]

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

    cdef bytes b(self, int x):
        return struct.pack(b'<B', x)

    cpdef object GetImage(self):
        IF UNAME_SYSNAME == "Linux":
            cdef XImage* image
            image = x11.CefBrowser_GetImage(self.cefBrowser)
            if not image:
                return None
            cdef int width = image.width
            cdef int height = image.height
            cdef list pixels = [b'0'] * (3 * width * height)
            cdef int x, y, blue, green, red, offset
            cdef unsigned long pixel
            for x in range(width):
                for y in range(height):
                    pixel = XGetPixel(image, x, y)
                    blue = pixel & 255
                    green = (pixel & 65280) >> 8
                    red = (pixel & 16711680) >> 16
                    offset = (x + width * y) * 3
                    pixels[offset:offset+3] = self.b(red), self.b(green),\
                                              self.b(blue)
            XDestroyImage(image)
            return b''.join(pixels), width, height
        ELSE:
            NonCriticalError("GetImage not implemented on this platform")
            return None

    cpdef object GetSetting(self, py_string key):
        cdef int browser_id = self.GetIdentifier()
        if browser_id in g_browser_settings:
            if key in g_browser_settings[browser_id]:
                return g_browser_settings[browser_id][key]
        return None

    # --------------
    # CEF API.
    # --------------

    cpdef py_void AddWordToDictionary(self, py_string word):
        cdef CefString cef_word
        PyToCefString(word, cef_word)
        self.GetCefBrowserHost().get().AddWordToDictionary(cef_word)

    cpdef py_bool CanGoBack(self):
        return self.GetCefBrowser().get().CanGoBack()

    cpdef py_bool CanGoForward(self):
        return self.GetCefBrowser().get().CanGoForward()

    cpdef py_void ParentWindowWillClose(self):
        # Method removed in upstream CEF, keeping for BC
        pass

    cpdef py_void CloseBrowser(self, py_bool forceClose=False):
        # Browser can be closed in two ways. Either by calling
        # CloseBrowser explicitilly or by destroying window
        # object and in such case lifespanHandler.OnBeforeClose
        # will be called.
        Debug("CefBrowser::CloseBrowser(%s)" % forceClose)

        # Fix Issue #454 "Crash on exit when closing browser
        #                 immediately during initial loading".
        if not self.cefBrowser.get():
            Debug("cefBrowser.get() failed in CloseBrowser")
            return
        # From testing it seems that only cefBrowser.get() can fail,
        # however let's check the host as well just to be safe.
        if not self.cefBrowser.get().GetHost().get():
            Debug("cefBrowser.get().GetHost() failed in CloseBrowser")
            return

        # Flush cookies to disk. Temporary solution for Issue #365.
        # A similar call is made in LifespanHandler_OnBeforeClose.
        # If using GetCookieManager to implement custom cookie managers
        # then flushing of cookies would need to be handled manually.
        self.GetCefBrowserHost().get().GetRequestContext().get() \
                .GetCookieManager(
                        <CefRefPtr[CefCompletionCallback]?>nullptr) \
                .get().FlushStore(<CefRefPtr[CefCompletionCallback]?>nullptr)

        cdef int browserId = self.GetCefBrowser().get().GetIdentifier()
        self.GetCefBrowserHost().get().CloseBrowser(bool(forceClose))
        global g_closed_browsers
        g_closed_browsers.append(browserId)

    cpdef py_void CloseDevTools(self):
        self.GetCefBrowserHost().get().CloseDevTools()

    def ExecuteFunction(self, *args):
        self.GetMainFrame().ExecuteFunction(*args)

    cpdef py_void ExecuteJavascript(self, py_string jsCode,
            py_string scriptUrl="", int startLine=1):
        self.GetMainFrame().ExecuteJavascript(jsCode, scriptUrl, startLine)

    cpdef py_void Find(self, py_string searchText,
                       py_bool forward, py_bool matchCase,
                       py_bool findNext):
        cdef CefString cefSearchText
        PyToCefString(searchText, cefSearchText)
        self.GetCefBrowserHost().get().Find(cefSearchText,
                bool(forward), bool(matchCase), bool(findNext))

    cpdef PyFrame GetFocusedFrame(self):
        assert IsThread(TID_UI), (
                "Browser.GetFocusedFrame() may only be called on UI thread")
        return GetPyFrame(self.GetCefBrowser().get().GetFocusedFrame())

    cpdef PyFrame GetFrameByName(self, py_string name):
        assert IsThread(TID_UI), (
                "Browser.GetFrameByName() may only be called on the UI thread")
        cdef CefString cefName
        PyToCefString(name, cefName)
        return GetPyFrame(self.GetCefBrowser().get().GetFrameByName(cefName))

    cpdef object GetFrameByIdentifier(self, py_string identifier):
        cdef CefString cefIdentifier
        PyToCefString(identifier, cefIdentifier)
        return GetPyFrame(self.GetCefBrowser().get().GetFrameByIdentifier(
                cefIdentifier))

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
            frame = self.GetFrameByName(name)
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

    cpdef py_bool HasDevTools(self):
        return self.GetCefBrowserHost().get().HasDevTools()

    cpdef py_bool HasDocument(self):
        return self.GetCefBrowser().get().HasDocument()

    cpdef py_void Invalidate(self,
                             cef_types.cef_paint_element_type_t element_type):
        return self.GetCefBrowserHost().get().Invalidate(element_type)

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

    cpdef py_void ReplaceMisspelling(self, py_string word):
        cdef CefString cef_word
        PyToCefString(word, cef_word)
        self.GetCefBrowserHost().get().ReplaceMisspelling(cef_word)

    cpdef py_void SetAutoResizeEnabled(self,
                                       py_bool enabled,
                                       list min_size,
                                       list max_size):
        self.GetCefBrowserHost().get().SetAutoResizeEnabled(
            bool(enabled),
            CefSize(min_size[0], min_size[1]),
            CefSize(max_size[0], max_size[1])
        )


    cpdef py_void SetBounds(self, int x, int y, int width, int height):
        IF UNAME_SYSNAME == "Linux":
            x11.SetX11WindowBounds(self.GetCefBrowser(), x, y, width, height)
        ELSE:
            NonCriticalError("SetBounds() not implemented on this platform")

    cpdef py_void SetAccessibilityState(self, cef_state_t state):
        self.GetCefBrowserHost().get().SetAccessibilityState(state)

    cpdef py_void SetFocus(self, enable):
        self.GetCefBrowserHost().get().SetFocus(bool(enable))

    cpdef py_void SetUserData(self, object key, object value):
        self.userData[key] = value

    cpdef py_void SetZoomLevel(self, double zoomLevel):
        self.GetCefBrowserHost().get().SetZoomLevel(zoomLevel)

    cpdef py_void ShowDevTools(self):
        cdef CefWindowInfo window_info
        IF UNAME_SYSNAME == "Windows":
            window_info.SetAsPopup(<CefWindowHandle>self.GetWindowHandle(),
                                   PyToCefStringValue("DevTools"))
        cdef CefBrowserSettings settings
        cdef CefPoint inspect_element_at
        self.GetCefBrowserHost().get().ShowDevTools(
                window_info, <CefRefPtr[CefClient]?>nullptr, settings,
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
                windowHandle = <WindowHandle>\
                        self.GetUserData("__outerWindowHandle")
            else:
                windowHandle = self.GetWindowHandle()

            # Offscreen browser will have an empty window handle.
            assert windowHandle, (
                    "Browser.ToggleFullscreen() failed: no window handle "
                    "found")

            cdef HWND hwnd = <HWND>windowHandle
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
                    SetWindowPos(hwnd, nullptr,
                            left, top, right-left, bottom-top,
                            SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
            else:
                SetWindowLong(hwnd, GWL_STYLE, int(self.gwlStyle))
                SetWindowLong(hwnd, GWL_EXSTYLE, int(self.gwlExStyle))

                if not for_metro:
                    (left, top, right, bottom) = self.windowRect
                    # noinspection PyUnresolvedReferences
                    SetWindowPos(hwnd, nullptr,
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
            cefEvent.modifiers = <uint32_t>pyEvent["modifiers"]
        # Always set CefKeyEvent.windows_key_code in SendKeyEvent, even on
        # Linux. When sending key event for 'backspace' on Linux and setting
        # "native_key_code", "character", "unmodified_character" it doesn't
        # work. It starts working after "windows_key_code" is also sent.
        if "windows_key_code" in pyEvent:
            cefEvent.windows_key_code = int(pyEvent["windows_key_code"])
        if "native_key_code" in pyEvent:
            cefEvent.native_key_code = int(pyEvent["native_key_code"])
        if "is_system_key" in pyEvent:
            cefEvent.is_system_key = int(bool(pyEvent["is_system_key"]))
        if "character" in pyEvent:
            cefEvent.character = int(pyEvent["character"])
        if "unmodified_character" in pyEvent:
            cefEvent.unmodified_character = \
                    int(pyEvent["unmodified_character"])
        if "focus_on_editable_field" in pyEvent:
            cefEvent.focus_on_editable_field = \
                    int(bool(pyEvent["focus_on_editable_field"]))
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

    # for backward compatibility
    cpdef py_void SendFocusEvent(self, py_bool setFocus):
        self.GetCefBrowserHost().get().SetFocus(setFocus)

    cpdef py_void SendCaptureLostEvent(self):
        self.GetCefBrowserHost().get().SendCaptureLostEvent()

    cpdef py_void StartDownload(self, py_string url):
        self.GetCefBrowserHost().get().StartDownload(PyToCefStringValue(
                url))

    cpdef py_bool TryCloseBrowser(self):
        return self.GetCefBrowserHost().get().TryCloseBrowser()

    cpdef py_void WasResized(self):
        self.GetCefBrowserHost().get().WasResized()

    cpdef py_void WasHidden(self, py_bool hidden):
        self.GetCefBrowserHost().get().WasHidden(bool(hidden))

    cpdef py_void NotifyScreenInfoChanged(self):
        self.GetCefBrowserHost().get().NotifyScreenInfoChanged()

    # -------------------------------------------------------------------------
    # OSR drag & drop
    # -------------------------------------------------------------------------

    cpdef py_void DragTargetDragEnter(self, DragData drag_data, int x, int y,
                                      uint32_t allowed_ops):
        cdef CefMouseEvent mouse_event
        mouse_event.x = x
        mouse_event.y = y
        self.GetCefBrowserHost().get().DragTargetDragEnter(
                drag_data.cef_drag_data, mouse_event,
                <cef_types.cef_drag_operations_mask_t>allowed_ops)

    cpdef py_void DragTargetDragOver(self, int x, int y, uint32_t allowed_ops):
        cdef CefMouseEvent mouse_event
        mouse_event.x = x
        mouse_event.y = y
        self.GetCefBrowserHost().get().DragTargetDragOver(
                mouse_event, <cef_types.cef_drag_operations_mask_t>allowed_ops)

    cpdef py_void DragTargetDragLeave(self):
        self.GetCefBrowserHost().get().DragTargetDragLeave()

    cpdef py_void DragTargetDrop(self, int x, int y):
        cdef CefMouseEvent mouse_event
        mouse_event.x = x
        mouse_event.y = y
        self.GetCefBrowserHost().get().DragTargetDrop(mouse_event)

    cpdef py_void DragSourceEndedAt(self, int x, int y, uint32_t operation):
        self.GetCefBrowserHost().get().DragSourceEndedAt(
                x, y, <cef_types.cef_drag_operations_mask_t>operation)

    cpdef py_void DragSourceSystemDragEnded(self):
        self.GetCefBrowserHost().get().DragSourceSystemDragEnded()

