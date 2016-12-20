# Example of embedding CEF Python browser using PyGTK library (GTK 2).
# Tested with GTK 2.24 and CEF Python v55.3+, only on Linux.
# Known issue on Linux: Keyboard focus problem (Issue #284).

from cefpython3 import cefpython as cef
import pygtk
import gtk
import gobject
import sys
import os

# In CEF you can run message loop in two ways (see API docs for more details):
# 1. By calling cef.MessageLoop() instead of an application-provided
#    message loop to get the best balance between performance and CPU
#    usage. This function will block until a quit message is received by
#    the system.
# 2. By calling cef.MessageLoopWork() in a timer - each call performs
#    a single iteration of CEF message loop processing.
MESSAGE_LOOP_BEST = 1
MESSAGE_LOOP_TIMER = 2  # Pass --message-loop-timer flag to script to use this
g_message_loop = None


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    configure_message_loop()
    cef.Initialize()
    gobject.threads_init()
    Gtk2Example()
    if g_message_loop == MESSAGE_LOOP_BEST:
        cef.MessageLoop()
    else:
        gtk.main()
    cef.Shutdown()


def check_versions():
    print("[gkt2.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[gkt2.py] Python {ver}".format(ver=sys.version[:6]))
    print("[gkt2.py] GTK {ver}".format(ver='.'.join(
                                           map(str, list(gtk.gtk_version)))))
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"
    pygtk.require('2.0')


def configure_message_loop():
    global g_message_loop
    if "--message-loop-timer" in sys.argv:
        print("[gkt2.py] Message loop mode: TIMER")
        g_message_loop = MESSAGE_LOOP_TIMER
        sys.argv.remove("--message-loop-timer")
    else:
        print("[gkt2.py] Message loop mode: BEST")
        g_message_loop = MESSAGE_LOOP_BEST
    if len(sys.argv) > 1:
        print("[gkt2.py] ERROR: unknown argument passed")
        sys.exit(1)


class Gtk2Example:

    def __init__(self):
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

        windowInfo = cef.WindowInfo()
        windowInfo.SetAsChild(self.main_window.window.xid)
        self.browser = cef.CreateBrowserSync(windowInfo, settings={},
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(LoadHandler())

        self.vbox.show()
        self.main_window.show()
        self.vbox.get_window().focus()
        self.main_window.get_window().focus()
        if g_message_loop == MESSAGE_LOOP_TIMER:
            gobject.timeout_add(10, self.on_timer)

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
            self.browser.SetBounds(x, y, width, height)

    def on_menubar_size_allocate(self, _, data):
        self.menubar_height = data.height

    def on_exit(self, *_):
        self.exiting = True
        self.browser.CloseBrowser(True)
        self.browser = None
        if g_message_loop == MESSAGE_LOOP_BEST:
            cef.QuitMessageLoop()
        else:
            gtk.main_quit()


class LoadHandler(object):

    def __init__(self):
        self.initial_app_loading = True

    def OnLoadStart(self, browser, **_):
        if self.initial_app_loading:
            # Temporary fix for focus issue during initial loading
            # on Linux (Issue #284). If this is not applied then
            # sometimes during initial loading, keyboard focus may
            # break and it is not possible to type anything, even
            # though a type cursor blinks in web view.
            print("[gtk2.py] LoadHandler.OnLoadStart:"
                  " keyboard focus fix (#284)")
            browser.SetFocus(True)
            self.initial_app_loading = False


if __name__ == '__main__':
    main()
