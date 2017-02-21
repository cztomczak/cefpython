# Example of embedding CEF Python browser using PyGObject/PyGI (GTK 3).

# Linux note: This example is currently broken in v54+ on Linux (Issue #261).
#             It works fine with cefpython v53.

# Tested configurations:
# - GTK 3.18 on Windows
# - GTK 3.10 on Linux
# - CEF Python v53.1+

from cefpython3 import cefpython as cef
import ctypes
# noinspection PyUnresolvedReferences
from gi.repository import Gtk, GObject, Gdk, GdkPixbuf
import sys
import os
import platform

# Fix for PyCharm hints warnings
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Linux imports
if LINUX:
    # noinspection PyUnresolvedReferences
    from gi.repository import GdkX11


def main():
    print("[gkt3.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[gkt3.py] Python {ver}".format(ver=sys.version[:6]))
    print("[gkt3.py] GTK {major}.{minor}".format(
            major=Gtk.get_major_version(),
            minor=Gtk.get_minor_version()))
    assert cef.__version__ >= "53.1", "CEF Python v53.1+ required to run this"
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    app = Gtk3Example()
    SystemExit(app.run(sys.argv))


class Gtk3Example(Gtk.Application):

    def __init__(self):
        super(Gtk3Example, self).__init__(application_id='cefpython.gtk3')
        self.browser = None
        self.window = None
        self.win32_handle = None

    def run(self, argv):
        GObject.threads_init()
        GObject.timeout_add(10, self.on_timer)
        self.connect("activate", self.on_activate)
        self.connect("shutdown", self.on_shutdown)
        return super(Gtk3Example, self).run(argv)

    def get_handle(self):
        if LINUX:
            return self.window.get_property("window").get_xid()
        elif WINDOWS:
            Gdk.threads_enter()
            ctypes.pythonapi.PyCapsule_GetPointer.restype = ctypes.c_void_p
            ctypes.pythonapi.PyCapsule_GetPointer.argtypes = \
                [ctypes.py_object]
            gpointer = ctypes.pythonapi.PyCapsule_GetPointer(
                    self.window.get_property("window").__gpointer__, None)
            gdk_dll = ctypes.CDLL("libgdk-3-0.dll")
            self.win32_handle = gdk_dll.gdk_win32_window_get_handle(
                    gpointer)
            Gdk.threads_leave()
            return self.win32_handle

    def on_timer(self):
        cef.MessageLoopWork()
        return True

    def on_activate(self, *_):
        self.window = Gtk.ApplicationWindow.new(self)
        self.window.set_title("GTK 3 example (PyGObject)")
        self.window.set_default_size(800, 600)
        self.window.connect("configure-event", self.on_configure)
        self.window.connect("size-allocate", self.on_size_allocate)
        self.window.connect("focus-in-event", self.on_focus_in)
        self.window.connect("delete-event", self.on_window_close)
        self.setup_icon()
        self.window.realize()
        window_info = cef.WindowInfo()
        window_info.SetAsChild(self.get_handle())
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.window.show_all()
        # Must set size of the window again after it was shown,
        # otherwise browser occupies only part of the window area.
        self.window.resize(*self.window.get_default_size())

    def on_configure(self, *_):
        if self.browser:
            self.browser.NotifyMoveOrResizeStarted()
        return False

    def on_size_allocate(self, _, data):
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.win32_handle, 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(data.x, data.y,
                                       data.width, data.height)

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
