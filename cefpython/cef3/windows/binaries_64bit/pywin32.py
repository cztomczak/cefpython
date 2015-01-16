# Example of embedding CEF browser using the PyWin32 extension.
# Tested with pywin32 version 218.

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

import cefwindow
import win32con
import win32gui
import win32api
import time

DEBUG = True

# -----------------------------------------------------------------------------
# Helper functions.

def Log(msg):
    print("[pywin32.py] %s" % str(msg))

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
        print("[pywin32.py] WARNING: failed writing to error file: %s" % (
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

# -----------------------------------------------------------------------------

def CefAdvanced():
    sys.excepthook = ExceptHook

    appSettings = dict()
    # appSettings["cache_path"] = "webcache/" # Disk cache
    if DEBUG:
        # cefpython debug messages in console and in log_file
        appSettings["debug"] = True
        cefwindow.g_debug = True
    appSettings["log_file"] = GetApplicationPath("debug.log")
    appSettings["log_severity"] = cefpython.LOGSEVERITY_INFO
    appSettings["release_dcheck_enabled"] = True # Enable only when debugging
    appSettings["browser_subprocess_path"] = "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess")
    cefpython.Initialize(appSettings)

    wndproc = {
        win32con.WM_CLOSE: CloseWindow,
        win32con.WM_DESTROY: QuitApplication,
        win32con.WM_SIZE: cefpython.WindowUtils.OnSize,
        win32con.WM_SETFOCUS: cefpython.WindowUtils.OnSetFocus,
        win32con.WM_ERASEBKGND: cefpython.WindowUtils.OnEraseBackground
    }

    browserSettings = dict()
    browserSettings["universal_access_from_file_urls_allowed"] = True
    browserSettings["file_access_from_file_urls_allowed"] = True

    if os.path.exists("icon.ico"):
        icon = os.path.abspath("icon.ico")
    else:
        icon = ""

    windowHandle = cefwindow.CreateWindow(title="pywin32 example",
            className="cefpython3_example", width=1024, height=768,
            icon=icon, windowProc=wndproc)
    windowInfo = cefpython.WindowInfo()
    windowInfo.SetAsChild(windowHandle)
    browser = cefpython.CreateBrowserSync(windowInfo, browserSettings,
            navigateUrl=GetApplicationPath("example.html"))
    cefpython.MessageLoop()
    cefpython.Shutdown()

def CloseWindow(windowHandle, message, wparam, lparam):
    browser = cefpython.GetBrowserByWindowHandle(windowHandle)
    browser.CloseBrowser()
    return win32gui.DefWindowProc(windowHandle, message, wparam, lparam)

def QuitApplication(windowHandle, message, wparam, lparam):
    win32gui.PostQuitMessage(0)
    return 0

def GetPywin32Version():
    fixed_file_info = win32api.GetFileVersionInfo(win32api.__file__, '\\')
    return fixed_file_info['FileVersionLS'] >> 16

if __name__ == "__main__":
    Log("pywin32 version = %s" % GetPywin32Version())
    CefAdvanced()
