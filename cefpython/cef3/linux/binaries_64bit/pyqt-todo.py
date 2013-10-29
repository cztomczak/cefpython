# This example is throwing segmentation faults when run on Linux,
# the problem seems to be in a call to CreateBrowserSync(),
# the backtrace leads to CefBrowserHostImpl::PlatformCreateWindow().
# Full backtrace:
"""
0x00007ffff1ee52a0 in CefBrowserHostImpl::PlatformCreateWindow() ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/libcef.so
(gdb) backtrace
#0  0x00007ffff1ee52a0 in CefBrowserHostImpl::PlatformCreateWindow() ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/libcef.so
#1  0x00007ffff1e24930 in CefBrowserHostImpl::Create(CefWindowInfo const&, CefStructBase<CefBrowserSettingsTraits> const&, CefRefPtr<CefClient>, content::WebContents*, scoped_refptr<CefBrowserInfo>, _GtkWidget*) ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/libcef.so
#2  0x00007ffff1e251ec in CefBrowserHost::CreateBrowserSync(CefWindowInfo const&, CefRefPtr<CefClient>, CefStringBase<CefStringTraitsUTF16> const&, CefStructBase<CefBrowserSettingsTraits> const&) ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/libcef.so
#3  0x00007ffff1dc9fec in cef_browser_host_create_browser_sync ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/libcef.so
#4  0x00007fffe8136e4f in CefBrowserHost::CreateBrowserSync(CefWindowInfo const&, CefRefPtr<CefClient>, CefStringBase<CefStringTraitsUTF16> const&, CefStructBase<CefBrowserSettingsTraits> const&) ()
   from /home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/cefpython_py27.so
#5  0x00007fffe8111cce in __pyx_pf_14cefpython_py27_16CreateBrowserSync (
    __pyx_v_windowInfo=<cefpython_py27.WindowInfo at remote 0xdc7fb0>, 
    __pyx_v_browserSettings=<optimized out>, __pyx_v_navigateUrl=
    'file:///home/czarek/cefpython/cefpython/cef3/linux/binaries_64bit/example.html', __pyx_self=<optimized out>) at cefpython.cpp:65142
#6  0x00007fffe8114ea6 in __pyx_pw_14cefpython_py27_17CreateBrowserSync (
"""

# An example of embedding CEF Python in PyQt4 application.

# On Ubuntu install the "python-qt4" package.
# Tested with version 4.9.1-2ubuntu1.

# Important: 
#   On Linux importing the cefpython module must be 
#   the very first in your application. This is because CEF makes 
#   a global tcmalloc hook for memory allocation/deallocation. 
#   See Issue 73 that is to provide CEF builds with tcmalloc disabled:
#   https://code.google.com/p/cefpython/issues/detail?id=73

import ctypes, os, sys
libcef_so = os.path.join(os.path.dirname(os.path.abspath(__file__)),\
        'libcef.so')
# Import a local module if exists, otherwise import from 
# an installed package.
if os.path.exists(libcef_so):
    ctypes.CDLL(libcef_so, ctypes.RTLD_GLOBAL)
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    from cefpython3 import cefpython

from PyQt4 import QtGui
from PyQt4 import QtCore

TEST_RESPONSE_READING = False

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
        print("cefpython: WARNING: failed writing to error file: %s" % (
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
        cefpython.WindowUtils.OnSetFocus(
                int(self.centralWidget().winId()), 0, 0, 0)

    def closeEvent(self, event):
        self.mainFrame.browser.CloseBrowser()

class MainFrame(QtGui.QWidget):
    browser = None

    def __init__(self, parent=None):
        super(MainFrame, self).__init__(parent)
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(int(self.winId()))
        # Linux requires adding "file://" for local files,
        # otherwise /home/some will be replaced as http://home/some
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings={},
                navigateUrl="file://"+GetApplicationPath("example.html"))
        self.show()

    def moveEvent(self, event):
        cefpython.WindowUtils.OnSize(int(self.winId()), 0, 0, 0)

    def resizeEvent(self, event):
        cefpython.WindowUtils.OnSize(int(self.winId()), 0, 0, 0)

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
    print("PyQt version: %s" % QtCore.PYQT_VERSION_STR)
    print("QtCore version: %s" % QtCore.qVersion())

    sys.excepthook = ExceptHook
    cefpython.g_debug = True
    cefpython.g_debugFile = GetApplicationPath("debug.log")

    settings = {}
    settings["log_file"] = GetApplicationPath("debug.log")
    settings["log_severity"] = cefpython.LOGSEVERITY_INFO
    settings["release_dcheck_enabled"] = True # Enable only when debugging
    settings["locales_dir_path"] = cefpython.GetModuleDirectory()+"/locales"
    settings["resources_dir_path"] = cefpython.GetModuleDirectory()
    settings["browser_subprocess_path"] = "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess")
    
    cefpython.Initialize(settings)

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
