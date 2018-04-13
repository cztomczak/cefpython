# Example of embedding CEF Python browser using wxPython library.
# This example has a top menu and a browser widget without navigation bar.

# Tested configurations:
# - wxPython 4.0 on Windows/Mac/Linux
# - wxPython 3.0 on Windows/Mac
# - wxPython 2.8 on Linux
# - CEF Python v55.4+

import wx
from cefpython3 import cefpython as cef
import platform
import sys
import os

# Fix for PyCharm hints warnings when using static methods
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Configuration
WIDTH = 800
HEIGHT = 600

# Globals
g_count_windows = 0


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    settings = {}
    if WINDOWS:
        # noinspection PyUnresolvedReferences, PyArgumentList
        cef.DpiAware.EnableHighDpiSupport()
    cef.Initialize(settings=settings)
    app = CefApp(False)
    app.MainLoop()
    del app  # Must destroy before calling Shutdown
    if not MAC:
        # On Mac shutdown is called in OnClose
        cef.Shutdown()


def check_versions():
    print("[wxpython.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[wxpython.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[wxpython.py] wxPython {ver}".format(ver=wx.version()))
    # CEF Python version requirement
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"


class MainFrame(wx.Frame):

    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='wxPython example', size=(WIDTH, HEIGHT))
        self.browser = None

        # Must ignore X11 errors like 'BadWindow' and others by
        # installing X11 error handlers. This must be done after
        # wx was intialized.
        if LINUX:
            WindowUtils.InstallX11ErrorHandlers()

        global g_count_windows
        g_count_windows += 1

        self.setup_icon()
        self.create_menu()
        self.Bind(wx.EVT_CLOSE, self.OnClose)

        # Set wx.WANTS_CHARS style for the keyboard to work.
        # This style also needs to be set for all parent controls.
        self.browser_panel = wx.Panel(self, style=wx.WANTS_CHARS)
        self.browser_panel.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
        self.browser_panel.Bind(wx.EVT_SIZE, self.OnSize)

        if MAC:
            try:
                # noinspection PyUnresolvedReferences
                from AppKit import NSApp
                # Make the content view for the window have a layer.
                # This will make all sub-views have layers. This is
                # necessary to ensure correct layer ordering of all
                # child views and their layers. This fixes Window
                # glitchiness during initial loading on Mac (Issue #371).
                NSApp.windows()[0].contentView().setWantsLayer_(True)
            except ImportError:
                print("[wxpython.py] Warning: PyObjC package is missing, "
                      "cannot fix Issue #371")
                print("[wxpython.py] To install PyObjC type: "
                      "pip install -U pyobjc")

        if LINUX:
            # On Linux must show before embedding browser, so that handle
            # is available (Issue #347).
            self.Show()
            # In wxPython 3.0 and wxPython 4.0 on Linux handle is
            # still not yet available, so must delay embedding browser
            # (Issue #349).
            if wx.version().startswith("3.") or wx.version().startswith("4."):
                wx.CallLater(100, self.embed_browser)
            else:
                # This works fine in wxPython 2.8 on Linux
                self.embed_browser()
        else:
            self.embed_browser()
            self.Show()

    def setup_icon(self):
        icon_file = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                 "resources", "wxpython.png")
        # wx.IconFromBitmap is not available on Linux in wxPython 3.0/4.0
        if os.path.exists(icon_file) and hasattr(wx, "IconFromBitmap"):
            icon = wx.IconFromBitmap(wx.Bitmap(icon_file, wx.BITMAP_TYPE_PNG))
            self.SetIcon(icon)

    def create_menu(self):
        filemenu = wx.Menu()
        filemenu.Append(1, "Some option")
        filemenu.Append(2, "Another option")
        filemenu.Append(3, "PrintToPDF test1")
        filemenu.Append(4, "PrintToPDF test2")
        menubar = wx.MenuBar()
        menubar.Append(filemenu, "&File")
        self.SetMenuBar(menubar)
        self.Bind(wx.EVT_MENU, self.menu_handler)

    def menu_handler(self, event): 
      id = event.GetId()
      if id == 3:
        self.browser.PrintToPdf('test1.pdf', {'backgrounds_enabled': 1})
      if id == 4:
        self.browser.PrintToPdf('test2.pdf', {'backgrounds_enabled': 1}, func=self.OnPdfFinished)

    def OnPdfFinished(self, path, ok):
        if ok:
            print("self.OnPdfPrintFinished: ok %s" % path)
        else:
            print("self.OnPdfPrintFinished: error")

    def embed_browser(self):
        window_info = cef.WindowInfo()
        (width, height) = self.browser_panel.GetClientSize().Get()
        assert self.browser_panel.GetHandle(), "Window handle not available yet"
        window_info.SetAsChild(self.browser_panel.GetHandle(),
                               [0, 0, width, height])
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://github.com/cztomczak/cefpython")
        self.browser.SetClientHandler(FocusHandler())
        self.browser.SetClientHandler(DialogHandler())
        self.browser.SetClientHandler(PdfPrintCallback())

    def OnSetFocus(self, _):
        if not self.browser:
            return
        if WINDOWS:
            WindowUtils.OnSetFocus(self.browser_panel.GetHandle(),
                                   0, 0, 0)
        self.browser.SetFocus(True)

    def OnSize(self, _):
        if not self.browser:
            return
        if WINDOWS:
            WindowUtils.OnSize(self.browser_panel.GetHandle(),
                               0, 0, 0)
        elif LINUX:
            (x, y) = (0, 0)
            (width, height) = self.browser_panel.GetSize().Get()
            self.browser.SetBounds(x, y, width, height)
        self.browser.NotifyMoveOrResizeStarted()

    def OnClose(self, event):
        print("[wxpython.py] OnClose called")
        if not self.browser:
            # May already be closing, may be called multiple times on Mac
            return

        if MAC:
            # On Mac things work differently, other steps are required
            self.browser.CloseBrowser()
            self.clear_browser_references()
            self.Destroy()
            global g_count_windows
            g_count_windows -= 1
            if g_count_windows == 0:
                cef.Shutdown()
                wx.GetApp().ExitMainLoop()
                # Call _exit otherwise app exits with code 255 (Issue #162).
                # noinspection PyProtectedMember
                os._exit(0)
        else:
            # Calling browser.CloseBrowser() and/or self.Destroy()
            # in OnClose may cause app crash on some paltforms in
            # some use cases, details in Issue #107.
            self.browser.ParentWindowWillClose()
            event.Skip()
            self.clear_browser_references()

    def clear_browser_references(self):
        # Clear browser references that you keep anywhere in your
        # code. All references must be cleared for CEF to shutdown cleanly.
        self.browser = None


