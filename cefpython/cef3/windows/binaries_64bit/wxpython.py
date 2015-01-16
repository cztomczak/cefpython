# An example of embedding CEF browser in wxPython on Windows.
# Tested with wxPython 2.8.12.1 and 3.0.2.0.

import os, sys
libcef_dll = os.path.join(os.path.dirname(os.path.abspath(__file__)),
        'libcef.dll')
if os.path.exists(libcef_dll):
    # Import a local module
    if (2,7) <= sys.version_info < (2,8):
        import cefpython_py27 as cefpython
    elif (3,4) <= sys.version_info < (3,4):
        import cefpython_py34 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import an installed package
    from cefpython3 import cefpython

import wx
import time
import re
import uuid
import platform
import inspect
import struct

# -----------------------------------------------------------------------------
# Globals

g_applicationSettings = None
g_browserSettings = None
g_commandLineSwitches = None

# Which method to use for message loop processing.
#   EVT_IDLE - wx application has priority
#   EVT_TIMER - cef browser has priority (default)
# It seems that Flash content behaves better when using a timer.
# Not sure if using EVT_IDLE is correct, it doesn't work on Linux,
# on Windows it works fine. See also the post by Robin Dunn:
# https://groups.google.com/d/msg/wxpython-users/hcNdMEx8u48/MD5Jgbm_k1kJ
USE_EVT_IDLE = False # If False then Timer will be used

TEST_EMBEDDING_IN_PANEL = True

# -----------------------------------------------------------------------------

def GetApplicationPath(file=None):
    import re, os, platform
    # On Windows after downloading file and calling Browser.GoForward(),
    # current working directory is set to %UserProfile%.
    # Calling os.path.dirname(os.path.realpath(__file__))
    # returns for eg. "C:\Users\user\Downloads". A solution
    # is to cache path on first call.
    if not hasattr(GetApplicationPath, "dir"):
        if hasattr(sys, "frozen"):
            dir = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            dir = os.path.dirname(os.path.realpath(__file__))
        else:
            dir = os.getcwd()
        GetApplicationPath.dir = dir
    # If file is None return current directory without trailing slash.
    if file is None:
        file = ""
    # Only when relative path.
    if not file.startswith("/") and not file.startswith("\\") and (
            not re.search(r"^[\w-]+:", file)):
        path = GetApplicationPath.dir + os.sep + file
        if platform.system() == "Windows":
            path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(file)

def ExceptHook(excType, excValue, traceObject):
    import traceback, os, time, codecs
    # This hook does the following: in case of exception write it to
    # the "error.log" file, display it to the console, shutdown CEF
    # and exit application immediately by ignoring "finally" (os._exit()).
    errorMsg = "\n".join(traceback.format_exception(excType, excValue,
            traceObject))
    errorFile = GetApplicationPath("error.log")
    try:
        appEncoding = cefpython.g_applicationSettings["string_encoding"]
    except:
        appEncoding = "utf-8"
    if type(errorMsg) == bytes:
        errorMsg = errorMsg.decode(encoding=appEncoding, errors="replace")
    try:
        with codecs.open(errorFile, mode="a", encoding=appEncoding) as fp:
            fp.write("\n[%s] %s\n" % (
                    time.strftime("%Y-%m-%d %H:%M:%S"), errorMsg))
    except:
        print("[wxpython.py] WARNING: failed writing to error file: %s" % (
                errorFile))
    # Convert error message to ascii before printing, otherwise
    # you may get error like this:
    # | UnicodeEncodeError: 'charmap' codec can't encode characters
    errorMsg = errorMsg.encode("ascii", errors="replace")
    errorMsg = errorMsg.decode("ascii", errors="replace")
    print("\n"+errorMsg+"\n")
    cefpython.QuitMessageLoop()
    cefpython.Shutdown()
    os._exit(1)

