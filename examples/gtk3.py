# Example of embedding CEF Python browser using PyGObject/PyGI (GTK 3).
#
# Tested configurations:
# - GTK 3.18 on Windows (cefpython v53.1+)
# - GTK 3.10 on Linux (works with cefpython v53.1 and v57.0+)
#
# Mac crash: This example crashes on Mac with error message:
#            > _createMenuRef called with existing principal MenuRef..
#            Reported as Issue #310.


from cefpython3 import cefpython as cef
import ctypes
import gi
import os
import platform
import sys

gi.require_version("Gtk", "3.0")
# noinspection PyUnresolvedReferences
from gi.repository import Gtk, GObject, Gdk, GdkPixbuf  # noqa

# Fix for PyCharm hints warnings when using static methods
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
    print("[gkt3.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[gkt3.py] GTK {major}.{minor}".format(
            major=Gtk.get_major_version(),
            minor=Gtk.get_minor_version()))
    assert cef.__version__ >= "53.1", "CEF Python v53.1+ required to run this"
    if not MAC:
        # On Mac exception hook doesn't work and is causing a strange error:
        # > Python[57738:d07] _createMenuRef called with existing principal
        # > MenuRef already associated with menu
        sys.excepthook = cef.ExceptHook  # To shutdown CEF processes on error
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
        self.connect("startup", self.on_startup)
        self.connect("activate", self.on_activate)
        self.connect("shutdown", self.on_shutdown)
        return super(Gtk3Example, self).run(argv)

    def get_handle(self):
        if WINDOWS:
            Gdk.threads_enter()
            ctypes.pythonapi.PyCapsule_GetPointer.restype = ctypes.c_void_p
            ctypes.pythonapi.PyCapsule_GetPointer.argtypes = \
                [ctypes.py_object]
            gpointer = ctypes.pythonapi.PyCapsule_GetPointer(
                    self.window.get_property("window").__gpointer__, None)
            libgdk = ctypes.CDLL("libgdk-3-0.dll")
            self.win32_handle = libgdk.gdk_win32_window_get_handle(gpointer)
            Gdk.threads_leave()
            return self.win32_handle
        elif LINUX:
            return self.window.get_property("window").get_xid()
        elif MAC:
            # TODO: Must call libgdk.gdk_quartz_window_get_nsview(gpointer)
            #       similarly as on Windows.
            print("[gtk3.py] WARNING: get_handle not implemented on Mac")
            return 0

    def on_timer(self):
        cef.MessageLoopWork()
        return True

    def on_startup(self, *_):
        self.window = Gtk.ApplicationWindow.new(self)
        self.window.set_title("GTK 3 example (PyGObject)")
        self.window.set_default_size(800, 600)
        self.window.connect("configure-event", self.on_configure)
        self.window.connect("size-allocate", self.on_size_allocate)
        self.window.connect("focus-in-event", self.on_focus_in)
        self.window.connect("delete-event", self.on_window_close)
        self.add_window(self.window)
        self.setup_icon()

    def on_activate(self, *_):
        self.window.realize()
        self.embed_browser()
        self.window.show_all()
        # Must set size of the window again after it was shown,
        # otherwise browser occupies only part of the window area.
        self.window.resize(*self.window.get_default_size())

    def embed_browser(self):
        window_info = cef.WindowInfo()
        # TODO: on Mac pass rect[x, y, width, height] to SetAsChild
        window_info.SetAsChild(self.get_handle())
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")

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
        if self.browser:
            self.browser.CloseBrowser(True)
            self.clear_browser_references()

    def clear_browser_references(self):
        # Clear browser references that you keep anywhere in your
        # code. All references must be cleared for CEF to shutdown cleanly.
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
