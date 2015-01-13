# Simple sample ilustrating the usage of CEFWindow class.

# On Mac the cefpython library must be imported the very first,
# before any other libraries (Issue 155).
import cefpython3.wx.chromectrl as chrome

import os
import wx
import platform

class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='cefwx example1', size=(800,600))

        self.cefWindow = chrome.ChromeWindow(self,
                url=os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 "sample1.html"))

        sizer = wx.BoxSizer()
        sizer.Add(self.cefWindow, 1, wx.EXPAND, 0)
        self.SetSizer(sizer)

        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnClose(self, event):
        # Remember to destroy all CEF browser references before calling
        # Destroy(), so that browser closes cleanly. In this specific
        # example there are no references kept, but keep this in mind
        # for the future.
        self.Destroy()
        # On Mac the code after app.MainLoop() never executes, so
        # need to call CEF shutdown here.
        if platform.system() == "Darwin":
            chrome.Shutdown()
            wx.GetApp().Exit()

class MyApp(wx.App):
    def OnInit(self):
        frame = MainFrame()
        self.SetTopWindow(frame)
        frame.Show()
        return True

if __name__ == '__main__':
    chrome.Initialize({
        "debug": True,
        "log_file": "debug.log",
        "log_severity": chrome.cefpython.LOGSEVERITY_INFO,
        "release_dcheck_enabled": True,
        # "cache_path": "webcache/",
    })
    print('[sample1.py] wx.version=%s' % wx.version())
    app = MyApp(False)
    app.MainLoop()
    # Important: do the wx cleanup before calling Shutdown
    del app
    # On Mac Shutdown is called in OnClose
    if platform.system() in ["Linux", "Windows"]:
        chrome.Shutdown()
