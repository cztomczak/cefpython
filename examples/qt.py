# Example of embedding CEF browser using PyQt4, PyQt5 and
# PySide libraries. This example has two widgets: a navigation
# bar and a browser.
#
# Tested configurations:
# - PyQt 5.8.2 on Linux
# - PyQt 4.11 (qt 4.8) on Windows/Linux
# - PySide 1.2 (qt 4.8) on Windows/Linux/Mac
# - CEF Python v55.4+
#
# Issues with PySide 1.2 on Mac:
# - Keyboard focus issues when switching between controls (Issue #284)
# - Mouse cursor never changes when hovering over links (Issue #311)
# - Sometimes process hangs when quitting app

from cefpython3 import cefpython as cef
import ctypes
import os
import platform
import sys

# GLOBALS
PYQT4 = False
PYQT5 = False
PYSIDE = False

# PyQt imports
if "pyqt4" in sys.argv:
    PYQT4 = True
    from PyQt4.QtGui import *
    from PyQt4.QtCore import *
elif "pyqt5" in sys.argv:
    PYQT5 = True
    from PyQt5.QtGui import *
    from PyQt5.QtCore import *
    from PyQt5.QtWidgets import *
# PySide imports
elif "pyside" in sys.argv:
    PYSIDE = True
    import PySide
    from PySide import QtCore
    from PySide.QtGui import *
    from PySide.QtCore import *
else:
    print("USAGE:")
    print("  qt.py pyqt4")
    print("  qt.py pyqt5")
    print("  qt.py pyside")
    sys.exit(1)

# Fix for PyCharm hints warnings when using static methods
WindowUtils = cef.WindowUtils()

# Platforms
WINDOWS = (platform.system() == "Windows")
LINUX = (platform.system() == "Linux")
MAC = (platform.system() == "Darwin")

# Configuration
WIDTH = 800
HEIGHT = 600

# OS differences
CefWidgetParent = QWidget
if LINUX and (PYQT4 or PYSIDE):
    CefWidgetParent = QX11EmbedContainer


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    app = CefApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    main_window.activateWindow()
    main_window.raise_()
    app.exec_()
    app.stopTimer()
    del main_window  # Just to be safe, similarly to "del app"
    del app  # Must destroy app object before calling Shutdown
    cef.Shutdown()


def check_versions():
    print("[qt.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[qt.py] Python {ver} {arch}".format(
            ver=platform.python_version(), arch=platform.architecture()[0]))
    if PYQT4 or PYQT5:
        print("[qt.py] PyQt {v1} (qt {v2})".format(
              v1=PYQT_VERSION_STR, v2=qVersion()))
    elif PYSIDE:
        print("[qt.py] PySide {v1} (qt {v2})".format(
              v1=PySide.__version__, v2=QtCore.__version__))
    # CEF Python version requirement
    assert cef.__version__ >= "55.4", "CEF Python v55.4+ required to run this"


class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__(None)
        self.cef_widget = None
        self.navigation_bar = None
        if PYQT4:
            self.setWindowTitle("PyQt4 example")
        elif PYQT5:
            self.setWindowTitle("PyQt5 example")
        elif PYSIDE:
            self.setWindowTitle("PySide example")
        self.setFocusPolicy(Qt.StrongFocus)
        self.setupLayout()

    def setupLayout(self):
        self.resize(WIDTH, HEIGHT)
        self.cef_widget = CefWidget(self)
        self.navigation_bar = NavigationBar(self.cef_widget)
        layout = QGridLayout()
        layout.addWidget(self.navigation_bar, 0, 0)
        layout.addWidget(self.cef_widget, 1, 0)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        layout.setRowStretch(0, 0)
        layout.setRowStretch(1, 1)
        frame = QFrame()
        frame.setLayout(layout)
        self.setCentralWidget(frame)
        # Browser can be embedded only after layout was set up
        self.cef_widget.embedBrowser()
        if LINUX and PYQT5:
            self.container = QWidget.createWindowContainer(
                    self.cef_widget.hidden_window, parent=self)
            layout.addWidget(self.container, 1, 0)

    def closeEvent(self, event):
        # Close browser (force=True) and free CEF reference
        if self.cef_widget.browser:
            self.cef_widget.browser.CloseBrowser(True)
            self.clear_browser_references()

    def clear_browser_references(self):
        # Clear browser references that you keep anywhere in your
        # code. All references must be cleared for CEF to shutdown cleanly.
        self.cef_widget.browser = None


