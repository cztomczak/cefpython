# Example of embedding CEF Python browser using wxPython library.
# This example has a top menu and a browser widget without navigation bar.

# Tested configurations:
# - wxPython 4.0 on Windows/Mac/Linux
# - wxPython 3.0 on Windows/Mac
# - wxPython 2.8 on Linux
# - CEF Python v66.0+

import wx
from cefpython3 import cefpython as cef
import ctypes
import platform
import sys
import os

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# CEF only supports X11 on Linux, so put GTK on its X11 backend (XWayland
# in Wayland sessions), where GetHandle() returns an X11 window ID that the
# browser can be embedded into. Must be set before wx.App is created.
if LINUX:
    os.environ["GDK_BACKEND"] = "x11"

if MAC:
    try:
        # noinspection PyUnresolvedReferences
        from AppKit import NSApp
    except ImportError:
        print("[wxpython.py] Error: PyObjC package is missing, "
              "cannot fix Issue #371")
        print("[wxpython.py] To install PyObjC type: "
              "pip install -U pyobjc")
        sys.exit(1)

# Configuration
WIDTH = 900
HEIGHT = 640

# Globals
g_count_windows = 0


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    settings = {}
    if MAC:
        # Issue #442 requires enabling message pump on Mac
        # and calling message loop work in a timer both at
        # the same time. This is an incorrect approach
        # and only a temporary fix.
        settings["external_message_pump"] = True
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
    assert int(cef.__version__.split(".")[0]) >= 66, "CEF Python v66.0+ required to run this"


def scale_window_size_for_high_dpi(width, height):
    """Scale window size for high DPI devices. This func can be
    called on all operating systems, but scales only for Windows.
    If scaled value is bigger than the work area on the display
    then it will be reduced."""
    if not WINDOWS:
        return width, height
    (_, _, max_width, max_height) = wx.GetClientDisplayRect().Get()
    # noinspection PyUnresolvedReferences
    (width, height) = cef.DpiAware.Scale((width, height))
    if width > max_width:
        width = max_width
    if height > max_height:
        height = max_height
    return width, height


def set_default_x11_visual(widget):
    """Put a GTK 3 widget on the X server's default visual. GTK 3 may use a
    visual chosen for OpenGL instead, and CEF can't create its window inside
    a window with another visual (Issue #701). wxPython has no API for this,
    so call GTK through the libraries that wxPython itself is linked against,
    as wxWidgets' own wxWebViewChromium does. Must be called before the
    widget is realized. Prints an error and returns False if the visual
    could not be set."""
    ptr = ctypes.c_void_p
    try:
        lib = ctypes.CDLL(wx._core.__file__)
        for name, restype, argtypes in [
                ("gtk_widget_get_realized", ctypes.c_int, [ptr]),
                ("gtk_widget_get_screen", ptr, [ptr]),
                ("gtk_widget_set_visual", None, [ptr, ptr]),
                ("g_type_check_instance_is_a", ctypes.c_int,
                 [ptr, ctypes.c_size_t]),
                ("gdk_x11_screen_get_type", ctypes.c_size_t, []),
                ("gdk_screen_get_display", ptr, [ptr]),
                ("gdk_x11_display_get_xdisplay", ptr, [ptr]),
                ("gdk_x11_screen_get_screen_number", ctypes.c_int, [ptr]),
                ("gdk_x11_screen_lookup_visual", ptr,
                 [ptr, ctypes.c_ulong]),
                ("XDefaultVisual", ptr, [ptr, ctypes.c_int]),
                ("XVisualIDFromVisual", ctypes.c_ulong, [ptr])]:
            func = getattr(lib, name)
            func.restype = restype
            func.argtypes = argtypes
    except (AttributeError, OSError) as exc:
        print("[wxpython.py] Error: cannot call GTK through wxPython: %s"
              % exc)
        return False
    widget = int(widget) if widget else 0
    if not widget or lib.gtk_widget_get_realized(widget):
        print("[wxpython.py] Error: the GTK widget is missing or already"
              " realized")
        return False
    screen = lib.gtk_widget_get_screen(widget)
    if not lib.g_type_check_instance_is_a(screen,
                                          lib.gdk_x11_screen_get_type()):
        print("[wxpython.py] Error: the GTK widget is not on an X11 screen")
        return False
    xdisplay = lib.gdk_x11_display_get_xdisplay(
            lib.gdk_screen_get_display(screen))
    xvisual = lib.XDefaultVisual(xdisplay,
                                 lib.gdk_x11_screen_get_screen_number(screen))
    visual = lib.gdk_x11_screen_lookup_visual(
            screen, lib.XVisualIDFromVisual(xvisual))
    if not visual:
        print("[wxpython.py] Error: GDK has no visual for the X server's"
              " default visual")
        return False
    lib.gtk_widget_set_visual(widget, visual)
    return True


