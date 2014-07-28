# An example of embedding the CEF browser in a PyQt4 application.
# Tested with PyQt "4.9.1".
# Command for installing PyQt4: "sudo apt-get install python-qt4".

# The official CEF Python binaries come with tcmalloc hook
# disabled. But if you've built custom binaries and kept tcmalloc
# hook enabled, then be aware that in such case it is required
# for the cefpython module to be the very first import in
# python scripts. See Issue 73 in the CEF Python Issue Tracker
# for more details.

import ctypes, os, sys
libcef_so = os.path.join(os.path.dirname(os.path.abspath(__file__)),\
        'libcef.so')
if os.path.exists(libcef_so):
    # Import local module
    ctypes.CDLL(libcef_so, ctypes.RTLD_GLOBAL)
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import from package
    from cefpython3 import cefpython

from PyQt4 import QtGui
from PyQt4 import QtCore

def GetApplicationPath(file=None):
    import re, os, platform
    # If file is None return current directory without trailing slash.
    if file is None:
        file = ""
    # Only when relative path.
    if not file.startswith("/") and not file.startswith("\\") and (
            not re.search(r"^[\w-]+:", file)):
        if hasattr(sys, "frozen"):
            path = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            path = os.path.dirname(os.path.realpath(__file__))
        else:
            path = os.getcwd()
        path = path + os.sep + file
        if platform.system() == "Windows":
            path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(file)

def ExceptHook(excType, excValue, traceObject):
    import traceback, os, time, codecs
    # This hook does the following: in case of exception write it to
    # the "error.log" file, display it to the console, shutdown CEF
    # and exit application immediately by ignoring "finally" (os._exit()).
    errorMsg = "\n".join(traceback.format_exception(excType, excValue,
            traceObject))
    errorFile = GetApplicationPath("error.log")
    try:
        appEncoding = cefpython.g_applicationSettings["string_encoding"]
    except:
        appEncoding = "utf-8"
    if type(errorMsg) == bytes:
        errorMsg = errorMsg.decode(encoding=appEncoding, errors="replace")
    try:
        with codecs.open(errorFile, mode="a", encoding=appEncoding) as fp:
            fp.write("\n[%s] %s\n" % (
                    time.strftime("%Y-%m-%d %H:%M:%S"), errorMsg))
    except:
        print("[wxpython.py] WARNING: failed writing to error file: %s" % (
                errorFile))
    # Convert error message to ascii before printing, otherwise
    # you may get error like this:
    # | UnicodeEncodeError: 'charmap' codec can't encode characters
    errorMsg = errorMsg.encode("ascii", errors="replace")
    errorMsg = errorMsg.decode("ascii", errors="replace")
    print("\n"+errorMsg+"\n")
    cefpython.QuitMessageLoop()
    cefpython.Shutdown()
    os._exit(1)

class MainWindow(QtGui.QMainWindow):
    mainFrame = None

    def __init__(self):
        super(MainWindow, self).__init__(None)
        self.createMenu()
        self.mainFrame = MainFrame(self)
        self.setCentralWidget(self.mainFrame)
        self.resize(1024, 768)
        self.setWindowTitle('PyQT CEF 3 example')
        self.setFocusPolicy(QtCore.Qt.StrongFocus)

    def createMenu(self):
        menubar = self.menuBar()
        filemenu = menubar.addMenu("&File")
        filemenu.addAction(QtGui.QAction("Open", self))
        filemenu.addAction(QtGui.QAction("Exit", self))
        aboutmenu = menubar.addMenu("&About")

    def focusInEvent(self, event):
        # cefpython.WindowUtils.OnSetFocus(
        #        int(self.centralWidget().winId()), 0, 0, 0)
        pass

    def closeEvent(self, event):
        self.mainFrame.browser.CloseBrowser()

