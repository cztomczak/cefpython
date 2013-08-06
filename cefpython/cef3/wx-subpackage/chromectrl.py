# Additional and wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#--------------------------------------------------------------------------------

from cefpython3 import cefpython
from cefpython3.wx.utils import ExceptHook
import os, sys, platform
import wx
import wx.lib.buttons as buttons

#-------------------------------------------------------------------------------

# Default timer interval when timer used to service CEF message loop
DEFAULT_TIMER_MILLIS = 10

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
                wx.Bitmap(os.path.join(self.bitmapDir, "Arrow Left.png"),
                          wx.BITMAP_TYPE_PNG), style=wx.BORDER_NONE)
        self.forwardBtn = buttons.GenBitmapButton(self, -1,
                wx.Bitmap(os.path.join(self.bitmapDir, "Arrow Right.png"),
                          wx.BITMAP_TYPE_PNG), style=wx.BORDER_NONE)
        self.reloadBtn = buttons.GenBitmapButton(self, -1,
                wx.Bitmap(os.path.join(self.bitmapDir, "Button Load.png"),
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
    def __init__(self, parent, url="", useTimer=False,
                 timerMillis=DEFAULT_TIMER_MILLIS,  size=(-1, -1),
                 *args, **kwargs):
        wx.Window.__init__(self, parent, id=wx.ID_ANY, size=size,
                           *args, **kwargs)
        # On Linux absolute file urls need to start with "file://"
        # otherwise a path of "/home/some" is converted to "http://home/some".
        if platform.system() == "Linux":
            if url.startswith("/"):
                url = "file://" + url
        self.url = url
        
        windowInfo = cefpython.WindowInfo()
        if platform.system() == "Windows":
            windowInfo.SetAsChild(self.GetHandle())
        elif platform.system() == "Linux":
            windowInfo.SetAsChild(self.GetGtkWidget())
        else:
            raise Exception("Unsupported OS")
        
        # TODO: allow for custom browser settings for the ChromeWindow
        browserSettings = {}

        # Disable plugins:
        # | browserSettings["plugins_disabled"] = True

        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings=browserSettings, navigateUrl=url)

        if platform.system() == "Windows":
            self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
            self.Bind(wx.EVT_SIZE, self.OnSize)
        if useTimer:
            self.timerID = 1
            self._CreateTimer(timerMillis)
        else:
            self.Bind(wx.EVT_IDLE, self.OnIdle)
        self._useTimer = useTimer

    def __del__(self):
        '''cleanup stuff'''
        if self._useTimer:
            self.timer.Stop()
        # Calling Unbind() is unnecessary and will cause problems on Windows 8:
        # https://groups.google.com/d/topic/cefpython/iXE7e1ekArI/discussion
        # | self.Unbind(wx.EVT_IDLE)
        # CloseBrowser() parameter: forceClose=True
        self.browser.CloseBrowser(True)

    def _CreateTimer(self, millis):
        self.timer = wx.Timer(self, self.timerID)
        self.timer.Start(millis) #
        wx.EVT_TIMER(self, self.timerID, self.OnTimer)

    def OnTimer(self, event):
        """Service CEF message loop when useTimer is True"""
        cefpython.MessageLoopWork()

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
        self.GetBrowser().GetMainFrame().LoadUrl(url)


class ChromeCtrl(wx.Panel):
    def __init__(self, parent, url="", useTimer=False,
                 timerMillis=DEFAULT_TIMER_MILLIS, hasNavBar=True,
                 *args, **kwargs):
        wx.Panel.__init__(self, parent, *args, **kwargs)

        self.chromeWindow = ChromeWindow(self, url=str(url), useTimer=useTimer)
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

    def OnLoadError(self, browser, frame, errorCode, failedUrl, errorText):
        # TODO
        print("ERROR LOADING URL : %s" % failedUrl)

class CallbackClientHandler(object):
    def __init__(self, onLoadStart=None, onLoadEnd=None):
        self.onLoadStart = onLoadStart
        self.onLoadEnd = onLoadEnd

    def OnLoadStart(self, browser, frame):
        if self.onLoadStart and frame.GetUrl() != "about:blank":
            self.onLoadStart(browser, frame)

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        if self.onLoadEnd and frame.GetUrl() != "about:blank":
            self.onLoadEnd(browser, frame, httpStatusCode)

    def OnLoadError(self, browser, frame, errorCode, failedUrl, errorText):
        # TODO
        print("ERROR LOADING URL : %s" % failedUrl)

#-------------------------------------------------------------------------------

def Initialize(settings=None):
    """Initializes CEF, We should do it before initializing wx
       If no settings passed a default is used
    """
    sys.excepthook = ExceptHook
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
    if not "browser_subprocess_path" in settings: 
        settings["browser_subprocess_path"] = \
            "%s/%s" % (cefpython.GetModuleDirectory(), "subprocess")

    # DEBUGGING options:
    # ------------------
    # cefpython.g_debug = True
    # cefpython.g_debugFile = "debug.log"
    # settings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE
    # settings["log_file"] = "debug.log" # Set to "" to disable.
    # settings["release_dcheck_enabled"] = True
        
    cefpython.Initialize(settings)

def Shutdown():
    """Shuts down CEF, should be called by app exiting code"""
    cefpython.Shutdown()