class MainFrame(wx.Frame):
    browser = None
    mainPanel = None

    def GetHandleForBrowser(self):
        if self.mainPanel:
            return self.mainPanel.GetHandle()
        else:
            return self.GetHandle()

    def __init__(self, url=None, popup=False):
        if popup:
            title = "wxPython Popup"
        else:
            title = "wxPython CEF 3 example"
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                title=title)
        size=(800,600)

        # This is an optional code to enable High DPI support.
        if "auto_zooming" in g_applicationSettings \
                and g_applicationSettings["auto_zooming"] == "system_dpi":
            # This utility function will adjust width/height using
            # OS DPI settings. For 800/600 with Win7 DPI settings
            # being set to "Larger 150%" will return 1200/900.
            size = cefpython.DpiAware.CalculateWindowSize(size[0], size[1])

        self.SetSize(size)

        if not url:
            url = "file://"+GetApplicationPath("wxpython.html")
            # Test hash in url.
            # url += "#test-hash"

        self.CreateMenu()

        if TEST_EMBEDDING_IN_PANEL:
            print("Embedding in a wx.Panel!")
            # You also have to set the wx.WANTS_CHARS style for
            # all parent panels/controls, if it's deeply embedded.
            self.mainPanel = wx.Panel(self, style=wx.WANTS_CHARS)

        # Global client callbacks must be set before browser is created.
        self.clientHandler = ClientHandler()
        cefpython.SetGlobalClientCallback("OnCertificateError",
                self.clientHandler._OnCertificateError)
        cefpython.SetGlobalClientCallback("OnBeforePluginLoad",
                self.clientHandler._OnBeforePluginLoad)
        cefpython.SetGlobalClientCallback("OnAfterCreated",
                self.clientHandler._OnAfterCreated)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.GetHandleForBrowser())
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings=g_browserSettings,
                navigateUrl=url)

        self.clientHandler.mainBrowser = self.browser
        self.browser.SetClientHandler(self.clientHandler)

        jsBindings = cefpython.JavascriptBindings(
            bindToFrames=False, bindToPopups=True)
        jsBindings.SetFunction("PyPrint", PyPrint)
        jsBindings.SetProperty("pyProperty", "This was set in Python")
        jsBindings.SetProperty("pyConfig", ["This was set in Python",
                {"name": "Nested dictionary", "isNested": True},
                [1,"2", None]])
        self.javascriptExternal = JavascriptExternal(self.browser)
        jsBindings.SetObject("external", self.javascriptExternal)
        jsBindings.SetProperty("sources", GetSources())
        self.browser.SetJavascriptBindings(jsBindings)

        if self.mainPanel:
            self.mainPanel.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.mainPanel.Bind(wx.EVT_SIZE, self.OnSize)
        else:
            self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.Bind(wx.EVT_SIZE, self.OnSize)

        self.Bind(wx.EVT_CLOSE, self.OnClose)
        if USE_EVT_IDLE and not popup:
            # Bind EVT_IDLE only for the main application frame.
            print("Using EVT_IDLE to execute the CEF message loop work")
            self.Bind(wx.EVT_IDLE, self.OnIdle)

    def CreateMenu(self):
        filemenu = wx.Menu()
        filemenu.Append(1, "Open")
        exit = filemenu.Append(2, "Exit")
        self.Bind(wx.EVT_MENU, self.OnClose, exit)
        aboutmenu = wx.Menu()
        aboutmenu.Append(1, "CEF Python")
        menubar = wx.MenuBar()
        menubar.Append(filemenu,"&File")
        menubar.Append(aboutmenu, "&About")
        self.SetMenuBar(menubar)

    def OnSetFocus(self, event):
        cefpython.WindowUtils.OnSetFocus(self.GetHandleForBrowser(), 0, 0, 0)

    def OnSize(self, event):
        cefpython.WindowUtils.OnSize(self.GetHandleForBrowser(), 0, 0, 0)

    def OnClose(self, event):
        # Remove all CEF browser references so that browser is closed
        # cleanly. Otherwise there may be issues for example with cookies
        # not being flushed to disk when closing app immediately
        # (Issue 158).
        del self.javascriptExternal.mainBrowser
        del self.clientHandler.mainBrowser
        del self.browser

        # Destroy wx frame, this will complete the destruction of CEF browser
        self.Destroy()

        # In wx.chromectrl calling browser.CloseBrowser and/or self.Destroy
        # may cause crashes when embedding multiple browsers in tab
        # (Issue 107). In such case instead of calling CloseBrowser/Destroy
        # try this code:
        # | self.browser.ParentWindowWillClose()
        # | event.Skip()

    def OnIdle(self, event):
        cefpython.MessageLoopWork()

def PyPrint(message):
    print("[wxpython.py] PyPrint: "+message)

