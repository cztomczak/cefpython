# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

class WindowUtils(object):

    @classmethod
    def OnSetFocus(cls, WindowHandle windowHandle, long msg, long wparam,
                   long lparam):
        cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
        if not pyBrowser:
            return 0
        pyBrowser.SetFocus(True)
        return 0

    @classmethod
    def OnSize(cls, WindowHandle windowHandle, long msg, long wparam,
               long lparam):
        cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
        if not pyBrowser:
            return DefWindowProc(<HWND>windowHandle, msg, wparam, lparam)

        cdef HWND innerHwnd = <HWND>pyBrowser.GetWindowHandle()
        cdef RECT rect2
        GetClientRect(<HWND>windowHandle, &rect2)

        cdef HDWP hdwp = BeginDeferWindowPos(1)
        hdwp = DeferWindowPos(hdwp, innerHwnd, NULL,
                rect2.left, rect2.top,
                rect2.right - rect2.left,
                rect2.bottom - rect2.top,
                SWP_NOZORDER)
        EndDeferWindowPos(hdwp)

        return DefWindowProc(<HWND>windowHandle, msg, wparam, lparam)

    @classmethod
    def OnEraseBackground(cls, WindowHandle windowHandle, long msg,
                          long wparam, long lparam):
        cdef PyBrowser pyBrowser = GetBrowserByWindowHandle(windowHandle)
        if not pyBrowser:
            return DefWindowProc(<HWND>windowHandle, msg, wparam, lparam)

        # Dont erase the background if the browser window has been loaded,
        # this avoids flashing.
        if pyBrowser.GetWindowHandle():
            return 0

        return DefWindowProc(<HWND>windowHandle, msg, wparam, lparam)

    @classmethod
    def SetTitle(cls, PyBrowser pyBrowser, str pyTitle):
        # Each browser window should have a title (Issue 3).
        # When popup is created, the window that sits in taskbar
        # has no title.
        if not pyTitle:
            return

        cdef WindowHandle windowHandle
        if pyBrowser.GetUserData("__outerWindowHandle"):
            windowHandle = <WindowHandle>\
                    pyBrowser.GetUserData("__outerWindowHandle")
        else:
            windowHandle = pyBrowser.GetWindowHandle()

        assert windowHandle, (
                "WindowUtils.SetTitle() failed: windowHandle is empty")

        # Get window title.
        cdef int sizeOfTitle = 100
        cdef wchar_t* widecharTitle = (
                <wchar_t*>calloc(sizeOfTitle, wchar_t_size))
        GetWindowTextW(<HWND>windowHandle, widecharTitle, sizeOfTitle)
        cdef str currentTitle = WidecharToPyString(widecharTitle)
        free(widecharTitle)

        # Must keep alive while c_str() is passed.
        cdef CefString cefTitle
        PyToCefString(pyTitle, cefTitle)

        if pyBrowser.GetUserData("__outerWindowHandle"):
            if not currentTitle:
                SetWindowTextW(<HWND>windowHandle, cefTitle.ToWString().c_str())
        else:
            # For independent popups we always change title to what page
            # is displayed currently.
            SetWindowTextW(<HWND>windowHandle, cefTitle.ToWString().c_str())

    @classmethod
    def SetIcon(cls, PyBrowser pyBrowser, py_string icon="inherit"):
        # `icon` parameter is not implemented.
        # Popup window inherits icon from the main window.

        if pyBrowser.GetUserData("__outerWindowHandle"):
            return None

        windowHandle = pyBrowser.GetWindowHandle()
        assert windowHandle, (
                "WindowUtils.SetIcon() failed: windowHandle is empty")

        iconBig = SendMessage(
                <HWND>windowHandle, WM_GETICON, ICON_BIG, 0)
        iconSmall = SendMessage(
                <HWND>windowHandle, WM_GETICON, ICON_SMALL, 0)

        cdef WindowHandle parentWindowHandle

        if not iconBig and not iconSmall:
            parentWindowHandle = pyBrowser.GetOpenerWindowHandle()
            parentIconBig = SendMessage(
                    <HWND>parentWindowHandle, WM_GETICON, ICON_BIG, 0)
            parentIconSmall = SendMessage(
                    <HWND>parentWindowHandle, WM_GETICON, ICON_SMALL, 0)

            # If parent is main application window, then
            # GetOpenerWindowHandle() returned innerWindowHandle
            # of the parent window, try again.

            if not parentIconBig and not parentIconSmall:
                parentWindowHandle = <uintptr_t>GetParent(
                                                    <HWND>parentWindowHandle)

            Debug("WindowUtils.SetIcon(): popup inherits icon from "
                    "parent window: %s" % parentWindowHandle)

            parentIconBig = SendMessage(
                    <HWND>parentWindowHandle, WM_GETICON, ICON_BIG, 0)
            parentIconSmall = SendMessage(
                    <HWND>parentWindowHandle, WM_GETICON, ICON_SMALL, 0)

            if parentIconBig:
                SendMessage(<HWND>windowHandle, WM_SETICON,
                            ICON_BIG, parentIconBig)
            if parentIconSmall:
                SendMessage(<HWND>windowHandle, WM_SETICON,
                            ICON_SMALL, parentIconSmall)

    @classmethod
    def GetParentHandle(cls, WindowHandle windowHandle):
        return <WindowHandle>GetParent(<HWND>windowHandle)

    @classmethod
    def IsWindowHandle(cls, WindowHandle windowHandle):
        IF UNAME_SYSNAME == "Windows":
            return bool(IsWindow(<HWND>windowHandle))
        ELSE:
            return False

    @classmethod
    def InstallX11ErrorHandlers(cls):
        pass
