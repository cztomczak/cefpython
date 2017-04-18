# Example of embedding CEF browser using PyGTK library (GTK 2).

# Tested configurations:
# - GTK 2.24 on Windows/Linux/Mac
# - CEF Python v55.3+

from cefpython3 import cefpython as cef
import pygtk
import gtk
import gobject
import os
import platform
import sys

# Fix for PyCharm hints warnings when using static methods
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# In CEF you can run message loop in two ways (see API ref for more details):
# 1. By calling cef.MessageLoopWork() in a timer - each call performs
#    a single iteration of CEF message loop processing.
# 2. By calling cef.MessageLoop() instead of an application-provided
#    message loop to get the best balance between performance and CPU
#    usage. This function will block until a quit message is received by
#    the system. This seem to work only on Linux in GTK example.
# NOTE: On Mac message loop timer doesn't work, so using CEF message
#       loop by default.
MESSAGE_LOOP_TIMER = 1
MESSAGE_LOOP_CEF = 2  # Pass --message-loop-cef flag to script on Linux
g_message_loop = None


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    configure_message_loop()
    cef.Initialize()
    gobject.threads_init()
    Gtk2Example()
    if g_message_loop == MESSAGE_LOOP_CEF:
        cef.MessageLoop()
    else:
        gtk.main()
    cef.Shutdown()


def check_versions():
    print("[gtk2.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[gtk2.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[gtk2.py] GTK {ver}".format(ver='.'.join(
                                           map(str, list(gtk.gtk_version)))))
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"
    pygtk.require('2.0')


def configure_message_loop():
    global g_message_loop
    if MAC and "--message-loop-cef" not in sys.argv:
        print("[gtk2.py] Force --message-loop-cef flag on Mac")
        sys.argv.append("--message-loop-cef")
    if "--message-loop-cef" in sys.argv:
        print("[gtk2.py] Message loop mode: CEF (best performance)")
        g_message_loop = MESSAGE_LOOP_CEF
        sys.argv.remove("--message-loop-cef")
    else:
        print("[gtk2.py] Message loop mode: TIMER")
        g_message_loop = MESSAGE_LOOP_TIMER


class Gtk2Example:
    def __init__(self):
        self.browser = None
        self.menubar_height = 0
        self.exiting = False

        self.main_window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.main_window.connect('focus-in-event', self.on_focus_in)
        self.main_window.connect('configure-event', self.on_configure)
        self.main_window.connect('destroy', self.on_exit)
        self.main_window.set_size_request(width=800, height=600)
        self.main_window.set_title('GTK 2 example (PyGTK)')
        icon = os.path.join(os.path.dirname(__file__), "resources", "gtk.png")
        if os.path.exists(icon):
            self.main_window.set_icon_from_file(icon)
        self.main_window.realize()

        self.vbox = gtk.VBox(False, 0)
        self.vbox.connect('size-allocate', self.on_vbox_size_allocate)
        self.menubar = self.create_menu()
        self.menubar.connect('size-allocate', self.on_menubar_size_allocate)
        self.vbox.pack_start(self.menubar, False, False, 0)
        self.main_window.add(self.vbox)

        # On Linux must show window first before embedding browser
        # (Issue #347).
        self.vbox.show()
        self.main_window.show()
        self.embed_browser()

        self.vbox.get_window().focus()
        self.main_window.get_window().focus()
        if g_message_loop == MESSAGE_LOOP_TIMER:
            gobject.timeout_add(10, self.on_timer)

    def embed_browser(self):
        windowInfo = cef.WindowInfo()
        size = self.main_window.get_size()
        rect = [0, 0, size[0], size[1]]
        windowInfo.SetAsChild(self.get_window_handle(), rect)
        self.browser = cef.CreateBrowserSync(windowInfo, settings={},
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(LoadHandler())

    def get_window_handle(self):
        if WINDOWS:
            return self.main_window.window.handle
        elif LINUX:
            return self.main_window.window.xid
        elif MAC:
            return self.main_window.window.nsview

    def create_menu(self):
        item1 = gtk.MenuItem('MenuBar')
        item1.show()
        item1_0 = gtk.Menu()
        item1_1 = gtk.MenuItem('Just a menu')
        item1_0.append(item1_1)
        item1_1.show()
        item1.set_submenu(item1_0)
        menubar = gtk.MenuBar()
        menubar.append(item1)
        menubar.show()
        return menubar

    def on_timer(self):
        if self.exiting:
            return False
        cef.MessageLoopWork()
        return True

    def on_focus_in(self, *_):
        if self.browser:
            self.browser.SetFocus(True)
            return True
        return False

    def on_configure(self, *_):
        if self.browser:
            self.browser.NotifyMoveOrResizeStarted()
        return False

    def on_vbox_size_allocate(self, _, data):
        if self.browser:
            x = data.x
            y = data.y + self.menubar_height
            width = data.width
            height = data.height - self.menubar_height
            if WINDOWS:
                WindowUtils.OnSize(self.get_window_handle(), 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(x, y, width, height)

    def on_menubar_size_allocate(self, _, data):
        self.menubar_height = data.height

    def on_exit(self, *_):
        if self.exiting:
            print("[gtk2.py] on_exit() called, but already exiting")
            return
        self.exiting = True
        self.browser.CloseBrowser(True)
        self.clear_browser_references()
        if g_message_loop == MESSAGE_LOOP_CEF:
            cef.QuitMessageLoop()
        else:
            gtk.main_quit()

    def clear_browser_references(self):
        # Clear browser references that you keep anywhere in your
        # code. All references must be cleared for CEF to shutdown cleanly.
        self.browser = None


class LoadHandler(object):
    def __init__(self):
        self.initial_app_loading = True

    def OnLoadStart(self, browser, **_):
        if self.initial_app_loading:
            # Temporary fix for focus issue during initial loading
            # on Linux (Issue #284).
            if LINUX:
                print("[gtk2.py] LoadHandler.OnLoadStart:"
                      " keyboard focus fix (Issue #284)")
                browser.SetFocus(True)
            self.initial_app_loading = False


if __name__ == '__main__':
    main()