class JavascriptExternal:
    mainBrowser = None
    stringVisitor = None

    def __init__(self, mainBrowser):
        self.mainBrowser = mainBrowser

    def GoBack(self):
        self.mainBrowser.GoBack()

    def GoForward(self):
        self.mainBrowser.GoForward()

    def CreateAnotherBrowser(self, url=None):
        frame = MainFrame(url=url)
        frame.Show()

    def Print(self, message):
        print("[wxpython.py] Print: "+message)

    def TestAllTypes(self, *args):
        print("[wxpython.py] TestAllTypes: "+str(args))

    def ExecuteFunction(self, *args):
        self.mainBrowser.GetMainFrame().ExecuteFunction(*args)

    def TestJSCallback(self, jsCallback):
        print("[wxpython.py] jsCallback.GetFunctionName() = %s"\
                % jsCallback.GetFunctionName())
        print("[wxpython.py] jsCallback.GetFrame().GetIdentifier() = %s" % \
                jsCallback.GetFrame().GetIdentifier())
        jsCallback.Call("This message was sent from python using js callback")

    def TestJSCallbackComplexArguments(self, jsObject):
        jsCallback = jsObject["myCallback"];
        jsCallback.Call(1, None, 2.14, "string", ["list", ["nested list", \
                {"nested object":None}]], \
                {"nested list next":[{"deeply nested object":1}]})

    def TestPythonCallback(self, jsCallback):
        jsCallback.Call(self.PyCallback)

    def PyCallback(self, *args):
        message = "PyCallback() was executed successfully! "\
                "Arguments: %s" % str(args)
        print("[wxpython.py] "+message)
        self.mainBrowser.GetMainFrame().ExecuteJavascript(
                "window.alert(\"%s\")" % message)

    def GetSource(self):
        # Must keep a strong reference to the StringVisitor object
        # during the visit.
        self.stringVisitor = StringVisitor()
        self.mainBrowser.GetMainFrame().GetSource(self.stringVisitor)

    def GetText(self):
        # Must keep a strong reference to the StringVisitor object
        # during the visit.
        self.stringVisitor = StringVisitor()
        self.mainBrowser.GetMainFrame().GetText(self.stringVisitor)

    def ShowDevTools(self):
        print("[wxpython.py] external.ShowDevTools called")
        self.mainBrowser.ShowDevTools()

    # -------------------------------------------------------------------------
    # Cookies
    # -------------------------------------------------------------------------
    cookieVisitor = None

    def VisitAllCookies(self):
        # Need to keep the reference alive.
        self.cookieVisitor = CookieVisitor()
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\n[wxpython.py] Cookie manager not yet created! Visit"\
                    " the cookietester website first and create some cookies")
            return
        cookieManager.VisitAllCookies(self.cookieVisitor)

    def VisitUrlCookies(self):
        # Need to keep the reference alive.
        self.cookieVisitor = CookieVisitor()
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\n[wxpython.py] Cookie manager not yet created! Visit"\
                    " the cookietester website first and create some cookies")
            return
        cookieManager.VisitUrlCookies(
            "http://www.html-kit.com/tools/cookietester/",
            False, self.cookieVisitor)
        # .www.html-kit.com

    def SetCookie(self):
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\n[wxpython.py] Cookie manager not yet created! Visit"\
                    "the cookietester website first and create some cookies")
            return
        cookie = cefpython.Cookie()
        cookie.SetName("Created_Via_Python")
        cookie.SetValue("yeah really")
        cookieManager.SetCookie("http://www.html-kit.com/tools/cookietester/",
                cookie)
        print("\n[wxpython.py] Cookie created! Visit html-kit cookietester to"\
                " see it")

    def DeleteCookies(self):
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\n[wxpython.py] Cookie manager not yet created! Visit"\
                    " the cookietester website first and create some cookies")
            return
        cookieManager.DeleteCookies(
                "http://www.html-kit.com/tools/cookietester/",
                "Created_Via_Python")
        print("\n[wxpython.py] Cookie deleted! Visit html-kit cookietester "\
                "to see the result")

class StringVisitor:
    def Visit(self, string):
        print("\n[wxpython.py] StringVisitor.Visit(): string:")
        print("--------------------------------")
        print(string)
        print("--------------------------------")

