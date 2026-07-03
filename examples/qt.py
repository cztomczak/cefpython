# Example of embedding CEF browser using PyQt5, PyQt6 and PySide6 libraries.
# This example has two widgets: a navigation bar and a browser.
#
# Tested configurations:
# - PyQt 5.8.2 (qt 5.8.0) on Windows/Linux/Mac
# - PyQt6 on Linux
# - PySide6 on Linux
# - CEF Python v55.4+

from cefpython3 import cefpython as cef
import os
import platform
import sys

# GLOBALS
PYQT5 = False
PYQT6 = False
PYSIDE6 = False

if "pyqt5" in sys.argv:
    PYQT5 = True
    # noinspection PyUnresolvedReferences
    from PyQt5.QtGui import *
    # noinspection PyUnresolvedReferences
    from PyQt5.QtCore import *
    # noinspection PyUnresolvedReferences
    from PyQt5.QtWidgets import *
elif "pyqt6" in sys.argv:
    PYQT6 = True
    # noinspection PyUnresolvedReferences
    from PyQt6.QtGui import *
    # noinspection PyUnresolvedReferences
    from PyQt6.QtCore import *
    # noinspection PyUnresolvedReferences
    from PyQt6.QtWidgets import *
elif "pyside6" in sys.argv:
    PYSIDE6 = True
    # noinspection PyUnresolvedReferences
    import PySide6
    # noinspection PyUnresolvedReferences
    from PySide6 import QtCore
    # noinspection PyUnresolvedReferences
    from PySide6.QtGui import *
    # noinspection PyUnresolvedReferences
    from PySide6.QtCore import *
    # noinspection PyUnresolvedReferences
    from PySide6.QtWidgets import *
else:
    print("USAGE:")
    print("  qt.py pyqt5")
    print("  qt.py pyqt6")
    print("  qt.py pyside6")
    sys.exit(1)

# Fix for PyCharm hints warnings when using static methods
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# CEF only supports X11 on Linux.  Force Qt onto the xcb (X11/XWayland)
# backend for all bindings so that winId() returns a real X11 window ID
# that CEF can embed into.  Wayland desktops (e.g. KDE Plasma on Kubuntu)
# often pre-set QT_QPA_PLATFORM=wayland in the session environment, so a
# hard override is needed — setdefault would not override a pre-set value.
# Must be set before creating QApplication.
if LINUX:
    os.environ["QT_QPA_PLATFORM"] = "xcb"

# Configuration
WIDTH = 800
HEIGHT = 600


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    settings = {}
    if MAC:
        # Issue #442 requires enabling message pump on Mac
        # in Qt example. Calling cef.DoMessageLoopWork in a timer
        # doesn't work anymore.
        settings["external_message_pump"] = True
    settings["context_menu"] = {
        "enabled": True,
        "navigation": True,
        "print": True,
        "view_source": True,
        "external_browser": True,
        "devtools": True,
    }

    cef.Initialize(settings)
    app = CefApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    main_window.activateWindow()
    main_window.raise_()
    if PYQT6 or PYSIDE6:
        app.exec()
    else:
        app.exec_()
    if not cef.GetAppSetting("external_message_pump") or LINUX:
        app.stopTimer()
    del main_window  # Just to be safe, similarly to "del app"
    del app  # Must destroy app object before calling Shutdown
    cef.Shutdown()


