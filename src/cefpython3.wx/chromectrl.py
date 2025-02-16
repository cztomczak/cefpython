# Additional and wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

from cefpython3 import cefpython
import os, sys, platform
import wx
import wx.lib.buttons as buttons

#-------------------------------------------------------------------------------

# CEF Python application settings
g_settings = None

def Debug(msg):
    if g_settings and "debug" in g_settings and g_settings["debug"]:
        print("[chromectrl.py] "+msg)

#-------------------------------------------------------------------------------

# Default timer interval when timer used to service CEF message loop
DEFAULT_TIMER_MILLIS = 10

# A global timer for CEF message loop processing.
g_messageLoopTimer = None

def CreateMessageLoopTimer(timerMillis):
    # This function gets called multiple times for each ChromeWindow
    # instance.
    global g_messageLoopTimer
    Debug("CreateMesageLoopTimer")
    if g_messageLoopTimer:
        return
    g_messageLoopTimer = wx.Timer()
    g_messageLoopTimer.Start(timerMillis)
    Debug("g_messageLoopTimer.GetId() = "\
            +str(g_messageLoopTimer.GetId()))
    wx.EVT_TIMER(g_messageLoopTimer, g_messageLoopTimer.GetId(),\
            MessageLoopTimer)

def MessageLoopTimer(event):
    cefpython.MessageLoopWork()

def DestroyMessageLoopTimer():
    global g_messageLoopTimer
    Debug("DestroyMessageLoopTimer")
    if g_messageLoopTimer:
        g_messageLoopTimer.Stop()
        g_messageLoopTimer = None
    else:
        # There was no browser created during session.
        Debug("DestroyMessageLoopTimer: timer not started")

#-------------------------------------------------------------------------------

class NavigationBar(wx.Panel):
    def __init__(self, parent, *args, **kwargs):
        wx.Panel.__init__(self, parent, *args, **kwargs)

        self.bitmapDir = os.path.join(os.path.dirname(
            os.path.abspath(__file__)), "images")

        self._InitComponents()
        self._LayoutComponents()
        self._InitEventHandlers()

    def _InitComponents(self):
        self.backBtn = buttons.GenBitmapButton(self, -1,
                wx.Bitmap(os.path.join(self.bitmapDir, "back.png"),
                          wx.BITMAP_TYPE_PNG), style=wx.BORDER_NONE)
        self.forwardBtn = buttons.GenBitmapButton(self, -1,
                wx.Bitmap(os.path.join(self.bitmapDir, "forward.png"),
                          wx.BITMAP_TYPE_PNG), style=wx.BORDER_NONE)
        self.reloadBtn = buttons.GenBitmapButton(self, -1,
                wx.Bitmap(os.path.join(self.bitmapDir, "reload_page.png"),
                          wx.BITMAP_TYPE_PNG), style=wx.BORDER_NONE)

        self.url = wx.TextCtrl(self, id=-1, style=0)

        self.historyPopup = wx.Menu()

    def _LayoutComponents(self):
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(self.backBtn, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|
                  wx.ALL, 0)
        sizer.Add(self.forwardBtn, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|
                  wx.ALL, 0)
        sizer.Add(self.reloadBtn, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|
                  wx.ALL, 0)

        sizer.Add(self.url, 1, wx.EXPAND|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 12)

        self.SetSizer(sizer)
        self.Fit()

    def _InitEventHandlers(self):
        self.backBtn.Bind(wx.EVT_CONTEXT_MENU, self.OnButtonContext)

    def __del__(self):
        self.historyPopup.Destroy()

    def GetBackButton(self):
        return self.backBtn

    def GetForwardButton(self):
        return self.forwardBtn

    def GetReloadButton(self):
        return self.reloadBtn

    def GetUrlCtrl(self):
        return self.url

    def InitHistoryPopup(self):
        self.historyPopup = wx.Menu()

    def AddToHistory(self, url):
        self.historyPopup.Append(-1, url)

    def OnButtonContext(self, event):
        self.PopupMenu(self.historyPopup)