class CookieVisitor:
    def Visit(self, cookie, count, total, deleteCookie):
        if count == 0:
            print("\n[wxpython.py] CookieVisitor.Visit(): total cookies: %s"\
                    % total)
        print("\n[wxpython.py] CookieVisitor.Visit(): cookie:")
        print("    "+str(cookie.Get()))
        # True to continue visiting cookies
        return True

class ClientHandler:
    mainBrowser = None # May be None for global client callbacks.

    def __init__(self):
        pass

    # -------------------------------------------------------------------------
    # DisplayHandler
    # -------------------------------------------------------------------------

    def OnAddressChange(self, browser, frame, url):
        print("[wxpython.py] DisplayHandler::OnAddressChange()")
        print("    url = %s" % url)

    def OnTitleChange(self, browser, title):
        print("[wxpython.py] DisplayHandler::OnTitleChange()")
        print("    title = %s" % title)

    def OnTooltip(self, browser, textOut):
        # OnTooltip not yet implemented (both Linux and Windows),
        # will be fixed in next CEF release, see Issue 783:
        # https://code.google.com/p/chromiumembedded/issues/detail?id=783
        print("[wxpython.py] DisplayHandler::OnTooltip()")
        print("    text = %s" % textOut[0])

    statusMessageCount = 0
    def OnStatusMessage(self, browser, value):
        if not value:
            # Do not notify in the console about empty statuses.
            return
        self.statusMessageCount += 1
        if self.statusMessageCount > 3:
            # Do not spam too much.
            return
        print("[wxpython.py] DisplayHandler::OnStatusMessage()")
        print("    value = %s" % value)

    def OnConsoleMessage(self, browser, message, source, line):
        print("[wxpython.py] DisplayHandler::OnConsoleMessage()")
        print("    message = %s" % message)
        print("    source = %s" % source)
        print("    line = %s" % line)

    # -------------------------------------------------------------------------
    # KeyboardHandler
    # -------------------------------------------------------------------------

    def OnPreKeyEvent(self, browser, event, eventHandle,
            isKeyboardShortcutOut):
        print("[wxpython.py] KeyboardHandler::OnPreKeyEvent()")

    def OnKeyEvent(self, browser, event, eventHandle):
        if event["type"] == cefpython.KEYEVENT_KEYUP:
            # OnKeyEvent is called twice for F5/Esc keys, with event
            # type KEYEVENT_RAWKEYDOWN and KEYEVENT_KEYUP.
            # Normal characters a-z should have KEYEVENT_CHAR.
            return False
        print("[wxpython.py] KeyboardHandler::OnKeyEvent()")
        print("    type=%s" % event["type"])
        print("    modifiers=%s" % event["modifiers"])
        print("    windows_key_code=%s" % event["windows_key_code"])
        print("    native_key_code=%s" % event["native_key_code"])
        print("    is_system_key=%s" % event["is_system_key"])
        print("    character=%s" % event["character"])
        print("    unmodified_character=%s" % event["unmodified_character"])
        print("    focus_on_editable_field=%s" \
                % event["focus_on_editable_field"])
        linux = (platform.system() == "Linux")
        windows = (platform.system() == "Windows")
        # F5
        if (linux and event["native_key_code"] == 71) \
                or (windows and event["windows_key_code"] == 116):
            print("[wxpython.py] F5 pressed, calling"
                    " browser.ReloadIgnoreCache()")
            browser.ReloadIgnoreCache()
            return True
        # Escape
        if (linux and event["native_key_code"] == 9) \
                or (windows and event["windows_key_code"] == 27):
            print("[wxpython.py] Esc pressed, calling browser.StopLoad()")
            browser.StopLoad()
            return True
        # F12
        if (linux and event["native_key_code"] == 96) \
                or (windows and event["windows_key_code"] == 123):
            print("[wxpython.py] F12 pressed, calling"
                    " browser.ShowDevTools()")
            browser.ShowDevTools()
            return True
        return False

    # -------------------------------------------------------------------------
    # RequestHandler
    # -------------------------------------------------------------------------

    def OnBeforeBrowse(self, browser, frame, request, isRedirect):
        print("[wxpython.py] RequestHandler::OnBeforeBrowse()")
        print("    url = %s" % request.GetUrl()[:100])
        # Handle "magnet:" links.
        if request.GetUrl().startswith("magnet:"):
            print("[wxpython.p] RequestHandler::OnBeforeBrowse(): "
                    "magnet link clicked, cancelling browse request")
            return True
        return False

    def OnBeforeResourceLoad(self, browser, frame, request):
        print("[wxpython.py] RequestHandler::OnBeforeResourceLoad()")
        print("    url = %s" % request.GetUrl()[:100])
        return False

    def OnResourceRedirect(self, browser, frame, oldUrl, newUrlOut):
        print("[wxpython.py] RequestHandler::OnResourceRedirect()")
        print("    old url = %s" % oldUrl[:100])
        print("    new url = %s" % newUrlOut[0][:100])

    def GetAuthCredentials(self, browser, frame, isProxy, host, port, realm,
            scheme, callback):
        # This callback is called on the IO thread, thus print messages
        # may not be visible.
        print("[wxpython.py] RequestHandler::GetAuthCredentials()")
        print("    host = %s" % host)
        print("    realm = %s" % realm)
        callback.Continue(username="test", password="test")
        return True

    def OnQuotaRequest(self, browser, originUrl, newSize, callback):
        print("[wxpython.py] RequestHandler::OnQuotaRequest()")
        print("    origin url = %s" % originUrl)
        print("    new size = %s" % newSize)
        callback.Continue(True)
        return True

    def GetCookieManager(self, browser, mainUrl):
        # Create unique cookie manager for each browser.
        # You must set the "unique_request_context_per_browser"
        # application setting to True for the cookie manager
        # to work.
        # Return None to have one global cookie manager for
        # all CEF browsers.
        if not browser:
            # The browser param may be empty in some exceptional
            # case, see docs.
            return None
        cookieManager = browser.GetUserData("cookieManager")
        if cookieManager:
            return cookieManager
        else:
            print("[wxpython.py] RequestHandler::GetCookieManager():"\
                    " created cookie manager")
            cookieManager = cefpython.CookieManager.CreateManager("")
            if "cache_path" in g_applicationSettings:
                path = g_applicationSettings["cache_path"]
                # path = os.path.join(path, "cookies_browser_{}".format(
                #     browser.GetIdentifier()))
                cookieManager.SetStoragePath(path)
            browser.SetUserData("cookieManager", cookieManager)
            return cookieManager

    def OnProtocolExecution(self, browser, url, allowExecutionOut):
        # There's no default implementation for OnProtocolExecution on Linux,
        # you have to make OS system call on your own. You probably also need
        # to use LoadHandler::OnLoadError() when implementing this on Linux.
        print("[wxpython.py] RequestHandler::OnProtocolExecution()")
        print("    url = %s" % url)
        if url.startswith("magnet:"):
            print("[wxpython.py] Magnet link allowed!")
            allowExecutionOut[0] = True

    def _OnBeforePluginLoad(self, browser, url, policyUrl, info):
        # This is a global callback set using SetGlobalClientCallback().
        # Plugins are loaded on demand, only when website requires it,
        # the same plugin may be called multiple times.
        # This callback is called on the IO thread, thus print messages
        # may not be visible.
        print("[wxpython.py] RequestHandler::_OnBeforePluginLoad()")
        print("    url = %s" % url)
        print("    policy url = %s" % policyUrl)
        print("    info.GetName() = %s" % info.GetName())
        print("    info.GetPath() = %s" % info.GetPath())
        print("    info.GetVersion() = %s" % info.GetVersion())
        print("    info.GetDescription() = %s" % info.GetDescription())
        # False to allow, True to block plugin.
        return False

    def _OnCertificateError(self, certError, requestUrl, callback):
        # This is a global callback set using SetGlobalClientCallback().
        print("[wxpython.py] RequestHandler::_OnCertificateError()")
        print("    certError = %s" % certError)
        print("    requestUrl = %s" % requestUrl)
        if requestUrl == "https://testssl-expire.disig.sk/index.en.html":
            print("    Not allowed!")
            return False
        if requestUrl \
                == "https://testssl-expire.disig.sk/index.en.html?allow=1":
            print("    Allowed!")
            callback.Continue(True)
            return True
        return False

    def OnRendererProcessTerminated(self, browser, status):
        print("[wxpython.py] RequestHandler::OnRendererProcessTerminated()")
        statuses = {
            cefpython.TS_ABNORMAL_TERMINATION: "TS_ABNORMAL_TERMINATION",
            cefpython.TS_PROCESS_WAS_KILLED: "TS_PROCESS_WAS_KILLED",
            cefpython.TS_PROCESS_CRASHED: "TS_PROCESS_CRASHED"
        }
        statusName = "Unknown"
        if status in statuses:
            statusName = statuses[status]
        print("    status = %s" % statusName)

    def OnPluginCrashed(self, browser, pluginPath):
        print("[wxpython.py] RequestHandler::OnPluginCrashed()")
        print("    plugin path = %s" % pluginPath)

    # -------------------------------------------------------------------------
    # LoadHandler
    # -------------------------------------------------------------------------

    def OnLoadingStateChange(self, browser, isLoading, canGoBack,
            canGoForward):
        print("[wxpython.py] LoadHandler::OnLoadingStateChange()")
        print("    isLoading = %s, canGoBack = %s, canGoForward = %s" \
                % (isLoading, canGoBack, canGoForward))

    def OnLoadStart(self, browser, frame):
        print("[wxpython.py] LoadHandler::OnLoadStart()")
        print("    frame url = %s" % frame.GetUrl()[:100])

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        print("[wxpython.py] LoadHandler::OnLoadEnd()")
        print("    frame url = %s" % frame.GetUrl()[:100])
        # For file:// urls the status code = 0
        print("    http status code = %s" % httpStatusCode)
        # Tests for the Browser object methods
        self._Browser_LoadUrl(browser)

    def _Browser_LoadUrl(self, browser):
        if browser.GetUrl() == "data:text/html,Test#Browser.LoadUrl":
             browser.LoadUrl("file://"+GetApplicationPath("wxpython.html"))

    def OnLoadError(self, browser, frame, errorCode, errorTextList, failedUrl):
        print("[wxpython.py] LoadHandler::OnLoadError()")
        print("    frame url = %s" % frame.GetUrl()[:100])
        print("    error code = %s" % errorCode)
        print("    error text = %s" % errorTextList[0])
        print("    failed url = %s" % failedUrl)
        # Handle ERR_ABORTED error code, to handle the following cases:
        # 1. Esc key was pressed which calls browser.StopLoad() in OnKeyEvent
        # 2. Download of a file was aborted
        # 3. Certificate error
        if errorCode == cefpython.ERR_ABORTED:
            print("[wxpython.py] LoadHandler::OnLoadError(): Ignoring load "
                    "error: Esc was pressed or file download was aborted, "
                    "or there was certificate error")
            return;
        customErrorMessage = "My custom error message!"
        frame.LoadUrl("data:text/html,%s" % customErrorMessage)

    # -------------------------------------------------------------------------
    # LifespanHandler
    # -------------------------------------------------------------------------

    # ** This callback is executed on the IO thread **
    # Empty place-holders: popupFeatures, client.
    def OnBeforePopup(self, browser, frame, targetUrl, targetFrameName,
            popupFeatures, windowInfo, client, browserSettings,
            noJavascriptAccess):
        print("[wxpython.py] LifespanHandler::OnBeforePopup()")
        print("    targetUrl = %s" % targetUrl)

        # Custom browser settings for popups:
        # > browserSettings[0] = {"plugins_disabled": True}

        # Set WindowInfo object:
        # > windowInfo[0] = cefpython.WindowInfo()

        # On Windows there are keyboard problems in popups, when popup
        # is created using "window.open" or "target=blank". This issue
        # occurs only in wxPython. PyGTK or PyQt do not require this fix.
        # The solution is to create window explicitilly, and not depend
        # on CEF to create window internally.
        # If you set allowPopups=True then CEF will create popup window.
        # The wx.Frame cannot be created here, as this callback is
        # executed on the IO thread. Window should be created on the UI
        # thread. One solution is to call cefpython.CreateBrowser()
        # which runs asynchronously and can be called on any thread.
        # The other solution is to post a task on the UI thread, so
        # that cefpython.CreateBrowserSync() can be used.
        cefpython.PostTask(cefpython.TID_UI, self._CreatePopup, targetUrl)

        allowPopups = False
        return not allowPopups

    def _CreatePopup(self, url):
        frame = MainFrame(url=url, popup=True)
        frame.Show()

    def _OnAfterCreated(self, browser):
        # This is a global callback set using SetGlobalClientCallback().
        print("[wxpython.py] LifespanHandler::_OnAfterCreated()")
        print("    browserId=%s" % browser.GetIdentifier())

    def RunModal(self, browser):
        print("[wxpython.py] LifespanHandler::RunModal()")
        print("    browserId=%s" % browser.GetIdentifier())

    def DoClose(self, browser):
        print("[wxpython.py] LifespanHandler::DoClose()")
        print("    browserId=%s" % browser.GetIdentifier())

    def OnBeforeClose(self, browser):
        print("[wxpython.py] LifespanHandler::OnBeforeClose")
        print("    browserId=%s" % browser.GetIdentifier())

    # -------------------------------------------------------------------------
    # JavascriptDialogHandler
    # -------------------------------------------------------------------------

    def OnJavascriptDialog(self, browser, originUrl, acceptLang, dialogType,
                   messageText, defaultPromptText, callback,
                   suppressMessage):
        print("[wxpython.py] JavascriptDialogHandler::OnJavascriptDialog()")
        print("    originUrl="+originUrl)
        print("    acceptLang="+acceptLang)
        print("    dialogType="+str(dialogType))
        print("    messageText="+messageText)
        print("    defaultPromptText="+defaultPromptText)
        # If you want to suppress the javascript dialog:
        # suppressMessage[0] = True
        return False

    def OnBeforeUnloadJavascriptDialog(self, browser, messageText, isReload,
            callback):
        print("[wxpython.py] OnBeforeUnloadJavascriptDialog()")
        print("    messageText="+messageText)
        print("    isReload="+str(isReload))
        # Return True if the application will use a custom dialog:
        #   callback.Continue(allow=True, userInput="")
        #   return True
        return False

    def OnResetJavascriptDialogState(self, browser):
        print("[wxpython.py] OnResetDialogState()")

    def OnJavascriptDialogClosed(self, browser):
        print("[wxpython.py] OnDialogClosed()")