class FocusHandler(object):
    def OnGotFocus(self, browser, **_):
        # Temporary fix for focus issues on Linux (Issue #284).
        if LINUX:
            print("[wxpython.py] FocusHandler.OnGotFocus:"
                  " keyboard focus fix (Issue #284)")
            browser.SetFocus(True)


class DialogHandler(object):
    def OnFileDialog(self, browser, mode, title, default_file_path, accept_filters, selected_accept_filter, file_dialog_callback):
      file_real_path = os.path.realpath('test1.pdf')
      if os.path.exists(file_real_path):
        file_dialog_callback.Continue(0, [file_real_path])
        return True
      else:
        return False


class PdfPrintCallback(object):
    def OnPdfPrintFinished(self, path, ok):
        if ok:
            print("PdfPrintCallback.OnPdfPrintFinished: ok %s" % path)
        else:
            print("PdfPrintCallback.OnPdfPrintFinished: error")


class CefApp(wx.App):

    def __init__(self, redirect):
        self.timer = None
        self.timer_id = 1
        self.is_initialized = False
        super(CefApp, self).__init__(redirect=redirect)

    def OnPreInit(self):
        super(CefApp, self).OnPreInit()
        # On Mac with wxPython 4.0 the OnInit() event never gets
        # called. Doing wx window creation in OnPreInit() seems to
        # resolve the problem (Issue #350).
        if MAC and wx.version().startswith("4."):
            print("[wxpython.py] OnPreInit: initialize here"
                  " (wxPython 4.0 fix)")
            self.initialize()

    def OnInit(self):
        self.initialize()
        return True

    def initialize(self):
        if self.is_initialized:
            return
        self.is_initialized = True
        self.create_timer()
        frame = MainFrame()
        self.SetTopWindow(frame)
        frame.Show()

    def create_timer(self):
        # See also "Making a render loop":
        # http://wiki.wxwidgets.org/Making_a_render_loop
        # Another way would be to use EVT_IDLE in MainFrame.
        self.timer = wx.Timer(self, self.timer_id)
        self.Bind(wx.EVT_TIMER, self.on_timer, self.timer)
        self.timer.Start(10)  # 10ms timer

    def on_timer(self, _):
        if MAC:
            cef.MessageLoop()
        else:
            cef.MessageLoopWork()

    def OnExit(self):
        self.timer.Stop()
        return 0


if __name__ == '__main__':
    main()
