# Additional wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Only 32bit architecture is supported")

import sys
try:
    # Import local PYD file (portable zip).
    if sys.hexversion >= 0x02070000 and sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    elif sys.hexversion >= 0x03000000 and sys.hexversion < 0x04000000:
        import cefpython_py32 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
except ImportError:
    # Import from package (installer exe).
    from cefpython1 import cefpython

import wx

def GetApplicationPath(file=None):
    import re, os
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
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(file)

def ExceptHook(type, value, traceObject):
    import traceback, os, time
    # This hook does the following: in case of exception display it,
    # write to error.log, shutdown CEF and exit application.
    error = "\n".join(traceback.format_exception(type, value, traceObject))
    with open(GetApplicationPath("error.log"), "a") as file:
        file.write("\n[%s] %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), error))
    print("\n"+error+"\n")
    cefpython.QuitMessageLoop()
    cefpython.Shutdown()
    # So that "finally" does not execute.
    os._exit(1)

#-------------------------------------------------------------------------------

TIMER_MILLIS = 10

#-------------------------------------------------------------------------------

class CEFWindow(wx.Window):
    """Standalone CEF component. The class provides facilites for interacting with wx message loop"""
    def __init__(self, parent, url="", size=(-1, -1), *args, **kwargs):
        wx.Window.__init__(self, parent, id=wx.ID_ANY, size=size, *args, **kwargs)
        self.url = url
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.GetHandle())
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings={}, navigateUrl=url)

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

    #def Shutdown(self):
        #print "CLOSING PAGE %s, YA MAN" % self.url
        #self.timer.Stop()
        #self.browser.CloseBrowser()

#-------------------------------------------------------------------------------

def initCEF(settings=None):
    """Initializes CEF, We should do it before initializing wx
       If no settings passed a default is used
    """
    sys.excepthook = ExceptHook
    if not settings:
        settings = {
            "log_severity": cefpython.LOGSEVERITY_INFO,
            "log_file": GetApplicationPath("debug.log"),
            "release_dcheck_enabled": True # Enable only when debugging.
        }
    cefpython.Initialize(settings)

def shutdownCEF():
    """Shuts down CEF, should be called by app exiting code"""
    cefpython.Shutdown()