class MyApp(wx.App):
    timer = None
    timerID = 1
    mainFrame = None

    def OnInit(self):
        if not USE_EVT_IDLE:
            print("[wxpython.py] Using TIMER to run CEF message loop")
            self.CreateTimer()
        self.mainFrame = MainFrame()
        self.SetTopWindow(self.mainFrame)
        self.mainFrame.Show()
        return True

    def CreateTimer(self):
        # See "Making a render loop":
        # http://wiki.wxwidgets.org/Making_a_render_loop
        # Another approach is to use EVT_IDLE in MainFrame,
        # see which one fits you better.
        self.timer = wx.Timer(self, self.timerID)
        self.timer.Start(10) # 10ms
        wx.EVT_TIMER(self, self.timerID, self.OnTimer)

    def OnTimer(self, event):
        cefpython.MessageLoopWork()

    def OnExit(self):
        # When app.MainLoop() returns, MessageLoopWork() should
        # not be called anymore.
        print("[wxpython.py] MyApp.OnExit")
        if not USE_EVT_IDLE:
            self.timer.Stop()


def GetSources():
    # Get sources of all python functions and methods from this file.
    # This is to provide sources preview to wxpython.html.
    # The dictionary of functions is binded to "window.sources".
    thisModule = sys.modules[__name__]
    functions = inspect.getmembers(thisModule, inspect.isfunction)
    classes = inspect.getmembers(thisModule, inspect.isclass)
    sources = {}
    for funcTuple in functions:
        sources[funcTuple[0]] = inspect.getsource(funcTuple[1])
    for classTuple in classes:
        className = classTuple[0]
        classObject = classTuple[1]
        methods = inspect.getmembers(classObject)
        for methodTuple in methods:
            try:
                sources[methodTuple[0]] = inspect.getsource(\
                        methodTuple[1])
            except:
                pass
    return sources


