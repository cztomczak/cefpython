# An example of embedding CEF in wxPython application.

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Architecture not supported: %s" \
            % platform.architecture()[0])

import os, sys
libcef_dll = os.path.join(os.path.dirname(os.path.abspath(__file__)),
        'libcef.dll')
if os.path.exists(libcef_dll):
    # Import the local module.
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    elif 0x03000000 <= sys.hexversion < 0x04000000:
        import cefpython_py32 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import the package.
    from cefpython3 import cefpython

import wx
import time
import re
import uuid
import platform

# Which method to use for message loop processing.
#   EVT_IDLE - wx application has priority
#   EVT_TIMER - cef browser has priority (default)
# It seems that Flash content behaves better when using a timer.
# Not sure if using EVT_IDLE is correct, it doesn't work on Linux,
# on Windows it works fine, but read the comment below.
"""
See comment by Robin Dunn:
https://groups.google.com/d/msg/wxpython-users/hcNdMEx8u48/MD5Jgbm_k1kJ
-------------------------------------------------------------------------------
EVT_IDLE events are not sent continuously while the application is idle.
They are sent (normally once) when the app *becomes* idle, which
usually means when the event queue has just been emptied.  If you want
EVT_IDLE events to be sent continuously then you need to call
event.RequestMore() from the handler. Be careful however as that will
cause your application to consume 100% of the CPU if there is no limits.
-------------------------------------------------------------------------------
"""
USE_EVT_IDLE = False # If False then Timer will be used.

TEST_EMBEDDING_IN_PANEL = True

def GetApplicationPath(file=None):
    import re, os, platform
    # If file is None return current directory without trailing slash.
    if file is None:
        file = ""
    # Only when relative path.
    if not file.startswith("/") and not file.startswith("\\") and (
            not re.search(r"^[\w-]+:", file)):
        if hasattr(sys, "frozen"):
            path = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            path = os.path.dirname(os.path.realpath(__file__))
        else:
            path = os.getcwd()
        path = path + os.sep + file
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
        print("cefpython: WARNING: failed writing to error file: %s" % (
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

    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                title='wxPython CEF 3 example', size=(800,600))
        self.CreateMenu()

        if TEST_EMBEDDING_IN_PANEL:
            print("Embedding in a wx.Panel!")
            # You also have to set the wx.WANTS_CHARS style for
            # all parent panels/controls, if it's deeply embedded.
            self.mainPanel = wx.Panel(self, style=wx.WANTS_CHARS)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.GetHandleForBrowser())
        # TODO: when url is preceded with "file://" an error is thrown
        # on Windows when calling urllib_pathname2url(url) in utils.pyx:
        # | IOError: Bad path: file:///C:\cefpython\cefpython-src\..
        # --
        # Preceding url with "file://" is required only on Linux.
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings={"plugins_disabled": False},
                navigateUrl=GetApplicationPath("wxpython.html"))

        clientHandler = ClientHandler()
        self.browser.SetClientHandler(clientHandler)
        cefpython.SetGlobalClientCallback("OnCertificateError",
                clientHandler._OnCertificateError)
        cefpython.SetGlobalClientCallback("OnBeforePluginLoad",
                clientHandler._OnBeforePluginLoad)

        jsBindings = cefpython.JavascriptBindings(
            bindToFrames=False, bindToPopups=True)
        jsBindings.SetFunction("PyPrint", PyPrint)
        jsBindings.SetProperty("pyProperty", "This was set in Python")
        jsBindings.SetProperty("pyConfig", ["This was set in Python",
                {"name": "Nested dictionary", "isNested": True},
                [1,"2", None]])
        jsBindings.SetObject("external", JavascriptExternal(self.browser))
        self.browser.SetJavascriptBindings(jsBindings)

        if self.mainPanel:
            self.mainPanel.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.mainPanel.Bind(wx.EVT_SIZE, self.OnSize)
        else:
            self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.Bind(wx.EVT_SIZE, self.OnSize)

        self.Bind(wx.EVT_CLOSE, self.OnClose)
        if USE_EVT_IDLE:
            print("Using EVT_IDLE to execute the CEF message loop work")
            # Bind EVT_IDLE only for the main application frame.
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
        print("MainFrame.OnClose()")
        self.browser.ParentWindowWillClose()
        self.Destroy()

    def OnIdle(self, event):
        cefpython.MessageLoopWork()
        # See the comment at the top of the file by Robin Dunn.
        # | event.RequestMore()

