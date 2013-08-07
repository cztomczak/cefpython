# Slightly more advanced sample illustrating the usage of CEFWindow class
# __author__ = "Greg Kacy <grkacy@gmail.com>"

import os
import wx
import wx.lib.agw.flatnotebook as fnb
import cefpython3.wx.chromectrl as chrome

class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='cefwx example3', size=(800,600))
        self._InitComponents()
        self._LayoutComponents()
        self._InitEventHandlers()

    def _InitComponents(self):
        self.tabs = fnb.FlatNotebook(self, wx.ID_ANY,
                                     agwStyle=fnb.FNB_NODRAG|fnb.FNB_X_ON_TAB)
        # You also have to set the wx.WANTS_CHARS style for
        # all parent panels/controls, if it's deeply embedded.
        self.tabs.SetWindowStyleFlag(wx.WANTS_CHARS)

        ctrl1 = chrome.ChromeCtrl(self.tabs, useTimer=True,
                                  url="wikipedia.org")
        ctrl1.GetNavigationBar().GetUrlCtrl().SetEditable(False)
        ctrl1.GetNavigationBar().GetBackButton().SetBitmapLabel(
            wx.Bitmap(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                   "back.png"), wx.BITMAP_TYPE_PNG))
        ctrl1.GetNavigationBar().GetForwardButton().SetBitmapLabel(
            wx.Bitmap(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    "forward.png"), wx.BITMAP_TYPE_PNG))
        ctrl1.GetNavigationBar().GetReloadButton().SetBitmapLabel(
            wx.Bitmap(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    "reload_page.png"), wx.BITMAP_TYPE_PNG))

        self.tabs.AddPage(ctrl1, "Wikipedia")

        ctrl2 = chrome.ChromeCtrl(self.tabs, useTimer=True, url="google.com",
                                  hasNavBar=False)
        self.tabs.AddPage(ctrl2, "Google")

        ctrl3 = chrome.ChromeCtrl(self.tabs, useTimer=True, url="greenpeace.org")
        ctrl3.SetNavigationBar(CustomNavigationBar(ctrl3))
        self.tabs.AddPage(ctrl3, "Greenpeace")

    def _LayoutComponents(self):
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(self.tabs, 1, wx.EXPAND)
        self.SetSizer(sizer)

    def _InitEventHandlers(self):
        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnClose(self, event):
        self.Destroy()


class CustomNavigationBar(chrome.NavigationBar):
    def _LayoutComponents(self):
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(self.url, 1, wx.EXPAND|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 12)

        sizer.Add(self.GetBackButton(), 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|
                  wx.ALL, 0)
        sizer.Add(self.GetForwardButton(), 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|
                  wx.ALL, 0)
        # in this example we dont want reload button
        self.GetReloadButton().Hide()
        self.SetSizer(sizer)
        self.Fit()

if __name__ == '__main__':
    chrome.Initialize()
    print('sample3.py: wx.version=%s' % wx.version())
    app = wx.PySimpleApp()
    MainFrame().Show()
    app.MainLoop()
    # Important: do the wx cleanup before calling Shutdown.
    del app
    chrome.Shutdown()

