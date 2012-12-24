# Additional wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Architecture not supported: %s" % platform.architecture()[0])

import sys
if sys.hexversion >= 0x02070000 and sys.hexversion < 0x03000000:
    import cefpython_py27 as cefpython
elif sys.hexversion >= 0x03000000 and sys.hexversion < 0x04000000:
    import cefpython_py32 as cefpython
else:
    raise Exception("Unsupported python version: %s" % sys.version)

import wx

#-------------------------------------------------------------------------------

TIMER_MILLIS = 10

#-------------------------------------------------------------------------------

class CEFWindow(wx.Window):
    """Standalone CEF component. The class provides facilites for interacting with wx message loop"""
    def __init__(self, parent, url="", size=(-1, -1), *args, **kwargs):
        wx.Window.__init__(self, parent, id=wx.ID_ANY, size=size, *args, **kwargs)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.GetHandle())
        self.browser = cefpython.CreateBrowserSync(windowInfo, browserSettings={}, navigateURL=url)

        self.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
        self.Bind(wx.EVT_SIZE, self.OnSize)

        self.timerID = 1
        self._createTimer()

    def GetBrowser(self):
        '''Returns the CEF's browser object'''
        return browser

    def __del__(self):
        '''cleanup stuff'''
        self.timer.Stop()
        self.browser.CloseBrowser()

    def _createTimer(self):
        # this timer's events services the SEF message loops
        self.timer = wx.Timer(self, self.timerID)
        self.timer.Start(TIMER_MILLIS) #
        wx.EVT_TIMER(self, self.timerID, self._onTimer)

    def _onTimer(self, event):
        """Service CEF message loop"""
        cefpython.SingleMessageLoop()

    def OnSetFocus(self, event):
        cefpython.WindowUtils.OnSetFocus(self.GetHandle(), 0, 0, 0)

    def OnSize(self, event):
        cefpython.WindowUtils.OnSize(self.GetHandle(), 0, 0, 0)

#-------------------------------------------------------------------------------

def initCEF():
    """Initializes CEF, We should do it before initializing wx"""
    sys.excepthook = cefpython.ExceptHook
    settings = {"log_severity": cefpython.LOGSEVERITY_VERBOSE, "release_dcheck_enabled": True}
    cefpython.Initialize(settings)

def shutdownCEF():
    """Shuts down CEF, should be called by app exiting code"""
    cefpython.Shutdown()
