# Additional wx specific layer of abstraction for the cefpython
# __author__ = "Greg Kacy <grkacy@gmail.com>"

#-------------------------------------------------------------------------------

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Only 32bit architecture is supported")

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

def ExceptHook(excType, excValue, traceObject):
    import traceback, os, time, codecs
    # This hook does the following: in case of exception write it to
    # the "error.log" file, display it to the console, shutdown CEF
    # and exit application immediately by ignoring "finally" (_exit()).
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
        return self.browser

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
        cefpython.MessageLoopWork()

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
