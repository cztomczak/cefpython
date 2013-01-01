# Simple sample ilustrating the usage of CEFWindow class
# __author__ = "Greg Kacy <grkacy@gmail.com>"

import wx

from cefwxpanel import initCEF, shutdownCEF, CEFWindow, GetApplicationPath

class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY, title='wxPython example', size=(600,400))

        self.cefPanel = CEFWindow(self,
                url=GetApplicationPath("cefsimple.html"))

        sizer = wx.BoxSizer()
        sizer.Add(self.cefPanel, 1, wx.EXPAND, 0)
        self.SetSizer(sizer)

        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnClose(self, event):
        self.Destroy()

if __name__ == '__main__':
    initCEF()
    print('wx.version=%s' % wx.version())
    app = wx.PySimpleApp()
    MainFrame().Show()
    app.MainLoop()
    del app # Let wx.App destructor do the cleanup before calling cefpython.Shutdown().
    shutdownCEF()


