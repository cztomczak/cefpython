# Slightly more advanced sample illustrating the usage of CEFWindow class
# __author__ = "Greg Kacy <grkacy@gmail.com>"

# TODO: There is something wrong happening on Linux. CPU usage
#       for the python process is 100% all the time. This problem
#       does not occur on Windows, nor in sample1.py/sample3.py.
#       It must have something to do with invalid usage of the wx 
#       controls in this example.

import wx
import wx.lib.agw.flatnotebook as fnb
import cefpython3.wx.chromectrl as chrome
import platform
import sys

ROOT_NAME = "My Locations"

URLS = ["http://gmail.com",
        "http://maps.google.com",
        "http://youtube.com",
        "http://yahoo.com",
        "http://wikipedia.com",
        "http://cyaninc.com",
        "http://tavmjong.free.fr/INKSCAPE/MANUAL/web/svg_tests.php"
        ]


class MainFrame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='cefwx example2', size=(1024, 768))

        self.initComponents()
        self.layoutComponents()
        self.initEventHandlers()
        if len(sys.argv) == 2 and sys.argv[1] == "test-launch":
            wx.CallLater(500, self.testLaunch)

    def testLaunch(self):
        # This hash is checked by /tests/test-launch.sh script
        # to detect whether CEF initialized successfully.
        print("b8ba7d9945c22425328df2e21fbb64cd")
        self.Close()

    def initComponents(self):
        self.tree = wx.TreeCtrl(self, id=-1, size=(200, -1))
        self.root = self.tree.AddRoot(ROOT_NAME)
        for url in URLS:
            self.tree.AppendItem(self.root, url)
        self.tree.Expand(self.root)

        self.tabs = fnb.FlatNotebook(self, wx.ID_ANY,
                agwStyle=fnb.FNB_NODRAG | fnb.FNB_X_ON_TAB)
        # You also have to set the wx.WANTS_CHARS style for
        # all parent panels/controls, if it's deeply embedded.
        self.tabs.SetWindowStyleFlag(wx.WANTS_CHARS)

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
            cefPanel = chrome.ChromeCtrl(self.tabs, useTimer=True, url=str(url))
            self.tabs.AddPage(cefPanel, url)
            self.tabs.SetSelection(self.tabs.GetPageCount()-1)
        event.Skip()

    def OnPageClosing(self, event):
        print("sample2.py: One could place some extra closing stuff here")
        event.Skip()

    def OnClose(self, event):
        self.Destroy()


if __name__ == '__main__':
    chrome.Initialize()
    if platform.system() == "Linux":
        # CEF initialization fails intermittently on Linux during
        # launch of a subprocess (Issue 131). The solution is
        # to offload cpu for half a second after Initialize
        # has returned (it still runs some stuff in its thread).
        import time
        time.sleep(0.5)
    print('sample2.py: wx.version=%s' % wx.version())
    app = wx.PySimpleApp()
    MainFrame().Show()
    app.MainLoop()
    # Important: do the wx cleanup before calling Shutdown.
    del app
    chrome.Shutdown()

