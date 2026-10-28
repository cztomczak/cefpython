# Example of embedding CEF browser using PyQt6 and PySide6 libraries.
# This example has two widgets: a navigation bar and a browser.
#
# Tested configurations:
# - PyQt6 on Windows/Linux
# - PySide6 on Windows/Linux
# - CEF Python v55.4+

from cefpython3 import cefpython as cef
import os
import platform
import sys

# Selected Qt6 binding.  The embedding code below is shared by both bindings.
QT_BINDING = None
QT_BINDING_VERSION = None

if "pyqt6" in sys.argv:
    QT_BINDING = "PyQt6"
    # noinspection PyUnresolvedReferences
    from PyQt6.QtGui import *
    # noinspection PyUnresolvedReferences
    from PyQt6.QtCore import *
    # noinspection PyUnresolvedReferences
    from PyQt6.QtWidgets import *
    QT_BINDING_VERSION = PYQT_VERSION_STR
elif "pyside6" in sys.argv:
    QT_BINDING = "PySide6"
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
    QT_BINDING_VERSION = PySide6.__version__
else:
    print("USAGE:")
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
    main_window.cef_widget.embedBrowser()
    app.exec()
    if not cef.GetAppSetting("external_message_pump"):
        app.stopTimer()
    del main_window  # Just to be safe, similarly to "del app"
    del app  # Must destroy app object before calling Shutdown
    cef.Shutdown()


def check_versions():
    print("[qt.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[qt.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[qt.py] {binding} {version} (qt {qt_version})".format(
          binding=QT_BINDING, version=QT_BINDING_VERSION,
          qt_version=qVersion()))
    # CEF Python version requirement
    assert int(cef.__version__.split(".")[0]) >= 55, "CEF Python v55.4+ required to run this"


def round_half_up(value):
    # Qt rounds halves up when it sizes a native window, e.g. 862.5 -> 863.
    # Python's round() rounds halves to even (862.5 -> 862), so it can't be
    # used to match the window size.
    return int(value + 0.5)


class MainWindow(QMainWindow):
    def __init__(self):
        # noinspection PyArgumentList
        super(MainWindow, self).__init__(None)
        self.cef_widget = None
        self.navigation_bar = None
        # _closing: CloseBrowser() was requested.
        # _do_close_called: CEF called DoClose(), so the browser is
        # committed to closing (see closeEvent / CloseHandler).
        self._closing = False
        self._do_close_called = False
        self.setWindowTitle("{0} example".format(QT_BINDING))
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
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

    def closeEvent(self, event):
        # Don't destroy the window while the browser is still open.
        # CloseBrowser() is asynchronous. CEF calls DoClose() and, if it
        # returns False, sends a close event to this window. Only that
        # event (or the one from OnBeforeClose) may be accepted. Close
        # requests before that, e.g. a double click on the close button,
        # are ignored.
        if self.cef_widget.browser and not self._do_close_called:
            if not self._closing:
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
        self.show()

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
        # Call this after the main window was shown, when the layout has
        # sized this widget and its native window. Embedding earlier leaves
        # the browser at its initial size on Windows (Issue #718).
        # CEF is parented directly into the native Qt widget window via
        # WindowInfo.SetAsChild().
        width, height = self.browserSize()
        window_info = cef.WindowInfo()
        window_info.SetAsChild(self.getHandle(), [0, 0, width, height])
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        if self.browser:
            self.browser.SetClientHandler(LoadHandler(self.parent.navigation_bar))
            self.browser.SetClientHandler(FocusHandler(self))
            self.browser.SetClientHandler(CloseHandler(self.parent))

    def browserSize(self):
        # Size of this widget in the units CEF expects for the browser:
        # points on Mac, physical pixels on Windows and Linux.
        if MAC:
            return self.width(), self.height()
        ratio = self.devicePixelRatio()
        return (round_half_up(self.width() * ratio),
                round_half_up(self.height() * ratio))

    def getHandle(self):
        return int(self.winId())

    def moveEvent(self, _):
        self.updateBrowserSize()

    def resizeEvent(self, _):
        self.updateBrowserSize()

    def updateBrowserSize(self):
        # Make the browser fill the native window of this widget
        if not self.browser:
            return
        if WINDOWS:
            # SetBounds() is Linux only. OnSize() resizes the browser to
            # the client area of the native window.
            WindowUtils.OnSize(self.getHandle(), 0, 0, 0)
        elif LINUX:
            width, height = self.browserSize()
            self.browser.SetBounds(0, 0, width, height)
        self.browser.NotifyMoveOrResizeStarted()


class CefApplication(QApplication):
    def __init__(self, args):
        super(CefApplication, self).__init__(args)
        if not cef.GetAppSetting("external_message_pump"):
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
                                 "resources", "qt.png")
        if os.path.exists(icon_file):
            self.setWindowIcon(QIcon(icon_file))


class CloseHandler(object):
    # LifespanHandler: completes the deferred close started in
    # MainWindow.closeEvent().
    def __init__(self, main_window):
        self.main_window = main_window

    def DoClose(self, browser, **_):
        # Returning False makes CEF send a close event to the parent window,
        # which closeEvent() now accepts.
        self.main_window._do_close_called = True
        return False

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