class MainFrame(QtGui.QX11EmbedContainer):
    browser = None
    plug = None

    def __init__(self, parent=None):
        super(MainFrame, self).__init__(parent)
        
        # QX11EmbedContainer provides an X11 window. The CEF
        # browser can be embedded only by providing a GtkWidget
        # pointer. So we're embedding a GtkPlug inside the X11
        # window. In latest CEF trunk it is possible to embed
        # the CEF browser by providing X11 window id. So it will
        # be possible to remove the GTK dependency from CEF
        # Python in the future.
        gtkPlugPtr = cefpython.WindowUtils.gtk_plug_new(\
                int(self.winId()))
        print("[pyqt.py] MainFrame: GDK Native Window id: "+str(self.winId()))
        print("[pyqt.py] MainFrame: GTK Plug ptr: "+str(gtkPlugPtr))

        """
        Embedding GtkPlug is also possible with the pygtk module.
        ---------------------------------------------------------
        self.plug = gtk.Plug(self.winId())
        import re
        m = re.search("GtkPlug at 0x(\w+)", str(self.plug))
        hexId = m.group(1)
        gtkPlugPtr = int(hexId, 16)
        ...
        plug.show()
        self.show()
        ---------------------------------------------------------
        """

        windowInfo = cefpython.WindowInfo()
        # Need to pass to CEF the GtkWidget* pointer
        windowInfo.SetAsChild(gtkPlugPtr)
        # Linux requires adding "file://" for local files,
        # otherwise /home/some will be replaced as http://home/some
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings={},
                navigateUrl="file://"+GetApplicationPath("example.html"))
        
        cefpython.WindowUtils.gtk_widget_show(gtkPlugPtr)
        self.show()

    def moveEvent(self, event):
        # cefpython.WindowUtils.OnSize(int(self.winId()), 0, 0, 0)
        pass

    def resizeEvent(self, event):
        # cefpython.WindowUtils.OnSize(int(self.winId()), 0, 0, 0)
        pass

class CefApplication(QtGui.QApplication):
    timer = None

    def __init__(self, args):
        super(CefApplication, self).__init__(args)
        self.createTimer()

    def createTimer(self):
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.onTimer)
        self.timer.start(10)

    def onTimer(self):
        # The proper way of doing message loop should be:
        # 1. In createTimer() call self.timer.start(0)
        # 2. In onTimer() call MessageLoopWork() only when
        #    QtGui.QApplication.instance()->hasPendingEvents()
        #    returns False.
        # But there is a bug in Qt, hasPendingEvents() returns
        # always true.
        # (The behavior described above was tested on Windows
        #  with pyqt 4.8, maybe this is not true anymore,
        #  test it TODO)
        cefpython.MessageLoopWork()

    def stopTimer(self):
        # Stop the timer after Qt message loop ended, calls to
        # MessageLoopWork() should not happen anymore.
        self.timer.stop()

if __name__ == '__main__':
    print("[pyqt.py] PyQt version: %s" % QtCore.PYQT_VERSION_STR)
    print("[pyqt.py] QtCore version: %s" % QtCore.qVersion())

    # Intercept python exceptions. Exit app immediately when exception
    # happens on any of the threads.
    sys.excepthook = ExceptHook

    # Application settings
    settings = {
        "debug": True, # cefpython debug messages in console and in log_file
        "log_severity": cefpython.LOGSEVERITY_INFO, # LOGSEVERITY_VERBOSE
        "log_file": GetApplicationPath("debug.log"), # Set to "" to disable.
        "release_dcheck_enabled": True, # Enable only when debugging.
        # This directories must be set on Linux
        "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
        "resources_dir_path": cefpython.GetModuleDirectory(),
        "browser_subprocess_path": "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess"),
        # This option is required for the GetCookieManager callback
        # to work. It affects renderer processes, when this option
        # is set to True. It will force a separate renderer process
        # for each browser created using CreateBrowserSync.
        "unique_request_context_per_browser": True
    }

    # Command line switches set programmatically
    switches = {
        # "proxy-server": "socks5://127.0.0.1:8888",
        # "enable-media-stream": "",
        # "--invalid-switch": "" -> Invalid switch name
    }

    cefpython.Initialize(settings, switches)

    app = CefApplication(sys.argv)
    mainWindow = MainWindow()
    mainWindow.show()
    app.exec_()
    app.stopTimer()

    # Need to destroy QApplication(), otherwise Shutdown() fails.
    # Unset main window also just to be safe.
    del mainWindow
    del app

    cefpython.Shutdown()
