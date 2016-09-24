# Example of embedding CEF Python browser using PyGObject/Gtk library.
# Tested with GTK 3.10.

from cefpython3 import cefpython as cef
# noinspection PyUnresolvedReferences
from gi.repository import GdkX11, Gtk, GObject, GdkPixbuf
import sys
import os


def main():
    print("CEF Python {ver}".format(ver=cef.__version__))
    print("Python {ver}".format(ver=sys.version[:6]))
    print("GTK {major}.{minor}".format(
            major=Gtk.get_major_version(),
            minor=Gtk.get_minor_version()))
    assert cef.__version__ >= "53.1", "CEF Python v53.1+ required to run this"
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    app = GtkExample()
    SystemExit(app.run(sys.argv))


class GtkExample(Gtk.Application):

    def __init__(self):
        super(GtkExample, self).__init__(application_id='cefpython.gtk')
        self.browser = None
        self.window = None

    def run(self, argv):
        GObject.threads_init()
        GObject.timeout_add(10, self.on_timer)
        self.connect("activate", self.on_activate)
        self.connect("shutdown", self.on_shutdown)
        return super(GtkExample, self).run(argv)

    def on_timer(self):
        cef.MessageLoopWork()
        return True

    def on_activate(self, *_):
        self.window = Gtk.ApplicationWindow.new(self)
        self.window.set_title("Gtk example")
        self.window.set_default_size(800, 600)
        self.window.connect("configure-event", self.on_configure)
        self.window.connect("size-allocate", self.on_size_allocate)
        self.window.connect("focus-in-event", self.on_focus_in)
        self.window.connect("delete-event", self.on_window_close)
        self.setup_icon()
        self.window.realize()
        window_info = cef.WindowInfo()
        window_info.SetAsChild(self.window.get_property("window").get_xid())
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.window.show_all()

    def on_configure(self, *_):
        if self.browser:
            self.browser.NotifyMoveOrResizeStarted()
        return False

    def on_size_allocate(self, _, data):
        if self.browser:
            self.browser.SetBounds(data.x, data.y, data.width, data.height)

    def on_focus_in(self, *_):
        if self.browser:
            self.browser.SetFocus(True)
            return True
        return False

    def on_window_close(self, *_):
        # Close browser and free reference by setting to None
        self.browser.CloseBrowser(True)
        self.browser = None

    def on_shutdown(self, *_):
        cef.Shutdown()

    def setup_icon(self):
        icon = os.path.join(os.path.dirname(__file__), "resources", "gtk.png")
        if not os.path.exists(icon):
            return
        pixbuf = GdkPixbuf.Pixbuf.new_from_file(icon)
        transparent = pixbuf.add_alpha(True, 0xff, 0xff, 0xff)
        Gtk.Window.set_default_icon_list([transparent])


if __name__ == '__main__':
    main()
