# An example of embedding CEF browser in PyGTK on Windows.
# Tested with PyGTK 2.24.10

import os, sys
libcef_dll = os.path.join(os.path.dirname(os.path.abspath(__file__)),
        'libcef.dll')
if os.path.exists(libcef_dll):
    # Import a local module
    if (2,7) <= sys.version_info < (2,8):
        import cefpython_py27 as cefpython
    elif (3,4) <= sys.version_info < (3,4):
        import cefpython_py34 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import an installed package
    from cefpython3 import cefpython

import pygtk
pygtk.require('2.0')
import gtk
import gobject

def GetApplicationPath(file=None):
    import re, os, platform
    # On Windows after downloading file and calling Browser.GoForward(),
    # current working directory is set to %UserProfile%.
    # Calling os.path.dirname(os.path.realpath(__file__))
    # returns for eg. "C:\Users\user\Downloads". A solution
    # is to cache path on first call.
    if not hasattr(GetApplicationPath, "dir"):
        if hasattr(sys, "frozen"):
            dir = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            dir = os.path.dirname(os.path.realpath(__file__))
        else:
            dir = os.getcwd()
        GetApplicationPath.dir = dir
    # If file is None return current directory without trailing slash.
    if file is None:
        file = ""
    # Only when relative path.
    if not file.startswith("/") and not file.startswith("\\") and (
            not re.search(r"^[\w-]+:", file)):
        path = GetApplicationPath.dir + os.sep + file
        if platform.system() == "Windows":
            path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(file)

def ExceptHook(excType, excValue, traceObject):
    import traceback, os, time, codecs
    # This hook does the following: in case of exception write it to
    # the "error.log" file, display it to the console, shutdown CEF
    # and exit application immediately by ignoring "finally" (_exit()).
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
        print("[pygtk_.py]: WARNING: failed writing to error file: %s" % (
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

class PyGTKExample:
    mainWindow = None
    container = None
    browser = None
    exiting = None
    searchEntry = None

    def __init__(self):
        gobject.timeout_add(10, self.OnTimer)

        self.mainWindow = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.mainWindow.connect('destroy', self.OnExit)
        self.mainWindow.set_size_request(width=1024, height=768)
        self.mainWindow.set_title('PyGTK CEF 3 example')
        self.mainWindow.realize()

        self.container = gtk.DrawingArea()
        self.container.set_property('can-focus', True)
        self.container.connect('size-allocate', self.OnSize)
        self.container.show()

        self.searchEntry = gtk.Entry()
        # By default, clicking a GTK widget doesn't grab the focus away from a native Win32 control (browser).
        self.searchEntry.connect('button-press-event', self.OnWidgetClick)
        self.searchEntry.show()

        table = gtk.Table(3, 1, homogeneous=False)
        self.mainWindow.add(table)
        table.attach(self.CreateMenu(), 0, 1, 0, 1, yoptions=gtk.SHRINK)
        table.attach(self.searchEntry, 0, 1, 1, 2, yoptions=gtk.SHRINK)
        table.attach(self.container, 0, 1, 2, 3)
        table.show()

        windowID = self.container.get_window().handle
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(windowID)
        self.browser = cefpython.CreateBrowserSync(windowInfo,
                browserSettings={},
                navigateUrl=GetApplicationPath('example.html'))

        self.mainWindow.show()

        # Browser took focus, we need to get it back and give to searchEntry.
        self.mainWindow.get_window().focus()
        self.searchEntry.grab_focus()

    def CreateMenu(self):
        file = gtk.MenuItem('File')
        file.show()
        filemenu = gtk.Menu()
        item = gtk.MenuItem('Open')
        filemenu.append(item)
        item.show()
        item = gtk.MenuItem('Exit')
        filemenu.append(item)
        item.show()
        file.set_submenu(filemenu)
        about = gtk.MenuItem('About')
        about.show()
        menubar = gtk.MenuBar()
        menubar.append(file)
        menubar.append(about)
        menubar.show()
        return menubar

    def OnWidgetClick(self, widget, data):
        self.mainWindow.get_window().focus()

    def OnTimer(self):
        if self.exiting:
            return False
        cefpython.MessageLoopWork()
        return True

    def OnFocusIn(self, widget, data):
        # This function is currently not called by any of code, but if you would like
        # for browser to have automatic focus add such line:
        # self.mainWindow.connect('focus-in-event', self.OnFocusIn)
        cefpython.WindowUtils.OnSetFocus(self.container.get_window().handle, 0, 0, 0)

    def OnSize(self, widget, sizeAlloc):
        cefpython.WindowUtils.OnSize(self.container.get_window().handle, 0, 0, 0)

    def OnExit(self, widget, data=None):
        self.exiting = True
        gtk.main_quit()

if __name__ == '__main__':
    version = '.'.join(map(str, list(gtk.gtk_version)))
    print('[pygtk_.py] GTK version: %s' % version)

    # Intercept python exceptions. Exit app immediately when exception
    # happens on any of the threads.
    sys.excepthook = ExceptHook

    # Application settings
    settings = {
        "debug": True, # cefpython debug messages in console and in log_file
        "log_severity": cefpython.LOGSEVERITY_INFO, # LOGSEVERITY_VERBOSE
        "log_file": GetApplicationPath("debug.log"), # Set to "" to disable
        "release_dcheck_enabled": True, # Enable only when debugging
        # This directories must be set on Linux
        "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
        "resources_dir_path": cefpython.GetModuleDirectory(),
        "browser_subprocess_path": "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess"),
    }

    cefpython.Initialize(settings)

    gobject.threads_init() # Timer for the message loop
    PyGTKExample()
    gtk.main()

    cefpython.Shutdown()
