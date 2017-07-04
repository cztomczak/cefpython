# Example of embedding CEF browser using the PyWin32 extension.
# Tested with pywin32 version 219.

from cefpython3 import cefpython as cef

import distutils.sysconfig
import os
import platform
import sys
import time

import win32api
import win32con
import win32gui

WindowUtils = cef.WindowUtils()

# Platforms (Windows only)
assert(platform.system() == "Windows")

def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    cef.Initialize()
    pyWin32Example()
    """
    if g_message_loop == MESSAGE_LOOP_CEF:
        cef.MessageLoop()
    else:
        gtk.main()
    """
    cef.Shutdown()


def check_versions():
    print("[pywin32.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[pywin32.py] Python {ver} {arch}".format(ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[pywin32.py] pywin32 {ver}".format(ver=GetPywin32Version()))
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"


def pyWin32Example():
    pass


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
    pth = distutils.sysconfig.get_python_lib(plat_specific=1)
    ver = open(os.path.join(pth, "pywin32.version.txt")).read().strip()
    return ver


if __name__ == '__main__':
    main()
