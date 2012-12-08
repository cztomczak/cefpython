# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

import win32gui
import win32con
import win32api
import time
import math
import os
import sys
import re

if sys.version_info.major == 2:
    from urllib import pathname2url as urllib_pathname2url
else:
    from urllib.request import pathname2url as urllib_pathname2url

g_debug = False
g_windows = {} # windowID(int): className
g_registeredClasses = {}

def Debug(msg):

    if not g_debug:
        return
    msg = "cefwindow: "+str(msg)
    print(msg)
    with open(GetRealPath("debug.log"), "a") as file:
        file.write(msg+"\n")

def GetRealPath(file=None, encodeURL=False):

    # This function is defined in 2 files: cefpython.pyx and cefwindow.py, if you make changes edit both files.
    # If file is None return current directory, without trailing slash.

    # encodeURL param - will call urllib.pathname2url(), only when file is empty (current dir)
    # or is relative path ("test.html", "some/test.html"), we need to encode it before passing
    # to CreateBrowser(), otherwise it is encoded by CEF internally and becomes (chinese characters):
    # >> %EF%BF%97%EF%BF%80%EF%BF%83%EF%BF%A6
    # but should be:
    # >> %E6%A1%8C%E9%9D%A2

    if file is None: file = ""
    if file.find("/") != 0 and file.find("\\") != 0 and not re.search(r"^[a-zA-Z]+:[/\\]?", file):
        # Execute this block only when relative path ("test.html", "some\test.html") or file is empty (current dir).
        # 1. find != 0 >> not starting with / or \ (/ - linux absolute path, \ - just to be sure)
        # 2. not re.search >> not (D:\\ or D:/ or D: or http:// or ftp:// or file://),
        #     "D:" is also valid absolute path ("D:cefpython" in chrome becomes "file:///D:/cefpython/")
        if hasattr(sys, "frozen"): path = os.path.dirname(sys.executable)
        elif "__file__" in globals(): path = os.path.dirname(os.path.realpath(__file__))
        else: path = os.getcwd()
        path = path + os.sep + file
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path) # directory without trailing slash.
        if encodeURL:
            return urllib_pathname2url(path)
        else:
            return path
    return file

def CreateWindow(title, className, width, height, xpos=None, ypos=None, icon=None, windowProc=None):

    """
    for key in g_windows:
        if g_windows[key] == className:
            raise Exception("There was already created a window with that className: %s."
                "Each created window must have an unique className." % className)
    """

    if not windowProc:
        windowProc = {win32con.WM_CLOSE: WM_CLOSE}

    bigIcon = ""
    smallIcon = ""

    if icon:
        icon = GetRealPath(icon)

        # Load small and big icon.
        # WNDCLASSEX (along with hIconSm) is not supported by pywin32,
        # we need to use WM_SETICON message after window creation.

        # http://stackoverflow.com/questions/2234988/how-to-set-hicon-on-a-window-ico-with-multiple-sizes
        # http://blog.barthe.ph/2009/07/17/wmseticon/

        bigX = win32api.GetSystemMetrics(win32con.SM_CXICON)
        bigY = win32api.GetSystemMetrics(win32con.SM_CYICON)
        bigIcon = win32gui.LoadImage(0, icon, win32con.IMAGE_ICON, bigX, bigY, win32con.LR_LOADFROMFILE)
        smallX = win32api.GetSystemMetrics(win32con.SM_CXSMICON)
        smallY = win32api.GetSystemMetrics(win32con.SM_CYSMICON)
        smallIcon = win32gui.LoadImage(0, icon, win32con.IMAGE_ICON, smallX, smallY, win32con.LR_LOADFROMFILE)

    wndclass = win32gui.WNDCLASS()
    wndclass.hInstance = win32api.GetModuleHandle(None)
    wndclass.lpszClassName = className
    wndclass.style = win32con.CS_VREDRAW | win32con.CS_HREDRAW
    # win32con.CS_GLOBALCLASS
    wndclass.hbrBackground = win32con.COLOR_WINDOW
    wndclass.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
    wndclass.lpfnWndProc = windowProc

    #noinspection PyUnusedLocal
    global g_registeredClasses
    if not className in g_registeredClasses:
        g_registeredClasses[className] = True
        atomclass = win32gui.RegisterClass(wndclass)
        Debug("win32gui.RegisterClass(%s)" % className)

    if xpos is None or ypos is None:
        # Center window on the screen.
        Debug("Centering window on the screen.")
        screenx = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
        screeny = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)
        xpos = int(math.floor((screenx - width) / 2))
        ypos = int(math.floor((screeny - height) / 2))
        if xpos < 0: xpos = 0
        if ypos < 0: ypos = 0

    windowID = win32gui.CreateWindow(className, title,
            win32con.WS_OVERLAPPEDWINDOW | win32con.WS_CLIPCHILDREN | win32con.WS_VISIBLE,
            xpos, ypos, width, height, # xpos, ypos, width, height
            0, 0, wndclass.hInstance, None)
    g_windows[windowID] = className

    if icon:
        if bigIcon:
            win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_BIG, bigIcon)
        if smallIcon:
            win32api.SendMessage(windowID, win32con.WM_SETICON, win32con.ICON_SMALL, smallIcon)

    Debug("windowID = %s" % windowID)
    return windowID


# Memory error when calling win32gui.DestroyWindow()
# after we called cefpython.CloseBrowser()

def DestroyWindow(windowID):

    win32gui.DestroyWindow(windowID)
    #className = GetWindowClassName(windowID)
    #win32gui.UnregisterClass(className, None)
    #del g_windows[windowID] # Let window with this className be created again.


def GetWindowClassName(windowID):

    for key in g_windows:
        if key == windowID:
            return g_windows[key]

def MoveWindow(windowID, xpos=None, ypos=None, width=None, height=None, center=None):

    (left, top, right, bottom) = win32gui.GetWindowRect(windowID)
    if xpos is None and ypos is None:
        xpos = left
        ypos = top
    if width is None and height is None:
        width = right - left
        height = bottom - top
    # Case: only ypos provided
    if xpos is None and ypos is not None:
        xpos = left
    if ypos is None and xpos is not None:
        ypos = top
    # Case: only height provided
    if not width:
        width = right - left
    if not height:
        height = bottom - top
    if center:
        screenx = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
        screeny = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)
        xpos = int(math.floor((screenx - width) / 2))
        ypos = int(math.floor((screeny - height) / 2))
        if xpos < 0: xpos = 0
        if ypos < 0: ypos = 0
    win32gui.MoveWindow(windowID, xpos, ypos, width, height, 1)


#noinspection PyUnusedLocal
def WM_CLOSE(windowID, msg, wparam, lparam):

    DestroyWindow(windowID)
    win32gui.PostQuitMessage(0)


def GetLastError():

    code = win32api.GetLastError()
    return "(%d) %s" % (code, win32api.FormatMessage(code))

#noinspection PyUnusedLocal
def MessageLoop(className):

    while not win32gui.PumpWaitingMessages():
        time.sleep(0.001)


if __name__ == "__main__":

    g_debug = True
    hwnd = CreateWindow("Test window", "testwindow", 800, 600)
    MessageLoop("testwindow")