class ChromeWindow(wx.Window):
    """
    Standalone CEF component. The class provides facilites for interacting
    with wx message loop
    """
    def __init__(self, parent, url="", useTimer=True,
                 timerMillis=DEFAULT_TIMER_MILLIS, browserSettings=None,
                 size=(-1, -1), *args, **kwargs):
        wx.Window.__init__(self, parent, id=wx.ID_ANY, size=size,
                           *args, **kwargs)

        # This timer is not used anymore, but creating it for backwards
        # compatibility. In one of external projects ChromeWindow.timer.Stop()
        # is being called during browser destruction.
        self.timer = wx.Timer()

        # On Linux absolute file urls need to start with "file://"
        # otherwise a path of "/home/some" is converted to "http://home/some".
        if platform.system() in ["Linux", "Darwin"]:
            if url.startswith("/"):
                url = "file://" + url
        self.url = url

        windowInfo = cefpython.WindowInfo()
        if platform.system() == "Windows":
            windowInfo.SetAsChild(self.GetHandle())
        elif platform.system() == "Linux":
            windowInfo.SetAsChild(self.GetGtkWidget())
        elif platform.system() == "Darwin":
            (width, height) = self.GetClientSizeTuple()
            windowInfo.SetAsChild(self.GetHandle(),
                                  [0, 0, width, height])
        else:
            raise Exception("Unsupported OS")

        if not browserSettings:
            browserSettings = {}

        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings=browserSettings, navigateUrl=url)

        if platform.system() == "Windows":
            self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.Bind(wx.EVT_SIZE, self.OnSize)

        self._useTimer = useTimer
        if useTimer:
            CreateMessageLoopTimer(timerMillis)
        else:
            # Currently multiple EVT_IDLE events might be registered
            # when creating multiple ChromeWindow instances. This will
            # result in calling CEF message loop work multiple times
            # simultaneously causing performance penalties and possibly
            # some unwanted behavior (CEF Python Issue 129).
            Debug("WARNING: Using EVT_IDLE for CEF message  loop processing"\
                    " is not recommended")
            self.Bind(wx.EVT_IDLE, self.OnIdle)

        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnClose(self, event):
        if not self._useTimer:
            try:
                self.Unbind(wx.EVT_IDLE)
            except:
                # Calling Unbind() may cause problems on Windows 8:
                # https://groups.google.com/d/topic/cefpython/iXE7e1ekArI/discussion
                # (it was causing problems in __del__, this might not
                #  be true anymore in OnClose, but still let's make sure)
                pass
        self.browser.ParentWindowWillClose()

    def OnIdle(self, event):
        """Service CEF message loop when useTimer is False"""
        cefpython.MessageLoopWork()
        event.Skip()

    def OnSetFocus(self, event):
        """OS_WIN only."""
        cefpython.WindowUtils.OnSetFocus(self.GetHandle(), 0, 0, 0)
        event.Skip()

    def OnSize(self, event):
        """OS_WIN only. Handle the the size event"""
        cefpython.WindowUtils.OnSize(self.GetHandle(), 0, 0, 0)
        event.Skip()

    def GetBrowser(self):
        """Returns the CEF's browser object"""
        return self.browser

    def LoadUrl(self, url, onLoadStart=None, onLoadEnd=None):
        if onLoadStart or onLoadEnd:
            self.GetBrowser().SetClientHandler(
                CallbackClientHandler(onLoadStart, onLoadEnd))

        browser = self.GetBrowser()
        if cefpython.g_debug:
            Debug("LoadUrl() self: %s" % self)
            Debug("browser: %s" % browser)
            Debug("browser id: %s" % browser.GetIdentifier())
            Debug("mainframe: %s" % browser.GetMainFrame())
            Debug("mainframe id: %s" % \
                    browser.GetMainFrame().GetIdentifier())
        self.GetBrowser().GetMainFrame().LoadUrl(url)

        #wx.CallLater(100, browser.ReloadIgnoreCache)
        #wx.CallLater(200, browser.GetMainFrame().LoadUrl, url)


class ChromeCtrl(wx.Panel):
    def __init__(self, parent, url="", useTimer=True,
                 timerMillis=DEFAULT_TIMER_MILLIS,
                 browserSettings=None, hasNavBar=True,
                 *args, **kwargs):
        # You also have to set the wx.WANTS_CHARS style for
        # all parent panels/controls, if it's deeply embedded.
        wx.Panel.__init__(self, parent, style=wx.WANTS_CHARS, *args, **kwargs)

        self.chromeWindow = ChromeWindow(self, url=str(url), useTimer=useTimer,
                browserSettings=browserSettings)
        sizer = wx.BoxSizer(wx.VERTICAL)
        self.navigationBar = None
        if hasNavBar:
            self.navigationBar = self.CreateNavigationBar()
            sizer.Add(self.navigationBar, 0, wx.EXPAND|wx.ALL, 0)
            self._InitEventHandlers()

        sizer.Add(self.chromeWindow, 1, wx.EXPAND, 0)

        self.SetSizer(sizer)
        self.Fit()

        ch = DefaultClientHandler(self)
        self.SetClientHandler(ch)
        if self.navigationBar:
            self.UpdateButtonsState()

    def _InitEventHandlers(self):
        self.navigationBar.backBtn.Bind(wx.EVT_BUTTON, self.OnLeft)
        self.navigationBar.forwardBtn.Bind(wx.EVT_BUTTON, self.OnRight)
        self.navigationBar.reloadBtn.Bind(wx.EVT_BUTTON, self.OnReload)

    def GetNavigationBar(self):
        return self.navigationBar

    def SetNavigationBar(self, navigationBar):
        sizer = self.GetSizer()
        if self.navigationBar:
            # remove previous one
            sizer.Replace(self.navigationBar, navigationBar)
            self.navigationBar.Hide()
            del self.navigationBar
        else:
            sizer.Insert(0, navigationBar, 0, wx.EXPAND)
        self.navigationBar = navigationBar
        sizer.Fit(self)

    def CreateNavigationBar(self):
        np = NavigationBar(self)
        return np

    def SetClientHandler(self, handler):
        self.chromeWindow.GetBrowser().SetClientHandler(handler)

    def OnLeft(self, event):
        if self.chromeWindow.GetBrowser().CanGoBack():
            self.chromeWindow.GetBrowser().GoBack()
        self.UpdateButtonsState()
        self.chromeWindow.GetBrowser().SetFocus(True)

    def OnRight(self, event):
        if self.chromeWindow.GetBrowser().CanGoForward():
            self.chromeWindow.GetBrowser().GoForward()
        self.UpdateButtonsState()
        self.chromeWindow.GetBrowser().SetFocus(True)

    def OnReload(self, event):
        self.chromeWindow.GetBrowser().Reload()
        self.UpdateButtonsState()
        self.chromeWindow.GetBrowser().SetFocus(True)

    def UpdateButtonsState(self):
        self.navigationBar.backBtn.Enable(
            self.chromeWindow.GetBrowser().CanGoBack())
        self.navigationBar.forwardBtn.Enable(
            self.chromeWindow.GetBrowser().CanGoForward())

    def OnLoadStart(self, browser, frame):
        if self.navigationBar:
            self.UpdateButtonsState()
            self.navigationBar.GetUrlCtrl().SetValue(
                browser.GetMainFrame().GetUrl())
            self.navigationBar.AddToHistory(browser.GetMainFrame().GetUrl())

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        if self.navigationBar:
            # In CEF 3 the CanGoBack() and CanGoForward() methods
            # sometimes do work, sometimes do not, when called from
            # the OnLoadStart event. That's why we're calling it again
            # here. This is still not perfect as OnLoadEnd() is not
            # guaranteed to get called for all types of pages. See the
            # cefpython documentation:
            # https://code.google.com/p/cefpython/wiki/LoadHandler
            # OnDomReady() would be perfect, but is still not implemented.
            # Another option is to implement our own browser state
            # using the OnLoadStart and OnLoadEnd callbacks.
            self.UpdateButtonsState()