if __name__ == '__main__':
    print('[wxpython.py] architecture=%s-bit' % (8 * struct.calcsize("P")))
    print('[wxpython.py] wx.version=%s' % wx.version())

    # Intercept python exceptions. Exit app immediately when exception
    # happens on any of the threads.
    sys.excepthook = ExceptHook

    # Application settings
    g_applicationSettings = {
        # Disk cache
        # "cache_path": "webcache/",

        # CEF Python debug messages in console and in log_file
        "debug": True,
        # Set it to LOGSEVERITY_VERBOSE for more details
        "log_severity": cefpython.LOGSEVERITY_INFO,
        # Set to "" to disable logging to a file
        "log_file": GetApplicationPath("debug.log"),
        # This should be enabled only when debugging
        "release_dcheck_enabled": True,

        # These directories must be set on Linux
        "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
        "resources_dir_path": cefpython.GetModuleDirectory(),
        # The "subprocess" executable that launches the Renderer
        # and GPU processes among others. You may rename that
        # executable if you like.
        "browser_subprocess_path": "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess"),

        # This option is required for the GetCookieManager callback
        # to work. It affects renderer processes, when this option
        # is set to True. It will force a separate renderer process
        # for each browser created using CreateBrowserSync.
        "unique_request_context_per_browser": True,
        # Downloads are handled automatically. A default SaveAs file
        # dialog provided by OS will be displayed.

        "downloads_enabled": True,
        # Remote debugging port, required for Developer Tools support.
        # A value of 0 will generate a random port. To disable devtools
        # support set it to -1.
        "remote_debugging_port": 0,
        # Mouse context menu
        "context_menu": {
            "enabled": True,
            "navigation": True, # Back, Forward, Reload
            "print": True,
            "view_source": True,
            "external_browser": True, # Open in external browser
            "devtools": True, # Developer Tools
        },

        # See also OnCertificateError which allows you to ignore
        # certificate errors for specific websites.
        "ignore_certificate_errors": True,
    }

    # You can comment out the code below if you do not want High
    # DPI support. If you disable it text will look fuzzy on
    # high DPI displays.
    #
    # Enabling High DPI support in app can be done by
    # embedding a DPI awareness xml manifest in executable
    # (see Issue 112 comment #2), or by calling SetProcessDpiAware
    # function. Embedding xml manifest is the most reliable method.
    # The downside of calling SetProcessDpiAware is that scrollbar
    # in CEF browser is smaller than it should be. This is because
    # DPI awareness was set too late, after the CEF dll was loaded.
    # To fix that embed DPI awareness xml manifest in the .exe file.
    #
    # There is one bug when enabling High DPI support - fonts in
    # javascript dialogs (alert) are tiny. However, you can implement
    # custom javascript dialogs using JavascriptDialogHandler.
    #
    # Additionally you have to set "auto_zomming" application
    # setting. High DPI support is available only on Windows.
    # You may set auto_zooming to "system_dpi" and browser
    # contents will be zoomed using OS DPI settings. On Win7
    # these can be set in: Control Panel > Appearance and
    # Personalization > Display.
    #
    # Example values for auto_zooming are:
    #   "system_dpi", "0.0" (96 DPI), "1.0" (120 DPI),
    #   "2.0" (144 DPI), "-1.0" (72 DPI)
    # Numeric value means a zoom level.
    # Example values that can be set in Win7 DPI settings:
    #   Smaller 100% (Default) = 96 DPI = 0.0 zoom level
    #   Medium 125% = 120 DPI = 1.0 zoom level
    #   Larger 150% = 144 DPI = 2.0 zoom level
    #   Custom 75% = 72 DPI = -1.0 zoom level
    g_applicationSettings["auto_zooming"] = "system_dpi"
    print("[wxpython.py] Calling SetProcessDpiAware")
    cefpython.DpiAware.SetProcessDpiAware()

    # Browser settings. You may have different settings for each
    # browser, see the call to CreateBrowserSync.
    g_browserSettings = {
        # "plugins_disabled": True,
        # "file_access_from_file_urls_allowed": True,
        # "universal_access_from_file_urls_allowed": True,
    }

    # Command line switches set programmatically
    g_commandLineSwitches = {
        # "proxy-server": "socks5://127.0.0.1:8888",
        # "no-proxy-server": "",
        # "enable-media-stream": "",
        # "disable-gpu": "",

    }

    cefpython.Initialize(g_applicationSettings, g_commandLineSwitches)

    app = MyApp(False)
    app.MainLoop()

    # Let wx.App destructor do the cleanup before calling
    # cefpython.Shutdown(). This is to ensure reliable CEF shutdown.
    del app

    cefpython.Shutdown()

