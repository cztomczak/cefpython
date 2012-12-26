# Slightly more advanced sample illustrating the usage of CEFWindow class
# __author__ = "Greg Kacy <grkacy@gmail.com>"

import wx
import wx.lib.agw.flatnotebook as fnb

from cefwxpanel import initCEF, shutdownCEF, CEFWindow

ROOT_NAME = "My Locations"

URLS = ["cefsimple.html",
        "http://google.com",
        "http://maps.google.com",
        "http://youtube.com",
        "http://yahoo.com",
        "http://wikipedia.com",
        "http://cyaninc.com",
        ]

class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY, title='wxPython example', size=(600,400))
        self.initComponents()
        self.layoutComponents()
        self.initEventHandlers()

    def initComponents(self):
        self.tree = wx.TreeCtrl(self, id=-1, size=(200, -1))
        self.root = self.tree.AddRoot(ROOT_NAME)
        for url in URLS:
            self.tree.AppendItem(self.root, url)
        self.tree.Expand(self.root)

        self.tabs = fnb.FlatNotebook(self, wx.ID_ANY, agwStyle=fnb.FNB_NODRAG|fnb.FNB_X_ON_TAB)

    def layoutComponents(self):
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(self.tree, 0, wx.EXPAND)
        sizer.Add(self.tabs, 1, wx.EXPAND)
        self.SetSizer(sizer)

    def initEventHandlers(self):
        self.Bind(wx.EVT_TREE_SEL_CHANGED, self.OnSelChanged, self.tree)
        self.Bind(fnb.EVT_FLATNOTEBOOK_PAGE_CLOSING, self.OnPageClosing)
        self.Bind(wx.EVT_CLOSE, self.OnClose)

    def OnSelChanged(self, event):
        self.item = event.GetItem()
        url = self.tree.GetItemText(self.item)
        if url and url != ROOT_NAME:
            cefPanel = CEFWindow(self.tabs, url=str(url))
            self.tabs.AddPage(cefPanel, url)
            self.tabs.SetSelection(self.tabs.GetPageCount()-1)
        event.Skip()

    def OnPageClosing(self, event):
        print "One could place some extra closing stuff here"
        event.Skip()

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