class CefWidget(CefWidgetParent):
    def __init__(self, parent=None):
        super(CefWidget, self).__init__(parent)
        self.parent = parent
        self.browser = None
        self.hidden_window = None  # Required for PyQt5 on Linux
        self.show()

    def focusInEvent(self, event):
        # This event seems to never get called on Linux, as CEF is
        # stealing all focus due to Issue #284.
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSetFocus(self.getHandle(), 0, 0, 0)
            self.browser.SetFocus(True)

    def focusOutEvent(self, event):
        # This event seems to never get called on Linux, as CEF is
        # stealing all focus due to Issue #284.
        if self.browser:
            self.browser.SetFocus(False)

    def embedBrowser(self):
        if LINUX and PYQT5:
            self.hidden_window = QWindow()
        window_info = cef.WindowInfo()
        rect = [0, 0, self.width(), self.height()]
        window_info.SetAsChild(self.getHandle(), rect)
        self.browser = cef.CreateBrowserSync(window_info,
                                             url="https://www.google.com/")
        self.browser.SetClientHandler(LoadHandler(self.parent.navigation_bar))
        self.browser.SetClientHandler(FocusHandler(self))

    def getHandle(self):
        # PyQt5 on Linux
        if self.hidden_window:
            return int(self.hidden_window.winId())
        try:
            # PyQt4 and PyQt5
            return int(self.winId())
        except:
            # PySide:
            # | QWidget.winId() returns <PyCObject object at 0x02FD8788>
            # | Converting it to int using ctypes.
            if sys.version_info[0] == 2:
                # Python 2
                ctypes.pythonapi.PyCObject_AsVoidPtr.restype = (
                        ctypes.c_void_p)
                ctypes.pythonapi.PyCObject_AsVoidPtr.argtypes = (
                        [ctypes.py_object])
                return ctypes.pythonapi.PyCObject_AsVoidPtr(self.winId())
            else:
                # Python 3
                ctypes.pythonapi.PyCapsule_GetPointer.restype = (
                        ctypes.c_void_p)
                ctypes.pythonapi.PyCapsule_GetPointer.argtypes = (
                        [ctypes.py_object])
                return ctypes.pythonapi.PyCapsule_GetPointer(
                        self.winId(), None)

    def moveEvent(self, _):
        self.x = 0
        self.y = 0
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.getHandle(), 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(self.x, self.y,
                                       self.width(), self.height())
            self.browser.NotifyMoveOrResizeStarted()

    def resizeEvent(self, event):
        size = event.size()
        if self.browser:
            if WINDOWS:
                WindowUtils.OnSize(self.getHandle(), 0, 0, 0)
            elif LINUX:
                self.browser.SetBounds(self.x, self.y,
                                       size.width(), size.height())
            self.browser.NotifyMoveOrResizeStarted()


class CefApplication(QApplication):
    def __init__(self, args):
        super(CefApplication, self).__init__(args)
        self.timer = self.createTimer()
        self.setupIcon()

    def createTimer(self):
        timer = QTimer()
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

    def OnSetFocus(self, **_):
        pass

    def OnGotFocus(self, browser, **_):
        # Temporary fix no. 1 for focus issues on Linux (Issue #284)
        if LINUX:
            print("[qt.py] FocusHandler.OnGotFocus:"
                  " keyboard focus fix no. 1 (Issue #284)")
            browser.SetFocus(True)


class NavigationBar(QFrame):
    def __init__(self, cef_widget):
        super(NavigationBar, self).__init__()
        self.cef_widget = cef_widget

        # Init layout
        layout = QGridLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Back button
        self.back = self.createButton("back")
        self.back.clicked.connect(self.onBack)
        layout.addWidget(self.back, 0, 0)

        # Forward button
        self.forward = self.createButton("forward")
        self.forward.clicked.connect(self.onForward)
        layout.addWidget(self.forward, 0, 1)

        # Reload button
        self.reload = self.createButton("reload")
        self.reload.clicked.connect(self.onReload)
        layout.addWidget(self.reload, 0, 2)

        # Url input
        self.url = QLineEdit("")
        self.url.returnPressed.connect(self.onGoUrl)
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
