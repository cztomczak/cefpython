# An example of embedding CEF browser in wxPython on Linux.

# Important: 
#   On Linux importing the cefpython module must be 
#   the very first in your application. This is because CEF makes 
#   a global tcmalloc hook for memory allocation/deallocation. 
#   See Issue 73 that is to provide CEF builds with tcmalloc disabled:
#   https://code.google.com/p/cefpython/issues/detail?id=73

import ctypes, os, sys
libcef_so = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'libcef.so')
if os.path.exists(libcef_so):
    # Import local module
    ctypes.CDLL(libcef_so, ctypes.RTLD_GLOBAL)
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import from package
    from cefpython3 import cefpython

import wx
import time
import re
import uuid
import platform

# Which method to use for message loop processing.
#   EVT_IDLE - wx application has priority (default)
#   EVT_TIMER - cef browser has priority
# It seems that Flash content behaves better when using a timer.
# IMPORTANT! On Linux EVT_IDLE does not work, the events seems to
# be propagated only when you move your mouse, which is not the
# expected behavior, it is recommended to use EVT_TIMER on Linux,
# so set this value to False.
USE_EVT_IDLE = False

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

    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                title='wxPython CEF 3 example', size=(800,600))
        self.CreateMenu()

        # Cannot attach browser to the main frame as this will cause
        # the menu not to work.
        self.mainPanel = wx.Panel(self)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.mainPanel.GetGtkWidget())
        # Linux requires adding "file://" for local files,
        # otherwise /home/some will be replaced as http://home/some
        self.browser = cefpython.CreateBrowserSync(
            windowInfo,
            # If there are problems with Flash you can disable it here,
            # by disabling all plugins.
            browserSettings={"plugins_disabled": False},
            navigateUrl="file://"+GetApplicationPath("wxpython.html"))

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

        self.Bind(wx.EVT_CLOSE, self.OnClose)
        if USE_EVT_IDLE:
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

    def OnClose(self, event):
        self.browser.CloseBrowser()
        self.Destroy()

    def OnIdle(self, event):
        cefpython.MessageLoopWork()

def PyPrint(message):
    print(message)

