# Example of embedding CEF Python browser using wxPython library.
# This example has a top menu and a browser widget without navigation bar.

# To install wxPython on Linux type "sudo apt-get install python-wxtools".

# Tested with wxPython 2.8 on Linux, wxPython 3.0 on Windows/Mac
# and CEF Python v55.3.

import wx
from cefpython3 import cefpython as cef
import platform
import sys
import os

# Constants
LINUX = (platform.system() == "Linux")
WINDOWS = (platform.system() == "Windows")
WIDTH = 800
HEIGHT = 600


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    app = CefApp(False)
    app.MainLoop()
    del app  # Must destroy before calling Shutdown
    cef.Shutdown()


def check_versions():
    print("[wxpython.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[wxpython.py] Python {ver}".format(ver=sys.version[:6]))
    print("[wxpython.py] wx {ver}".format(ver=wx.version()))
    # CEF Python version requirement
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"


class MainFrame(wx.Frame):

    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='wxPython example', size=(WIDTH, HEIGHT))
        self.browser = None

        self.setup_icon()
        self.create_menu()
        self.Bind(wx.EVT_CLOSE, self.OnClose)

        # Set wx.WANTS_CHARS style for the keyboard to work.
        # This style also needs to be set for all parent controls.
        self.browser_panel = wx.Panel(self, style=wx.WANTS_CHARS)
        self.browser_panel.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
        self.browser_panel.Bind(wx.EVT_SIZE, self.OnSize)

        # Must show so that handle is available when embedding browser
        self.Show()
        self.embed_browser()

    def setup_icon(self):
        icon_file = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                 "resources", "wxpython.png")
        if os.path.exists(icon_file):
            icon = wx.IconFromBitmap(wx.Bitmap(icon_file, wx.BITMAP_TYPE_PNG))
            self.SetIcon(icon)

    def create_menu(self):
        filemenu = wx.Menu()
        filemenu.Append(1, "Open")
        exit_ = filemenu.Append(2, "Exit")
        self.Bind(wx.EVT_MENU, self.OnClose, exit_)
        aboutmenu = wx.Menu()
        aboutmenu.Append(1, "CEF Python")
        menubar = wx.MenuBar()
        menubar.Append(filemenu, "&File")
        menubar.Append(aboutmenu, "&About")
        self.SetMenuBar(menubar)

    def embed_browser(self):
        window_info = cef.WindowInfo()
        window_info.SetAsChild(self.browser_panel.GetHandle())
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(FocusHandler())

    def OnSetFocus(self, _):
        if not self.brower:
            return
        if WINDOWS:
            # noinspection PyUnresolvedReferences
            cef.WindowUtils.OnSetFocus(self.GetHandleForBrowser(), 0, 0, 0)
        self.browser.SetFocus(True)

    def OnSize(self, _):
        if not self.browser:
            return
        if WINDOWS:
            # noinspection PyUnresolvedReferences
            cef.WindowUtils.OnSize(self.GetHandleForBrowser(), 0, 0, 0)
        elif LINUX:
            (x, y) = (0, 0)
            (width, height) = self.browser_panel.GetSizeTuple()
            # noinspection PyUnresolvedReferences
            self.browser.SetBounds(x, y, width, height)

    def OnClose(self, event):
        # In cefpython3.wx.chromectrl example calling browser.CloseBrowser()
        # and/or self.Destroy() in OnClose is causing crashes when
        # embedding multiple browser tabs. The solution is to call only
        # browser.ParentWindowWillClose. Behavior of this example
        # seems different as it extends wx.Frame, while ChromeWindow
        # from chromectrl extends wx.Window. Calling CloseBrowser
        # and Destroy does not cause crashes, but is not recommended.
        # Call ParentWindowWillClose and event.Skip() instead. See
        # also Issue #107: https://github.com/cztomczak/cefpython/issues/107
        self.browser.ParentWindowWillClose()
        event.Skip()

        # Clear all browser references for CEF to shutdown cleanly
        del self.browser


class FocusHandler(object):

    def __init__(self):
        pass

    def OnTakeFocus(self, **kwargs):
        # print("[wxpython.py] FocusHandler.OnTakeFocus, next={next}"
        #       .format(next=kwargs["next_component"]]))
        pass

    def OnSetFocus(self, **kwargs):
        # source_enum = {cef.FOCUS_SOURCE_NAVIGATION: "navigation",
        #                cef.FOCUS_SOURCE_SYSTEM:     "system"}
        # print("[wxpython.py] FocusHandler.OnSetFocus, source={source}"
        #       .format(source=source_enum[kwargs["source"]]))
        # return False
        pass

    def OnGotFocus(self, browser, **_):
        # Temporary fix for focus issues on Linux (Issue #284).
        # If this is not applied then when switching to another
        # window (alt+tab) and then back to this example, keyboard
        # focus becomes broken, you can't type anything, even
        # though a type cursor blinks in web view.
        print("[wxpython.py] FocusHandler.OnGotFocus:"
              " keyboard focus fix (#284)")
        browser.SetFocus(True)


class CefApp(wx.App):

    def __init__(self, redirect):
        self.timer = None
        self.timer_id = 1
        super(CefApp, self).__init__(redirect=redirect)

    def OnInit(self):
        self.create_timer()
        frame = MainFrame()
        self.SetTopWindow(frame)
        frame.Show()
        return True

    def create_timer(self):
        # See also "Making a render loop":
        # http://wiki.wxwidgets.org/Making_a_render_loop
        # Another way would be to use EVT_IDLE in MainFrame.
        self.timer = wx.Timer(self, self.timer_id)
        self.timer.Start(10)  # 10ms
        wx.EVT_TIMER(self, self.timer_id, self.on_timer)

    def on_timer(self, _):
        cef.MessageLoopWork()

    def OnExit(self):
        self.timer.Stop()


if __name__ == '__main__':
    main()