def check_versions():
    print("[qt.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[qt.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    if PYQT5 or PYQT6:
        print("[qt.py] PyQt {v1} (qt {v2})".format(
              v1=PYQT_VERSION_STR, v2=qVersion()))
    elif PYSIDE6:
        print("[qt.py] PySide6 {v1} (qt {v2})".format(
              v1=PySide6.__version__, v2=QtCore.__version__))
    # CEF Python version requirement
    assert tuple(int(x) for x in cef.__version__.split(".")) >= (55, 4), "CEF Python v55.4+ required to run this"


class MainWindow(QMainWindow):
    def __init__(self):
        # noinspection PyArgumentList
        super(MainWindow, self).__init__(None)
        self.cef_widget = None
        self.navigation_bar = None
        # True once CloseBrowser() has been requested; the window destruction
        # is deferred until OnBeforeClose fires (see closeEvent / CloseHandler).
        self._closing = False
        if PYQT5:
            self.setWindowTitle("PyQt5 example")
        elif PYQT6:
            self.setWindowTitle("PyQt6 example")
        elif PYSIDE6:
            self.setWindowTitle("PySide6 example")
        if PYQT6 or PYSIDE6:
            self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        else:
            self.setFocusPolicy(Qt.StrongFocus)
        self.setupLayout()

    def setupLayout(self):
        self.resize(WIDTH, HEIGHT)
        self.cef_widget = CefWidget(self)
        self.navigation_bar = NavigationBar(self.cef_widget)
        layout = QGridLayout()
        # noinspection PyArgumentList
        layout.addWidget(self.navigation_bar, 0, 0)
        # noinspection PyArgumentList
        layout.addWidget(self.cef_widget, 1, 0)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        layout.setRowStretch(0, 0)
        layout.setRowStretch(1, 1)
        # noinspection PyArgumentList
        frame = QFrame()
        frame.setLayout(layout)
        self.setCentralWidget(frame)

        if WINDOWS:
            # On Windows with PyQt5 main window must be shown first
            # before CEF browser is embedded, otherwise window is
            # not resized and application hangs during resize.
            self.show()

        # Browser can be embedded only after layout was set up
        self.cef_widget.embedBrowser()

        if LINUX and PYQT5:
            # On Linux with PyQt5 QX11EmbedContainer is no longer available.
            # The equivalent is to embed CEF in a QWindow (hidden_window) and
            # wrap it in a createWindowContainer widget.
            # noinspection PyUnresolvedReferences, PyArgumentList
            self.container = QWidget.createWindowContainer(
                    self.cef_widget.hidden_window, parent=self)
            # noinspection PyArgumentList
            layout.addWidget(self.container, 1, 0)
            # The container displaces cef_widget in the layout, so
            # cef_widget.resizeEvent never fires.  Drive SetBounds from the
            # container's resize events via this event filter.
            self.container.installEventFilter(self.cef_widget)

    def closeEvent(self, event):
        # Defer window destruction until the browser has fully closed.
        #
        # CloseBrowser() is asynchronous: CEF tears the browser down and then
        # fires OnBeforeClose.  If we let Qt destroy this window now, the X11
        # window that CEF is embedded into is destroyed out from under the
        # still-live browser, which on a real GPU crashes the GPU process
        # mid-eglSwapBuffers ("Failed to retrieve the size of the parent
        # window") and leaves CEF's observer list non-empty at shutdown
        # ("Check failed: observers_.empty()").  Instead ignore this close,
        # ask CEF to close the browser, and let CloseHandler.OnBeforeClose
        # re-trigger the close once the browser is gone.
        if self.cef_widget.browser and not self._closing:
            self._closing = True
            self.cef_widget.browser.CloseBrowser(True)
            event.ignore()
            return
        event.accept()

    def clear_browser_references(self):
        # Clear browser references that you keep anywhere in your
        # code. All references must be cleared for CEF to shutdown cleanly.
        self.cef_widget.browser = None


class CefWidget(QWidget):
    def __init__(self, parent=None):
        # noinspection PyArgumentList
        super(CefWidget, self).__init__(parent)
        self.parent = parent
        self.browser = None
        self.hidden_window = None  # Required for PyQt5 on Linux
        self.x = 0
        self.y = 0
        self.show()

    def eventFilter(self, obj, event):
        # Only installed on PyQt5/Linux where the container displaces cef_widget.
        if event.type() == QEvent.Resize and self.browser:
            size = event.size()
            self.browser.SetBounds(self.x, self.y, size.width(), size.height())
            self.browser.NotifyMoveOrResizeStarted()
        return False

    def focusInEvent(self, event):
        # This event seems to never get called on Linux, as CEF is
        # stealing all focus due to Issue #284.
        if cef.GetAppSetting("debug"):
            print("[qt.py] CefWidget.focusInEvent")
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSetFocus(self.getHandle(), 0, 0, 0)
            self.browser.SetFocus(True)

    def focusOutEvent(self, event):
        # This event seems to never get called on Linux, as CEF is
        # stealing all focus due to Issue #284.
        if cef.GetAppSetting("debug"):
            print("[qt.py] CefWidget.focusOutEvent")
        if self.browser:
            self.browser.SetFocus(False)

    def embedBrowser(self):
        if LINUX and PYQT5:
            # On Linux with PyQt5, QX11EmbedContainer is gone; the Qt-native
            # equivalent is to host CEF in a QWindow (hidden_window) wrapped in
            # a createWindowContainer widget (see setupLayout).  Qt reparents
            # the QWindow into the container itself.
            # noinspection PyUnresolvedReferences
            self.hidden_window = QWindow()
        # On all bindings CEF is parented directly into the native X11 window
        # via WindowInfo.SetAsChild(), exactly like upstream cefclient
        # (browser_window_std_gtk.cc).  The Qt widget forces a real X11 native
        # window (WA_PaintOnScreen / xcb backend); no deferred reparent needed.
        window_info = cef.WindowInfo()
        rect = [0, 0, self._phys(self.width()), self._phys(self.height())]
        window_info.SetAsChild(self.getHandle(), rect)
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        if self.browser:
            self.browser.SetClientHandler(LoadHandler(self.parent.navigation_bar))
            self.browser.SetClientHandler(FocusHandler(self))
            self.browser.SetClientHandler(CloseHandler(self.parent))
        if WINDOWS:
            # Sync browser size to actual HWND client rect using device pixels.
            # PyQt6 high-DPI scaling means self.width()/height() may be smaller
            # than the real client rect, leaving content in a smaller area.
            WindowUtils.OnSize(self.getHandle(), 0, 0, 0)

    def _phys(self, n):
        # Qt6 enables AA_EnableHighDpiScaling by default, so width()/height()
        # return logical pixels.  CEF expects physical pixels.  Multiply by
        # devicePixelRatio() for PyQt6/PySide6 on Linux; PyQt5 uses the
        # hidden_window/XReparentWindow path where X11 geometry drives sizing.
        if LINUX and (PYQT6 or PYSIDE6):
            return int(n * self.devicePixelRatio())
        return n

    def getHandle(self):
        if self.hidden_window:
            return int(self.hidden_window.winId())
        return int(self.winId())

    def moveEvent(self, _):
        self.x = 0
        self.y = 0
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.getHandle(), 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(self.x, self.y,
                                       self._phys(self.width()),
                                       self._phys(self.height()))
            self.browser.NotifyMoveOrResizeStarted()

    def resizeEvent(self, event):
        size = event.size()
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.getHandle(), 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(self.x, self.y,
                                       self._phys(size.width()),
                                       self._phys(size.height()))
            self.browser.NotifyMoveOrResizeStarted()


class CefApplication(QApplication):
    def __init__(self, args):
        super(CefApplication, self).__init__(args)
        if not cef.GetAppSetting("external_message_pump") or LINUX:
            self.timer = self.createTimer()
        self.setupIcon()

    def createTimer(self):
        timer = QTimer()
        # noinspection PyUnresolvedReferences
        timer.timeout.connect(self.onTimer)
        timer.start(10)
        return timer

    def onTimer(self):
        cef.MessageLoopWork()

    def stopTimer(self):
        # Stop the timer after Qt's message loop has ended
        self.timer.stop()

    def setupIcon(self):
        icon_file = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                 "resources", "{0}.png".format(sys.argv[1]))
        if os.path.exists(icon_file):
            self.setWindowIcon(QIcon(icon_file))


