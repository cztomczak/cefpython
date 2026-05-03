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
import subprocess
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

# On Linux, query the X11 pointer button mask directly to detect outside-clicks
# on the context menu.  XQueryPointer returns real button state even while CEF
# holds an X11 grab (grabs only affect event *delivery*, not state queries).
if LINUX:
    try:
        from Xlib import display as _xlib_display_mod
        _XLIB_DPY = _xlib_display_mod.Display()
        def _x11_button_state():
            try:
                r = _XLIB_DPY.screen().root.query_pointer()
                return r.mask & 0x1F00  # Button1Mask(256)..Button5Mask(4096)
            except Exception:
                return 0
    except ImportError:
        _XLIB_DPY = None
        def _x11_button_state():
            return int(QApplication.mouseButtons())

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
        # Dismiss any open context menu before CloseBrowser so the callback
        # is released before CEF destroys the browser's menu-manager state.
        if LINUX and ContextMenuHandler._active_menu is not None:
            ContextMenuHandler._active_menu.hide()
        # Close browser (force=True) and free CEF reference
        if self.cef_widget.browser:
            self.cef_widget.browser.CloseBrowser(True)
            self.clear_browser_references()

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
            # PyQt5 uses GDK/Xlib while CEF uses XCB.  Creating an XCB child
            # under a GDK/Xlib window triggers a cross-client MatchError on
            # Xwayland.  The workaround is to create CEF under root first and
            # then reparent into hidden_window via a GLib timer
            # (_linux_schedule_xembed / _linux_embed_info mechanism).
            # noinspection PyUnresolvedReferences
            self.hidden_window = QWindow()
        # For PyQt6/PySide6 on Linux, cef_widget already has WA_PaintOnScreen
        # which forces a real X11 native window.  CEF can be created directly
        # as a child of cef_widget.winId() — no hidden_window or deferred
        # reparent needed.
        window_info = cef.WindowInfo()
        rect = [0, 0, self._phys(self.width()), self._phys(self.height())]
        window_info.SetAsChild(self.getHandle(), rect)
        if (PYQT6 or PYSIDE6) and LINUX:
            # SetAsChild() substituted root as CEF's parent (Xwayland workaround).
            # Qt6 uses XCB (same as CEF) so a direct parent/child relationship
            # works.  Restore cef_widget as the parent and disable the GLib-timer
            # reparent by clearing _linux_embed_info.
            window_info.parentWindowHandle = self.getHandle()
            window_info._linux_embed_info = None
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        if self.browser:
            self.browser.SetClientHandler(LoadHandler(self.parent.navigation_bar))
            self.browser.SetClientHandler(FocusHandler(self))
            if LINUX:
                self.browser.SetClientHandler(ContextMenuHandler(self))
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


class LoadHandler(object):
    def __init__(self, navigation_bar):
        self.initial_app_loading = True
        self.navigation_bar = navigation_bar

    def OnLoadingStateChange(self, **_):
        self.navigation_bar.updateState()

    def OnLoadStart(self, browser, **_):
        self.navigation_bar.url.setText(browser.GetUrl())
        # Dismiss any open context menu before CEF tears down its menu state
        # during navigation — holding the callback alive past this point
        # triggers an observers_.empty() assertion in base/observer_list.h.
        if LINUX and ContextMenuHandler._active_menu is not None:
            ContextMenuHandler._active_menu.hide()
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
        # Temporary fix no. 1 for focus issues on Linux (Issue #284).
        # Do NOT call browser.SetFocus(True) here on Linux: it calls
        # XSetInputFocus which steals keyboard focus from any context-menu
        # popup that is currently shown, causing the menu to close instantly.
        if LINUX:
            if ContextMenuHandler._active_menu is not None:
                # Fast path: button still down when OnGotFocus fires.
                if _x11_button_state():
                    menu = ContextMenuHandler._active_menu
                    if not menu.geometry().contains(QCursor.pos()):
                        menu.hide()
                        return
                # Start (or restart) the poll.  Covers:
                # - hover via focus-follows-mouse (button not pressed yet)
                # - fast click where button was released before OnGotFocus fired
                ContextMenuHandler._start_focus_poll()