class JavascriptExternal:
    mainBrowser = None
    
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
    def OnLoadingStateChange(self, browser, isLoading, canGoBack, 
            canGoForward):
        print("DisplayHandler::OnLoadingStateChange()")
        print("isLoading = %s, canGoBack = %s, canGoForward = %s" \
                % (isLoading, canGoBack, canGoForward))

    def OnAddressChange(self, browser, frame, url):
        print("DisplayHandler::OnAddressChange()")
        print("url = %s" % url)

    def OnTitleChange(self, browser, title):
        print("DisplayHandler::OnTitleChange()")
        print("title = %s" % title)

    def OnTooltip(self, browser, textOut):
        # OnTooltip not yet implemented (both Linux and Windows), 
        # will be fixed in next CEF release, see Issue 783:
        # https://code.google.com/p/chromiumembedded/issues/detail?id=783
        print("DisplayHandler::OnTooltip()")
        print("text = %s" % textOut[0])

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
        print("value = %s" % value)

    def OnConsoleMessage(self, browser, message, source, line):
        print("DisplayHandler::OnConsoleMessage()")
        print("message = %s" % message)
        print("source = %s" % source)
        print("line = %s" % line)

    # -------------------------------------------------------------------------
    # KeyboardHandler
    # -------------------------------------------------------------------------
    def OnPreKeyEvent(self, browser, event, eventHandle, 
            isKeyboardShortcutOut):
        print("KeyboardHandler::OnPreKeyEvent()")

    def OnKeyEvent(self, browser, event, eventHandle):
        print("KeyboardHandler::OnKeyEvent()")
        print("native_key_code = %s" % event["native_key_code"])
        if platform.system() == "Linux":
            # F5 = 71
            if event["native_key_code"] == 71:
                print("F5 pressed! Reloading page..")
                browser.ReloadIgnoreCache()

    # -------------------------------------------------------------------------
    # RequestHandler
    # -------------------------------------------------------------------------
    def OnBeforeResourceLoad(self, browser, frame, request):
        print("RequestHandler::OnBeforeResourceLoad()")
        print("url = %s" % request.GetUrl()[:70])
        return False

    def OnResourceRedirect(self, browser, frame, oldUrl, newUrlOut):
        print("RequestHandler::OnResourceRedirect()")
        print("old url = %s" % oldUrl[:70])
        print("new url = %s" % newUrlOut[0][:70])

    def GetAuthCredentials(self, browser, frame, isProxy, host, port, realm,
            scheme, callback):
        print("RequestHandler::GetAuthCredentials()")
        print("host = %s" % host)
        print("realm = %s" % realm)
        callback.Continue(username="test", password="test")
        return True

    def OnQuotaRequest(self, browser, originUrl, newSize, callback):
        print("RequestHandler::OnQuotaRequest()")
        print("origin url = %s" % originUrl)
        print("new size = %s" % newSize)
        callback.Continue(True)
        return True

    def GetCookieManager(self, browser, mainUrl):
        # Create unique cookie manager for each browser.
        # --
        # Buggy implementation in CEF, reported here:
        # https://code.google.com/p/chromiumembedded/issues/detail?id=1043
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
        print("url = %s" % url)
        if url.startswith("magnet:"):
            print("Magnet link allowed!")
            allowExecutionOut[0] = True

    def _OnBeforePluginLoad(self, browser, url, policyUrl, info):
        # Plugins are loaded on demand, only when website requires it,
        # the same plugin may be called multiple times.
        print("RequestHandler::OnBeforePluginLoad()")
        print("url = %s" % url)
        print("policy url = %s" % policyUrl)
        print("info.GetName() = %s" % info.GetName())
        print("info.GetPath() = %s" % info.GetPath())
        print("info.GetVersion() = %s" % info.GetVersion())
        print("info.GetDescription() = %s" % info.GetDescription())
        # False to allow, True to block plugin.
        return False

    def _OnCertificateError(self, certError, requestUrl, callback):
        print("RequestHandler::OnCertificateError()")
        print("certError = %s" % certError)
        print("requestUrl = %s" % requestUrl)
        if requestUrl.startswith(
                "https://sage.math.washington.edu:8091/do-not-allow"):
            print("Not allowed!")
            return False
        if requestUrl.startswith(
                "https://sage.math.washington.edu:8091/hudson/job/"):
            print("Allowed!")
            callback.Continue(True)
            return True
        return False

    # -------------------------------------------------------------------------
    # LoadHandler
    # -------------------------------------------------------------------------
    def OnLoadStart(self, browser, frame):
        print("LoadHandler::OnLoadStart()")
        print("frame url = %s" % frame.GetUrl()[:70])

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        print("LoadHandler::OnLoadEnd()")
        print("frame url = %s" % frame.GetUrl()[:70])
        # For file:// urls the status code = 0
        print("http status code = %s" % httpStatusCode)

    def OnLoadError(self, browser, frame, errorCode, errorTextList, failedUrl):
        print("LoadHandler::OnLoadError()")
        print("frame url = %s" % frame.GetUrl()[:70])
        print("error code = %s" % errorCode)
        print("error text = %s" % errorTextList[0])
        print("failed url = %s" % failedUrl)
        customErrorMessage = "My custom error message!"
        frame.LoadUrl("data:text/html,%s" % customErrorMessage)

    def OnRendererProcessTerminated(self, browser, status):
        print("LoadHandler::OnRendererProcessTerminated()")
        statuses = {
            cefpython.TS_ABNORMAL_TERMINATION: "TS_ABNORMAL_TERMINATION",
            cefpython.TS_PROCESS_WAS_KILLED: "TS_PROCESS_WAS_KILLED",
            cefpython.TS_PROCESS_CRASHED: "TS_PROCESS_CRASHED"
        }
        statusName = "Unknown"
        if status in statuses:
            statusName = statuses[status]
        print("status = %s" % statusName)

    def OnPluginCrashed(self, browser, pluginPath):
        print("LoadHandler::OnPluginCrashed()")
        print("plugin path = %s" % pluginPath)

class MyApp(wx.App):
    timer = None
    timerID = 1
    timerCount = 0

    def OnInit(self):
        if not USE_EVT_IDLE:
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
        self.timerCount += 1
        # print("wxpython.py: OnTimer() %d" % self.timerCount)
        cefpython.MessageLoopWork()

    def OnExit(self):
        # When app.MainLoop() returns, MessageLoopWork() should
        # not be called anymore.
        if not USE_EVT_IDLE:
            self.timer.Stop()

if __name__ == '__main__':
    sys.excepthook = ExceptHook
    cefpython.g_debug = False
    cefpython.g_debugFile = GetApplicationPath("debug.log")
    settings = {
        "log_severity": cefpython.LOGSEVERITY_INFO, # LOGSEVERITY_VERBOSE
        "log_file": GetApplicationPath("debug.log"), # Set to "" to disable.
        "release_dcheck_enabled": True, # Enable only when debugging.
        # This directories must be set on Linux
        "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
        "resources_dir_path": cefpython.GetModuleDirectory(),
        "browser_subprocess_path": "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess")
    }
    # print("browser_subprocess_path="+settings["browser_subprocess_path"])
    cefpython.Initialize(settings)
    print('wx.version=%s' % wx.version())
    app = MyApp(False)
    app.MainLoop()
    # Let wx.App destructor do the cleanup before calling cefpython.Shutdown().
    del app
    cefpython.Shutdown()