class CloseHandler(object):
    # LifeSpanHandler: completes the deferred close started in
    # MainWindow.closeEvent().  By the time OnBeforeClose fires the browser
    # has been fully torn down by CEF, so it is now safe to destroy the Qt
    # window (which owns the X11 window CEF was embedded into).
    def __init__(self, main_window):
        self.main_window = main_window

    def OnBeforeClose(self, browser, **_):
        self.main_window.clear_browser_references()
        # Re-trigger the close; closeEvent now accepts it (browser is None),
        # Qt destroys the window, and the app quits on last-window-closed.
        self.main_window.close()


class LoadHandler(object):
    def __init__(self, navigation_bar):
        self.initial_app_loading = True
        self.navigation_bar = navigation_bar

    def OnLoadingStateChange(self, **_):
        self.navigation_bar.updateState()

    def OnLoadStart(self, browser, **_):
        self.navigation_bar.url.setText(browser.GetUrl())
        if self.initial_app_loading:
            self.navigation_bar.cef_widget.setFocus()
            # Temporary fix no. 2 for focus issue on Linux (Issue #284)
            if LINUX:
                print("[qt.py] LoadHandler.OnLoadStart:"
                      " keyboard focus fix no. 2 (Issue #284)")
                browser.SetFocus(True)
            self.initial_app_loading = False