class MainFrame(wx.Frame):

    def __init__(self):
        self.browser = None

        # Must ignore X11 errors like 'BadWindow' and others by
        # installing X11 error handlers. This must be done after
        # wx was intialized.
        if LINUX:
            cef.WindowUtils.InstallX11ErrorHandlers()

        global g_count_windows
        g_count_windows += 1

        if WINDOWS:
            # noinspection PyUnresolvedReferences, PyArgumentList
            print("[wxpython.py] System DPI settings: %s"
                  % str(cef.DpiAware.GetSystemDpi()))
        if hasattr(wx, "GetDisplayPPI"):
            print("[wxpython.py] wx.GetDisplayPPI = %s" % wx.GetDisplayPPI())
        print("[wxpython.py] wx.GetDisplaySize = %s" % wx.GetDisplaySize())

        print("[wxpython.py] MainFrame declared size: %s"
              % str((WIDTH, HEIGHT)))
        size = scale_window_size_for_high_dpi(WIDTH, HEIGHT)
        print("[wxpython.py] MainFrame DPI scaled size: %s" % str(size))

        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                          title='wxPython example', size=size)
        # wxPython will set a smaller size when it is bigger
        # than desktop size.
        print("[wxpython.py] MainFrame actual size: %s" % self.GetSize())

        self.setup_icon()
        self.create_menu()
        self.Bind(wx.EVT_CLOSE, self.OnClose)

        # Set wx.WANTS_CHARS style for the keyboard to work.
        # This style also needs to be set for all parent controls.
        self.browser_panel = wx.Panel(self, style=wx.WANTS_CHARS)
        self.browser_panel.Bind(wx.EVT_SET_FOCUS, self.OnSetFocus)
        self.browser_panel.Bind(wx.EVT_SIZE, self.OnSize)

        if MAC:
            # Make the content view for the window have a layer.
            # This will make all sub-views have layers. This is
            # necessary to ensure correct layer ordering of all
            # child views and their layers. This fixes Window
            # glitchiness during initial loading on Mac (Issue #371).
            NSApp.windows()[0].contentView().setWantsLayer_(True)

        if LINUX:
            # Put the browser panel on the X server's default visual before
            # it is realized (shown), otherwise CEF can't create its window
            # with GTK 3 (Issue #701). Without that window the browser stays
            # blank and the frame can't be closed (see OnClose), so leave the
            # panel empty then.
            if "gtk3" in wx.PlatformInfo and not set_default_x11_visual(
                    self.browser_panel.GetGtkWidget()):
                print("[wxpython.py] Error: the browser is not embedded")
            else:
                # The browser can only be embedded once GTK has realized the
                # panel and its X11 window exists (Issues #347, #349). wxGTK
                # sends EVT_WINDOW_CREATE at that point, possibly during
                # Show().
                self.browser_panel.Bind(wx.EVT_WINDOW_CREATE,
                                        self.OnBrowserPanelCreate)
            self.Show()
        else:
            self.embed_browser()
            self.Show()

    def OnBrowserPanelCreate(self, event):
        event.Skip()
        if event.GetWindow() is self.browser_panel and not self.browser:
            self.embed_browser()

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
        menubar = wx.MenuBar()
        menubar.Append(filemenu, "&File")
        self.SetMenuBar(menubar)

    def embed_browser(self):
        window_info = cef.WindowInfo()
        (width, height) = self.browser_panel.GetClientSize().Get()
        assert self.browser_panel.GetHandle(), "Window handle not available"
        window_info.SetAsChild(self.browser_panel.GetHandle(),
                               [0, 0, width, height])
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(FocusHandler())
        self.browser.SetClientHandler(LifespanHandler(self))

    def OnSetFocus(self, _):
        if not self.browser:
            return
        if WINDOWS:
            cef.WindowUtils.OnSetFocus(self.browser_panel.GetHandle(),
                                       0, 0, 0)
        self.browser.SetFocus(True)

    def OnSize(self, _):
        if not self.browser:
            return
        if WINDOWS:
            cef.WindowUtils.OnSize(self.browser_panel.GetHandle(),
                                   0, 0, 0)
        elif LINUX:
            (x, y) = (0, 0)
            (width, height) = self.browser_panel.GetSize().Get()
            self.browser.NotifyMoveOrResizeStarted()
            self.browser.SetBounds(x, y, width, height)
            return
        self.browser.NotifyMoveOrResizeStarted()

    def OnClose(self, event):
        print("[wxpython.py] OnClose called")
        if MAC:
            if not self.browser:
                # May already be closing, may be called multiple times on Mac
                return
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
            return
        # Close the browser before the window, as CEF requires (see
        # LifespanHandler.DoClose). TryCloseBrowser() starts closing it and
        # returns False until the window may close. CEF then sends another
        # close request, except on Linux, where LifespanHandler.OnBeforeClose
        # closes the window.
        if self.browser and not self.browser.TryCloseBrowser():
            event.Veto()
            return
        event.Skip()

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


class LifespanHandler(object):
    def __init__(self, frame):
        self.frame = frame

    def OnBeforeClose(self, browser, **_):
        # Popups inherit this handler from the main browser
        if browser.IsPopup():
            return
        self.frame.clear_browser_references()
        if LINUX:
            # CEF on Linux sends its close message to its own window, not
            # to the frame, so close the frame here (see MainFrame.OnClose)
            self.frame.Close()


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
        cef.MessageLoopWork()

    def OnExit(self):
        self.timer.Stop()
        return 0


if __name__ == '__main__':
    main()