class DefaultClientHandler(object):
    def __init__(self, parentCtrl):
        self.parentCtrl = parentCtrl

    def OnLoadStart(self, browser, frame):
        self.parentCtrl.OnLoadStart(browser, frame)

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        self.parentCtrl.OnLoadEnd(browser, frame, httpStatusCode)

    def OnLoadError(self, browser, frame, errorCode, errorText, failedUrl):
        # TODO
        Debug("ERROR LOADING URL : %s" % failedUrl)

class CallbackClientHandler(object):
    def __init__(self, onLoadStart=None, onLoadEnd=None):
        self._onLoadStart = onLoadStart
        self._onLoadEnd = onLoadEnd

    def OnLoadStart(self, browser, frame):
        if self._onLoadStart and frame.GetUrl() != "about:blank":
            self._onLoadStart(browser, frame)

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        if self._onLoadEnd and frame.GetUrl() != "about:blank":
            self._onLoadEnd(browser, frame, httpStatusCode)

    def OnLoadError(self, browser, frame, errorCode, errorText, failedUrl):
        # TODO
        Debug("ERROR LOADING URL : %s, %s" % (failedUrl, frame.GetUrl()))

#-------------------------------------------------------------------------------

def Initialize(settings=None, debug=False):
    """Initializes CEF, We should do it before initializing wx
       If no settings passed a default is used
    """
    switches = {}
    global g_settings
    if not settings:
        settings = {}

    if not "log_severity" in settings:
        settings["log_severity"] = cefpython.LOGSEVERITY_INFO
    if not "log_file" in settings:
        settings["log_file"] = ""

    if platform.system() == "Linux":
        # On Linux we need to set locales and resources directories.
        if not "locales_dir_path" in settings:
            settings["locales_dir_path"] = \
                cefpython.GetModuleDirectory() + "/locales"
        if not "resources_dir_path" in settings:
            settings["resources_dir_path"] = cefpython.GetModuleDirectory()
    elif platform.system() == "Darwin":
        # On Mac we need to set the resoures dir and the locale_pak switch
        if not "resources_dir_path" in settings:
            settings["resources_dir_path"] = (cefpython.GetModuleDirectory()
                + "/Resources")
        locale_pak = (cefpython.GetModuleDirectory()
            + "/Resources/en.lproj/locale.pak")
        if "locale_pak" in settings:
            locale_pak = settings["locale_pak"]
            del settings["locale_pak"]
        switches["locale_pak"] = locale_pak

    if not "browser_subprocess_path" in settings:
        settings["browser_subprocess_path"] = \
            "%s/%s" % (cefpython.GetModuleDirectory(), "subprocess")

    # DEBUGGING options:
    # ------------------
    if debug:
        settings["debug"] = True # cefpython messages in console and log_file
        settings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE
        settings["log_file"] = "debug.log" # Set to "" to disable.

    g_settings = settings
    cefpython.Initialize(settings, switches)

def Shutdown():
    """Shuts down CEF, should be called by app exiting code"""
    DestroyMessageLoopTimer()
    cefpython.Shutdown()