class FocusHandler(object):
    def __init__(self, cef_widget):
        self.cef_widget = cef_widget

    def OnTakeFocus(self, **_):
        if cef.GetAppSetting("debug"):
            print("[qt.py] FocusHandler.OnTakeFocus")

    def OnSetFocus(self, **_):
        if cef.GetAppSetting("debug"):
            print("[qt.py] FocusHandler.OnSetFocus")

    def OnGotFocus(self, browser, **_):
        if cef.GetAppSetting("debug"):
            print("[qt.py] FocusHandler.OnGotFocus")
        self.cef_widget.setFocus()
        # Focus fix for Linux (Issue #284): rely on the widget setFocus above;
        # do not call browser.SetFocus(True) here.


class NavigationBar(QFrame):
    def __init__(self, cef_widget):
        # noinspection PyArgumentList
        super(NavigationBar, self).__init__()
        self.cef_widget = cef_widget

        # Init layout
        layout = QGridLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Back button
        self.back = self.createButton("back")
        # noinspection PyUnresolvedReferences
        self.back.clicked.connect(self.onBack)
        # noinspection PyArgumentList
        layout.addWidget(self.back, 0, 0)

        # Forward button
        self.forward = self.createButton("forward")
        # noinspection PyUnresolvedReferences
        self.forward.clicked.connect(self.onForward)
        # noinspection PyArgumentList
        layout.addWidget(self.forward, 0, 1)

        # Reload button
        self.reload = self.createButton("reload")
        # noinspection PyUnresolvedReferences
        self.reload.clicked.connect(self.onReload)
        # noinspection PyArgumentList
        layout.addWidget(self.reload, 0, 2)

        # Url input
        self.url = QLineEdit("")
        # noinspection PyUnresolvedReferences
        self.url.returnPressed.connect(self.onGoUrl)
        # noinspection PyArgumentList
        layout.addWidget(self.url, 0, 3)

        # Layout
        self.setLayout(layout)
        self.updateState()

    def onBack(self):
        if self.cef_widget.browser:
            self.cef_widget.browser.GoBack()

    def onForward(self):
        if self.cef_widget.browser:
            self.cef_widget.browser.GoForward()

    def onReload(self):
        if self.cef_widget.browser:
            self.cef_widget.browser.Reload()

    def onGoUrl(self):
        if self.cef_widget.browser:
            self.cef_widget.browser.LoadUrl(self.url.text())

    def updateState(self):
        browser = self.cef_widget.browser
        if not browser:
            self.back.setEnabled(False)
            self.forward.setEnabled(False)
            self.reload.setEnabled(False)
            self.url.setEnabled(False)
            return
        self.back.setEnabled(browser.CanGoBack())
        self.forward.setEnabled(browser.CanGoForward())
        self.reload.setEnabled(True)
        self.url.setEnabled(True)
        self.url.setText(browser.GetUrl())

    def createButton(self, name):
        resources = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                 "resources")
        pixmap = QPixmap(os.path.join(resources, "{0}.png".format(name)))
        icon = QIcon(pixmap)
        button = QPushButton()
        button.setIcon(icon)
        button.setIconSize(pixmap.rect().size())
        return button

if __name__ == '__main__':
    main()
