# Example of embedding CEF Python browser using PyGObject/PyGI (GTK 3).
#
# Tested configurations:
# - GTK 3.24 on Windows (cefpython v147, PyGObject 3.58, Python 3.11 and 3.14)
# - GTK 3.24 on Linux (cefpython v147, PyGObject 3.56, Python 3.14)
#
# On Windows PyGObject 3.52+ is required (GIRepository 3.0).
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
from gi.repository import Gtk, GLib, GdkPixbuf  # noqa

# Fix for PyCharm hints warnings when using static methods
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Windows imports
if WINDOWS:
    gi.require_version("GIRepository", "3.0")
    # noinspection PyUnresolvedReferences
    from gi.repository import GIRepository

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
    assert int(cef.__version__.split(".")[0]) >= 147, "CEF Python v147+ required to run this"
    if not MAC:
        # On Mac exception hook doesn't work and is causing a strange error:
        # > Python[57738:d07] _createMenuRef called with existing principal
        # > MenuRef already associated with menu
        sys.excepthook = cef.ExceptHook  # To shutdown CEF processes on error
    cef.Initialize()
    app = Gtk3Example()
    SystemExit(app.run(sys.argv))

def get_win32_handle(gdk_window):
    if gdk_window is None:
        raise ValueError("Realize the GTK widget before getting its window handle")

    repo = GIRepository.Repository.new()
    repo.require("Gdk", "3.0", 0)
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.GetModuleHandleW.argtypes = [ctypes.c_wchar_p]
    kernel32.GetModuleHandleW.restype = ctypes.c_void_p
    kernel32.GetProcAddress.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
    kernel32.GetProcAddress.restype = ctypes.c_void_p

    address = None
    for library in repo.get_shared_libraries("Gdk") or []:
        module = kernel32.GetModuleHandleW(os.path.basename(library))
        if module:
            address = kernel32.GetProcAddress(module, b"gdk_win32_window_get_handle")
            if address:
                break
    if not address:
        raise RuntimeError("Could not find GDK's HWND function")

    capsule = gdk_window.__gpointer__
    get_name = ctypes.pythonapi.PyCapsule_GetName
    get_name.argtypes = [ctypes.py_object]
    get_name.restype = ctypes.c_char_p
    get_pointer = ctypes.pythonapi.PyCapsule_GetPointer
    get_pointer.argtypes = [ctypes.py_object, ctypes.c_char_p]
    get_pointer.restype = ctypes.c_void_p

    window_ptr = get_pointer(capsule, get_name(capsule))
    if not window_ptr:
        raise RuntimeError("Could not get the GdkWindow pointer")

    get_handle = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(address)
    hwnd = get_handle(window_ptr)
    if not hwnd:
        raise RuntimeError("GDK returned a null HWND")
    return int(hwnd)

class Gtk3Example(Gtk.Application):

    def __init__(self):
        super(Gtk3Example, self).__init__(application_id='cefpython.gtk3')
        self.browser = None
        self.window = None
        self.browser_area = None
        self.browser_area_handle = None

    def run(self, argv):
        GLib.timeout_add(10, self.on_timer)
        self.connect("startup", self.on_startup)
        self.connect("activate", self.on_activate)
        self.connect("shutdown", self.on_shutdown)
        return super(Gtk3Example, self).run(argv)

    def get_handle(self):
        if WINDOWS:
            return get_win32_handle(self.browser_area.get_window())
        elif LINUX:
            return self.browser_area.get_window().get_xid()
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
        if LINUX:
            # Put the window on the X server's default visual before it is
            # realized, otherwise the browser stays blank (Issue #701).
            screen = self.window.get_screen()
            self.window.set_visual(GdkX11.X11Screen.lookup_visual(
                    screen, WindowUtils.GetX11DefaultVisualId(
                            screen.get_screen_number())))
        self.window.set_title("GTK 3 example (PyGObject)")
        self.window.set_default_size(800, 600)
        self.window.connect("configure-event", self.on_configure)
        self.window.connect("focus-in-event", self.on_focus_in)
        self.window.connect("delete-event", self.on_window_close)
        # Embed the browser in a child widget, not in the window itself.
        # GTK may draw the title bar inside the window, and the browser
        # would cover it.
        self.browser_area = Gtk.DrawingArea()
        self.window.add(self.browser_area)
        self.browser_area.connect("size-allocate", self.on_size_allocate)
        self.add_window(self.window)
        self.setup_icon()

    def on_activate(self, *_):
        self.browser_area.realize()
        self.embed_browser()
        self.window.show_all()

    def embed_browser(self):
        self.browser_area_handle = self.get_handle()
        window_info = cef.WindowInfo()
        # TODO: on Mac pass rect[x, y, width, height] to SetAsChild
        window_info.SetAsChild(self.browser_area_handle)
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(LifespanHandler(self))

    def on_configure(self, *_):
        if self.browser:
            self.browser.NotifyMoveOrResizeStarted()
        return False

    def on_size_allocate(self, _, data):
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.browser_area_handle, 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(data.x, data.y,
                                       data.width, data.height)

    def on_focus_in(self, *_):
        if self.browser:
            self.browser.SetFocus(True)
            return True
        return False

    def on_window_close(self, *_):
        # Close the browser before the window, as CEF requires (see
        # LifespanHandler.DoClose). TryCloseBrowser() starts closing it and
        # returns False until it is closed. CEF then calls
        # LifespanHandler.OnBeforeClose, which closes the window again.
        if self.browser and not self.browser.TryCloseBrowser():
            return True
        return False

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


class LifespanHandler(object):
    def __init__(self, app):
        self.app = app

    def OnBeforeClose(self, browser, **_):
        # Popups inherit this handler from the main browser
        if browser.IsPopup():
            return
        self.app.clear_browser_references()
        # See on_window_close()
        self.app.window.close()


if __name__ == '__main__':
    main()
