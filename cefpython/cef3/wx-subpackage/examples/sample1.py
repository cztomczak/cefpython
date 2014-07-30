# Simple sample ilustrating the usage of CEFWindow class
# __author__ = "Greg Kacy <grkacy@gmail.com>"

import os
import wx
import cefpython3.wx.chromectrl as chrome

class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='cefwx example1', size=(1024,768))

        self.cefWindow = chrome.ChromeWindow(self,
                url=os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 "sample1.html"))

        sizer = wx.BoxSizer()
        sizer.Add(self.cefWindow, 1, wx.EXPAND, 0)
        self.SetSizer(sizer)

        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnClose(self, event):
        self.Destroy()

if __name__ == '__main__':
    chrome.Initialize({
        "debug": True,
        "log_severity": chrome.cefpython.LOGSEVERITY_INFO,
        "release_dcheck_enabled": True,
    })
    print('[sample1.py] wx.version=%s' % wx.version())
    app = wx.PySimpleApp()
    MainFrame().Show()
    app.MainLoop()
    # Important: do the wx cleanup before calling Shutdown.
    del app
    chrome.Shutdown()