class ContextMenuHandler(object):
    """Show a Qt context menu instead of CEF's native Aura/Ozone menu.

    CEF's native context menu on Linux/Xwayland fails to display correctly
    when the browser window has been reparented (embedded). Qt's own QMenu
    always appears at the right position because it uses QCursor.pos().

    In CEF Chrome style (116+), CefRunContextMenuCallback::Continue() does
    not execute commands — it silently does nothing.  All commands must be
    dispatched directly through Python browser APIs.
    """
    SEPARATOR = None
    _active_menu = None
    _focus_poll = None  # QTimer: polls for button press after hover-outside

    # CEF standard menu command IDs (cef_types.h cef_menu_id_t)
    _CMD_BACK            = 100
    _CMD_FORWARD         = 101
    _CMD_RELOAD          = 102
    _CMD_RELOAD_NOCACHE  = 103
    _CMD_STOPLOAD        = 104
    _CMD_PRINT           = 131
    _CMD_VIEW_SOURCE     = 132
    # Custom IDs added by context_menu_handler.cpp (MENU_ID_USER_FIRST = 26500)
    _CMD_DEVTOOLS        = 26501
    _CMD_RELOAD_PAGE     = 26502
    _CMD_OPEN_EXTERNAL   = 26503
    _CMD_OPEN_FRAME      = 26504

    def __init__(self, cef_widget=None):
        self._cef_widget = cef_widget

    @staticmethod
    def _stop_focus_poll():
        if ContextMenuHandler._focus_poll is not None:
            ContextMenuHandler._focus_poll.stop()
            ContextMenuHandler._focus_poll = None

    @staticmethod
    def _start_focus_poll():
        """Start a 5ms poll that hides the menu on an outside click."""
        ContextMenuHandler._stop_focus_poll()
        timer = QTimer()
        def _check():
            if ContextMenuHandler._active_menu is None:
                ContextMenuHandler._stop_focus_poll()
                return
            if _x11_button_state():
                menu = ContextMenuHandler._active_menu
                # Only dismiss if cursor is outside the menu.  A button press
                # inside the menu means the user selected an item — exec_()
                # handles that; don't interfere.
                if not menu.geometry().contains(QCursor.pos()):
                    menu.hide()
                # Stop poll either way once a button press is detected.
                ContextMenuHandler._stop_focus_poll()
        timer.timeout.connect(_check)
        timer.start(5)
        ContextMenuHandler._focus_poll = timer

    @staticmethod
    def _exec_cmd(browser, cmd_id, page_url):
        if cmd_id == ContextMenuHandler._CMD_BACK:
            browser.GoBack()
        elif cmd_id == ContextMenuHandler._CMD_FORWARD:
            browser.GoForward()
        elif cmd_id in (ContextMenuHandler._CMD_RELOAD,
                        ContextMenuHandler._CMD_RELOAD_NOCACHE,
                        ContextMenuHandler._CMD_RELOAD_PAGE):
            browser.ReloadIgnoreCache()
        elif cmd_id == ContextMenuHandler._CMD_STOPLOAD:
            browser.StopLoad()
        elif cmd_id == ContextMenuHandler._CMD_PRINT:
            browser.Print()
        elif cmd_id == ContextMenuHandler._CMD_VIEW_SOURCE:
            browser.LoadUrl("view-source:" + page_url)
        elif cmd_id == ContextMenuHandler._CMD_DEVTOOLS:
            browser.ShowDevTools()
        elif cmd_id in (ContextMenuHandler._CMD_OPEN_EXTERNAL,
                        ContextMenuHandler._CMD_OPEN_FRAME):
            if page_url:
                subprocess.Popen(["xdg-open", page_url])
        # Editing and spellcheck commands (cut/copy/paste/select-all/…)
        # are not yet handled — they silently do nothing.

    def RunContextMenu(self, browser, model, callback, **_):
        if ContextMenuHandler.SEPARATOR is None:
            ContextMenuHandler.SEPARATOR = cef.MENUITEMTYPE_SEPARATOR
        sep_type = ContextMenuHandler.SEPARATOR

        page_url = browser.GetUrl()
        cef_widget = self._cef_widget

        # Snapshot the model (valid only during this call).
        items = []
        for i in range(model.GetCount()):
            if model.GetTypeAt(i) == sep_type:
                items.append(None)
            else:
                items.append((model.GetLabelAt(i).replace("&", ""),
                               model.GetCommandIdAt(i),
                               model.IsEnabledAt(i)))

        def show_menu():
            # If a previous menu is still open (user right-clicked twice quickly
            # before the first was dismissed), hide it now.  Without this the
            # second exec_() runs inside the first's event loop and both menus
            # appear on screen simultaneously.
            if ContextMenuHandler._active_menu is not None:
                ContextMenuHandler._active_menu.hide()
                ContextMenuHandler._stop_focus_poll()

            # Cancel CEF's native context menu before displaying ours.
            callback.Cancel()

            menu = QMenu()
            text_to_cmd = {}
            for item in items:
                if item is None:
                    menu.addSeparator()
                else:
                    label, cmd_id, enabled = item
                    act = menu.addAction(label)
                    act.setEnabled(enabled)
                    text_to_cmd[label] = cmd_id

            ContextMenuHandler._active_menu = menu
            # Stop the focus-poll whenever the menu hides for any reason
            # (item click, outside-click via poll, navigation, window close).
            menu.aboutToHide.connect(ContextMenuHandler._stop_focus_poll)
            # exec_() runs a nested event loop; CEF's 10ms timer keeps firing.
            if PYQT6 or PYSIDE6:
                act = menu.exec(QCursor.pos())
            else:
                act = menu.exec_(QCursor.pos())
            ContextMenuHandler._active_menu = None
            ContextMenuHandler._stop_focus_poll()

            if act is not None:
                cmd_id = text_to_cmd.get(act.text())
                if cmd_id is not None:
                    b = cef_widget.browser if cef_widget else None
                    if b:
                        ContextMenuHandler._exec_cmd(b, cmd_id, page_url)

        # Defer the QMenu to the next event-loop tick so that this call
        # returns to CEF before any Qt event-loop work runs.
        QTimer.singleShot(0, show_menu)
        return True


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