def PyPrint(message):
    print(message)

class JavascriptExternal:
    mainBrowser = None
    stringVisitor = None

    def __init__(self, mainBrowser):
        self.mainBrowser = mainBrowser

    def Print(self, message):
        print(message)

    def TestAllTypes(self, *args):
        print(args)

    def ExecuteFunction(self, *args):
        self.mainBrowser.GetMainFrame().ExecuteFunction(*args)

    def TestJSCallback(self, jsCallback):
        print("jsCallback.GetFunctionName() = %s" % jsCallback.GetFunctionName())
        print("jsCallback.GetFrame().GetIdentifier() = %s" % \
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
        message = "PyCallback() was executed successfully! Arguments: %s" \
                % str(args)
        print(message)
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

    def NewWindow(self):
        frame = MainFrame()
        frame.Show()

    # -------------------------------------------------------------------------
    # Cookies
    # -------------------------------------------------------------------------
    cookieVisitor = None

    def VisitAllCookies(self):
        # Need to keep the reference alive.
        self.cookieVisitor = CookieVisitor()
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\nCookie manager not yet created! Visit http website first")
            return
        cookieManager.VisitAllCookies(self.cookieVisitor)

    def VisitUrlCookies(self):
        # Need to keep the reference alive.
        self.cookieVisitor = CookieVisitor()
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\nCookie manager not yet created! Visit http website first")
            return
        cookieManager.VisitUrlCookies(
            "http://www.html-kit.com/tools/cookietester/",
            False, self.cookieVisitor)
        # .www.html-kit.com

    def SetCookie(self):
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\nCookie manager not yet created! Visit http website first")
            return
        cookie = cefpython.Cookie()
        cookie.SetName("Created_Via_Python")
        cookie.SetValue("yeah really")
        cookieManager.SetCookie("http://www.html-kit.com/tools/cookietester/",
                cookie)
        print("\nCookie created! Visit html-kit cookietester to see it")

    def DeleteCookies(self):
        cookieManager = self.mainBrowser.GetUserData("cookieManager")
        if not cookieManager:
            print("\nCookie manager not yet created! Visit http website first")
            return
        cookieManager.DeleteCookies(
                "http://www.html-kit.com/tools/cookietester/",
                "Created_Via_Python")
        print("\nCookie deleted! Visit html-kit cookietester to see the result")

class StringVisitor:
    def Visit(self, string):
        print("\nStringVisitor.Visit(): string:")
        print("--------------------------------")
        print(string)
        print("--------------------------------")

class CookieVisitor:
    def Visit(self, cookie, count, total, deleteCookie):
        if count == 0:
            print("\nCookieVisitor.Visit(): total cookies: %s" % total)
        print("\nCookieVisitor.Visit(): cookie:")
        print(cookie.Get())
        # True to continue visiting cookies
        return True

class ClientHandler:

    # -------------------------------------------------------------------------
    # DisplayHandler
    # -------------------------------------------------------------------------

    def OnAddressChange(self, browser, frame, url):
        print("DisplayHandler::OnAddressChange()")
        print("  url = %s" % url)

    def OnTitleChange(self, browser, title):
        print("DisplayHandler::OnTitleChange()")
        print("  title = %s" % title)

    def OnTooltip(self, browser, textOut):
        # OnTooltip not yet implemented (both Linux and Windows),
        # will be fixed in next CEF release, see Issue 783:
        # https://code.google.com/p/chromiumembedded/issues/detail?id=783
        print("DisplayHandler::OnTooltip()")
        print("  text = %s" % textOut[0])

    statusMessageCount = 0
    def OnStatusMessage(self, browser, value):
        if not value:
            # Do not notify in the console about empty statuses.
            return
        self.statusMessageCount += 1
        if self.statusMessageCount > 3:
            # Do not spam too much.
            return
        print("DisplayHandler::OnStatusMessage()")
        print("  value = %s" % value)

    def OnConsoleMessage(self, browser, message, source, line):
        print("DisplayHandler::OnConsoleMessage()")
        print("  message = %s" % message)
        print("  source = %s" % source)
        print("  line = %s" % line)

    # -------------------------------------------------------------------------
    # KeyboardHandler
    # -------------------------------------------------------------------------

    def OnPreKeyEvent(self, browser, event, eventHandle,
            isKeyboardShortcutOut):
        print("KeyboardHandler::OnPreKeyEvent()")

    def OnKeyEvent(self, browser, event, eventHandle):
        print("KeyboardHandler::OnKeyEvent()")
        if platform.system() == "Linux":
            print("  native_key_code = %s" % event["native_key_code"])
            # F5 = 71
            if event["native_key_code"] == 71:
                print("  F5 pressed! Reloading page..")
                browser.ReloadIgnoreCache()
        elif platform.system() == "Windows":
            print("  windows_key_code = %s" % event["windows_key_code"])
            # F5 = VK_F5
            if event["windows_key_code"] == cefpython.VK_F5:
                print("  F5 pressed! Reloading page..")
                browser.ReloadIgnoreCache()

    # -------------------------------------------------------------------------
    # RequestHandler
    # -------------------------------------------------------------------------

    def OnBeforeBrowse(self, browser, frame, request, isRedirect):
        print("RequestHandler::OnBeforeBrowse()")
        print("  url = %s" % request.GetUrl()[:70])
        return False

    def OnBeforeResourceLoad(self, browser, frame, request):
        print("RequestHandler::OnBeforeResourceLoad()")
        print("  url = %s" % request.GetUrl()[:70])
        return False

    def OnResourceRedirect(self, browser, frame, oldUrl, newUrlOut):
        print("RequestHandler::OnResourceRedirect()")
        print("  old url = %s" % oldUrl[:70])
        print("  new url = %s" % newUrlOut[0][:70])

    def GetAuthCredentials(self, browser, frame, isProxy, host, port, realm,
            scheme, callback):
        print("RequestHandler::GetAuthCredentials()")
        print("  host = %s" % host)
        print("  realm = %s" % realm)
        callback.Continue(username="test", password="test")
        return True

    def OnQuotaRequest(self, browser, originUrl, newSize, callback):
        print("RequestHandler::OnQuotaRequest()")
        print("  origin url = %s" % originUrl)
        print("  new size = %s" % newSize)
        callback.Continue(True)
        return True

    def GetCookieManager(self, browser, mainUrl):
        # Create unique cookie manager for each browser.
        # You must set the "unique_request_context_per_browser"
        # application setting to True for the cookie manager
        # to work.
        cookieManager = browser.GetUserData("cookieManager")
        if cookieManager:
            return cookieManager
        else:
            cookieManager = cefpython.CookieManager.CreateManager("")
            browser.SetUserData("cookieManager", cookieManager)
            return cookieManager

    def OnProtocolExecution(self, browser, url, allowExecutionOut):
        # There's no default implementation for OnProtocolExecution on Linux,
        # you have to make OS system call on your own. You probably also need
        # to use LoadHandler::OnLoadError() when implementing this on Linux.
        print("RequestHandler::OnProtocolExecution()")
        print("  url = %s" % url)
        if url.startswith("magnet:"):
            print("  Magnet link allowed!")
            allowExecutionOut[0] = True

    def _OnBeforePluginLoad(self, browser, url, policyUrl, info):
        # Plugins are loaded on demand, only when website requires it,
        # the same plugin may be called multiple times.
        print("RequestHandler::OnBeforePluginLoad()")
        print("  url = %s" % url)
        print("  policy url = %s" % policyUrl)
        print("  info.GetName() = %s" % info.GetName())
        print("  info.GetPath() = %s" % info.GetPath())
        print("  info.GetVersion() = %s" % info.GetVersion())
        print("  info.GetDescription() = %s" % info.GetDescription())
        # False to allow, True to block plugin.
        return False

    def _OnCertificateError(self, certError, requestUrl, callback):
        print("RequestHandler::OnCertificateError()")
        print("  certError = %s" % certError)
        print("  requestUrl = %s" % requestUrl)
        if requestUrl.startswith(
                "https://sage.math.washington.edu:8091/do-not-allow"):
            print("  Not allowed!")
            return False
        if requestUrl.startswith(
                "https://sage.math.washington.edu:8091/hudson/job/"):
            print("  Allowed!")
            callback.Continue(True)
            return True
        return False

    def OnRendererProcessTerminated(self, browser, status):
        print("RequestHandler::OnRendererProcessTerminated()")
        statuses = {
            cefpython.TS_ABNORMAL_TERMINATION: "TS_ABNORMAL_TERMINATION",
            cefpython.TS_PROCESS_WAS_KILLED: "TS_PROCESS_WAS_KILLED",
            cefpython.TS_PROCESS_CRASHED: "TS_PROCESS_CRASHED"
        }
        statusName = "Unknown"
        if status in statuses:
            statusName = statuses[status]
        print("  status = %s" % statusName)

    def OnPluginCrashed(self, browser, pluginPath):
        print("RequestHandler::OnPluginCrashed()")
        print("  plugin path = %s" % pluginPath)

    # -------------------------------------------------------------------------
    # LoadHandler
    # -------------------------------------------------------------------------

    def OnLoadingStateChange(self, browser, isLoading, canGoBack,
            canGoForward):
        print("LoadHandler::OnLoadingStateChange()")
        print("  isLoading = %s, canGoBack = %s, canGoForward = %s" \
                % (isLoading, canGoBack, canGoForward))

    def OnLoadStart(self, browser, frame):
        print("LoadHandler::OnLoadStart()")
        print("  frame url = %s" % frame.GetUrl()[:70])

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        print("LoadHandler::OnLoadEnd()")
        print("  frame url = %s" % frame.GetUrl()[:70])
        # For file:// urls the status code = 0
        print("  http status code = %s" % httpStatusCode)

    def OnLoadError(self, browser, frame, errorCode, errorTextList, failedUrl):
        print("LoadHandler::OnLoadError()")
        print("  frame url = %s" % frame.GetUrl()[:70])
        print("  error code = %s" % errorCode)
        print("  error text = %s" % errorTextList[0])
        print("  failed url = %s" % failedUrl)
        customErrorMessage = "My custom error message!"
        frame.LoadUrl("data:text/html,%s" % customErrorMessage)

    # -------------------------------------------------------------------------
    # LifespanHandler
    # -------------------------------------------------------------------------

    # Empty place-holders: popupFeatures, windowInfo, client, browserSettings.
    def OnBeforePopup(self, browser, frame, targetUrl, targetFrameName,
            popupFeatures, windowInfo, client, browserSettings, noJavascriptAccess):
        print("LifespanHandler::OnBeforePopup()")
        print("  targetUrl = %s" % targetUrl)
        allowPopups = True
        return not allowPopups


class MyApp(wx.App):
    timer = None
    timerID = 1

    def OnInit(self):
        if not USE_EVT_IDLE:
            print("Using TIMER to execute the CEF message loop work")
            self.CreateTimer()
        frame = MainFrame()
        self.SetTopWindow(frame)
        frame.Show()
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
        if not USE_EVT_IDLE:
            self.timer.Stop()

if __name__ == '__main__':
    # Intercept python exceptions. Exit app immediately when exception
    # happens on any of the threads.
    sys.excepthook = ExceptHook
    
    # Application settings
    settings = {}
    settings["debug"] = True # cefpython messages in console and in log_file
    settings["log_file"] = GetApplicationPath("debug.log") # "" to disable
    settings["log_severity"] = cefpython.LOGSEVERITY_INFO # LOGSEVERITY_VERBOSE
    settings["release_dcheck_enabled"] = True # Enable only when debugging
    settings["browser_subprocess_path"] = \
            "%s/%s" % (cefpython.GetModuleDirectory(), "subprocess")
    # This option is required for the GetCookieManager callback
    # to work. It affects renderer processes, when this option
    # is set to True. It will force a separate renderer process
    # for each browser created using CreateBrowserSync.
    settings["unique_request_context_per_browser"] = True;

    # Command line switches set programmatically.
    switches = {
        # "log-severity": "verbose" # Overwrite the "log_severity" setting.
        # "proxy-server": "socks5://127.0.0.1:8888",
        # "enable-media-stream": "",
        # "--invalid-switch": "" -> Invalid switch name
    }

    cefpython.Initialize(settings, switches) # Initialize cefpython before wx.
    print('wx.version=%s' % wx.version())
    app = MyApp(False)
    app.MainLoop()
    # Let wx.App destructor do the cleanup before calling Shutdown().
    del app
    cefpython.Shutdown()
