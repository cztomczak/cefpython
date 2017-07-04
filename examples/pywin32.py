# Example of embedding CEF browser using the PyWin32 extension.
# Tested with pywin32 version 219.

from cefpython3 import cefpython as cef

import distutils.sysconfig
import math
import os
import platform
import sys

import win32api
import win32con
import win32gui

WindowUtils = cef.WindowUtils()

# Platforms (Windows only)
assert(platform.system() == "Windows")

def main(multi_threaded_message_loop):
    
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    
    settings = {"multi_threaded_message_loop": 1 if multi_threaded_message_loop else 0}
    cef.Initialize(settings)
    
    wndproc = {
        win32con.WM_CLOSE: CloseWindow,
        win32con.WM_DESTROY: QuitApplication,
        win32con.WM_SIZE: WindowUtils.OnSize,
        win32con.WM_SETFOCUS: WindowUtils.OnSetFocus,
        win32con.WM_ERASEBKGND: WindowUtils.OnEraseBackground
    }
    windowHandle = CreateWindow(title="pywin32 example", className="cefpython3_example", width=1024, height=768, windowProc=wndproc)
    
    windowInfo = cef.WindowInfo()
    windowInfo.SetAsChild(windowHandle)
    
    if(multi_threaded_message_loop):
        # when using multi-threaded message loop, CEF's UI thread is no more application's main thread
        cef.PostTask(cef.TID_UI, _createBrowserInUiThread, windowInfo, {}, "https://www.google.com/")
        win32gui.PumpMessages()
        
    else:
        browser = _createBrowserInUiThread(windowInfo, {}, "https://www.google.com/")
        cef.MessageLoop()
    
    cef.Shutdown()


def check_versions():
    print("[pywin32.py] CEF Python {ver}".format(ver=cef.__version__))
    print("[pywin32.py] Python {ver} {arch}".format(ver=platform.python_version(), arch=platform.architecture()[0]))
    print("[pywin32.py] pywin32 {ver}".format(ver=GetPywin32Version()))
    assert cef.__version__ >= "55.3", "CEF Python v55.3+ required to run this"


def _createBrowserInUiThread(windowInfo, settings, url):
    
    assert(cef.IsThread(cef.TID_UI))
    browser = cef.CreateBrowserSync(windowInfo, settings, url)


def CloseWindow(windowHandle, message, wparam, lparam):
    browser = cef.GetBrowserByWindowHandle(windowHandle)
    browser.CloseBrowser()
    return win32gui.DefWindowProc(windowHandle, message, wparam, lparam)


def QuitApplication(windowHandle, message, wparam, lparam):
    win32gui.PostQuitMessage(0)
    return 0


def CreateWindow(title, className, width, height, windowProc):
    
    wndclass = win32gui.WNDCLASS()
    wndclass.hInstance = win32api.GetModuleHandle(None)
    wndclass.lpszClassName = className
    wndclass.style = win32con.CS_VREDRAW | win32con.CS_HREDRAW
    # win32con.CS_GLOBALCLASS
    wndclass.hbrBackground = win32con.COLOR_WINDOW
    wndclass.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
    wndclass.lpfnWndProc = windowProc
    atomClass = win32gui.RegisterClass(wndclass)
    assert(atomClass != 0)
    
    # Center window on the screen.
    screenx = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
    screeny = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)
    xpos = int(math.floor((screenx - width) / 2))
    ypos = int(math.floor((screeny - height) / 2))
    if xpos < 0: xpos = 0
    if ypos < 0: ypos = 0
    
    windowHandle = win32gui.CreateWindow(className, title, 
                                         win32con.WS_OVERLAPPEDWINDOW | win32con.WS_CLIPCHILDREN | win32con.WS_VISIBLE,
                                         xpos, ypos, width, height, # xpos, ypos, width, height
                                         0, 0, wndclass.hInstance, None)
    
    assert(windowHandle != 0)
    return windowHandle


def GetPywin32Version():
    pth = distutils.sysconfig.get_python_lib(plat_specific=1)
    ver = open(os.path.join(pth, "pywin32.version.txt")).read().strip()
    return ver


if __name__ == '__main__':
    
    if "--multi_threaded_message_loop" in sys.argv:
        print("[pywin32.py] Message loop mode: CEF multi-threaded (best performance)")
        multi_threaded_message_loop = True
    else:
        print("[pywin32.py] Message loop mode: CEF single-threaded")
        multi_threaded_message_loop = False
    
    main(multi_threaded_message_loop)
