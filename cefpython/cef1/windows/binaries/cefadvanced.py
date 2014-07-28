# coding=utf-8

# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Checking whether python architecture and version are valid,
# otherwise an obfuscated error will be thrown when trying
# to load cefpython.pyd with a message "DLL load failed".

import platform
if platform.architecture()[0] != "32bit":
    raise Exception("Only 32bit architecture is supported")

import os, sys
libcef_dll = os.path.join(os.path.dirname(os.path.abspath(__file__)),
        'libcef.dll')
if os.path.exists(libcef_dll):
    # Import the local module.
    if 0x02070000 <= sys.hexversion < 0x03000000:
        import cefpython_py27 as cefpython
    elif 0x03000000 <= sys.hexversion < 0x04000000:
        import cefpython_py32 as cefpython
    else:
        raise Exception("Unsupported python version: %s" % sys.version)
else:
    # Import the package.
    from cefpython1 import cefpython

import cefwindow

# pywin32 extension
import win32api
import win32con
import win32gui

import re
import imp
import inspect
import pprint
import time
import imp

DEBUG = True

# TODO: example of creating popup windows from python,
#       call WindowInfo.SetAsPopup().
# TODO: example of creating modal windows from python.

def GetApplicationPath(file=None):
    import re, os
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

def InitDebugging():
    # Whether to print & log debug messages
    if DEBUG:
        cefpython.g_debug = True
        cefpython.g_debugFile = GetApplicationPath("debug.log")
        cefwindow.g_debug = True

def CefAdvanced():
    sys.excepthook = ExceptHook
    InitDebugging()

    appSettings = dict()
    appSettings["log_file"] = GetApplicationPath("debug.log")

    # LOGSEVERITY_INFO - less debug oput.
    # LOGSEVERITY_DISABLE - will not create "debug.log" file.
    appSettings["log_severity"] = cefpython.LOGSEVERITY_VERBOSE

    # Enable only when debugging, otherwise performance might hurt.
    appSettings["release_dcheck_enabled"] = True

    # Must be set so that OnUncaughtException() is called.
    appSettings["uncaught_exception_stack_size"] = 100

    cefpython.Initialize(applicationSettings=appSettings)

    # Closing main window quits the application as we define
    # WM_DESTOROY message.
    wndproc = {
        win32con.WM_CLOSE: CloseWindow,
        win32con.WM_DESTROY: QuitApplication,
        win32con.WM_SIZE: cefpython.WindowUtils.OnSize,
        win32con.WM_SETFOCUS: cefpython.WindowUtils.OnSetFocus,
        win32con.WM_ERASEBKGND: cefpython.WindowUtils.OnEraseBackground
    }

    windowHandle = cefwindow.CreateWindow(
            title="CefAdvanced", className="cefadvanced",
            width=900, height=710, icon="icon.ico", windowProc=wndproc)

    browserSettings = dict()
    browserSettings["history_disabled"] = False
    browserSettings["universal_access_from_file_urls_allowed"] = True
    browserSettings["file_access_from_file_urls_allowed"] = True

    javascriptBindings = cefpython.JavascriptBindings(
            bindToFrames=False, bindToPopups=True)
    windowInfo = cefpython.WindowInfo()
    windowInfo.SetAsChild(windowHandle)
    browser = cefpython.CreateBrowserSync(
            windowInfo, browserSettings=browserSettings,
            navigateUrl=GetApplicationPath("cefadvanced.html"))
    browser.SetUserData("outerWindowHandle", windowInfo.parentWindowHandle)
    browser.SetClientHandler(ClientHandler())
    browser.SetJavascriptBindings(javascriptBindings)

    javascriptRebindings = JavascriptRebindings(javascriptBindings, browser)
    javascriptRebindings.Bind()
    browser.SetUserData("javascriptRebindings", javascriptRebindings)

    cefpython.MessageLoop()
    cefpython.Shutdown()

def CloseWindow(windowHandle, msg, wparam, lparam):
    browser = cefpython.GetBrowserByWindowHandle(windowHandle)
    browser.CloseBrowser()
    return win32gui.DefWindowProc(windowHandle, msg, wparam, lparam)

def QuitApplication(windowHandle, msg, wparam, lparam):
    win32gui.PostQuitMessage(0)
    return 0

class JavascriptRebindings:
    javascriptBindings = None
    browser = None

    def __init__(self, javascriptBindings, browser):
        self.javascriptBindings = javascriptBindings
        self.browser = browser

    def Bind(self):
        # These bindings are rebinded when pressing F5.
        # It's not useful for the main module as it can't be reloaded.
        python = Python()
        python.browser = self.browser

        # Overwrite "window.alert".
        # self.javascriptBindings.SetFunction("alert", python.Alert)

        self.javascriptBindings.SetObject("python", python)
        self.javascriptBindings.SetObject("browser", self.browser)
        self.javascriptBindings.SetObject("frame", self.browser.GetMainFrame())
        self.javascriptBindings.SetProperty("PyConfig",
                {"option1": True, "option2": 20})

    def Rebind(self):
        # Reload all application modules, next rebind javascript bindings.
        # Called from: OnKeyEvent > F5.

        currentDir = GetApplicationPath()

        for mod in sys.modules.values():
            if mod and mod.__name__ != "__main__":
                # This module resides in app's directory.
                if hasattr(mod, "__file__") and (
                mod.__file__.find(currentDir) != -1):
                    try:
                        imp.reload(mod)
                        if DEBUG:
                            print("Reloaded module: %s" % mod.__name__)
                    except (Exception, exc):
                        print("WARNING: reloading module failed: %s. "
                              "Exception: %s" % (mod.__name__, exc))

        # cefpython & cefwindow modules have been reloaded,
        # we need to re-initialize debugging.
        InitDebugging()

        self.Bind()
        self.javascriptBindings.Rebind()

class ClientHandler:

    def OnLoadStart(self, browser, frame):
        # print("OnLoadStart(): frame url: %s" % frame.GetUrl())
        pass

    def OnLoadEnd(self, browser, frame, httpStatusCode):
        # print("OnLoadEnd(): frame url: %s" % frame.GetUrl())
        pass

    def OnLoadError(self, browser, frame, errorCode, failedUrl, errorText):
        # print("OnLoadError() failedUrl: %s" % (failedUrl))
        errorText[0] = ("Custom error message when loading url fails, "
                       "see: def OnLoadError()")
        return True

    def OnKeyEvent(self, browser, eventType, keyCode, modifiers, isSystemKey,
                   isAfterJavascript):

        # print("eventType = %s, keyCode=%s, modifiers=%s, isSystemKey=%s" %
        #        (eventType, keyCode, modifiers, isSystemKey))

        if eventType != cefpython.KEYEVENT_RAWKEYDOWN or isSystemKey:
            return False

        # Bind F12 to developer tools.
        if keyCode == cefpython.VK_F12 and (
        cefpython.IsKeyModifier(cefpython.KEY_NONE, modifiers)):
            browser.ShowDevTools()
            return True

        # Bind F5 to refresh browser window.
        # Also reload all modules and rebind javascript bindings.
        if keyCode == cefpython.VK_F5 and (
        cefpython.IsKeyModifier(cefpython.KEY_NONE, modifiers)):
            # When we press F5 in Developer Tools popup, there are
            # no bindings in this window, error would be thrown.
            # Pressing F5 in Developer Tools seem to not refresh
            # the parent window.
            if browser.GetUserData("javascriptRebindings"):
                browser.GetUserData("javascriptRebindings").Rebind()
            # This is not required, rebinding will work without refreshing page.
            browser.ReloadIgnoreCache()
            return True

        # Bind Ctrl(+) to increase zoom level
        if keyCode in (187, 107) and (
        cefpython.IsKeyModifier(cefpython.KEY_CTRL, modifiers)):
            browser.SetZoomLevel(browser.GetZoomLevel() +1)
            return True

        # Bind Ctrl(-) to reduce zoom level
        if keyCode in (189, 109) and (
        cefpython.IsKeyModifier(cefpython.KEY_CTRL, modifiers)):
            browser.SetZoomLevel(browser.GetZoomLevel() -1)
            return True

        # Bind F11 to go fullscreen.
        if keyCode == cefpython.VK_F11 and (
        cefpython.IsKeyModifier(cefpython.KEY_NONE, modifiers)):
            browser.ToggleFullscreen()
            return True

        return False

    def OnConsoleMessage(self, browser, message, source, line):
        appdir = GetApplicationPath().replace("\\", "/")
        if appdir[1] == ":":
            appdir = appdir[0].upper() + appdir[1:]
        source = source.replace("file:///", "")
        source = source.replace(appdir, "")
        print("Console message: %s (%s:%s)\n" % (message, source, line));
        return False

    def OnResourceResponse(self, browser, url, response, filter):
        # This function does not get called for local disk sources (file:///).
        pass
        # print("Resource: %s (status=%s)" % (url, response.GetStatus()))
        # response.SetHeaderMap(
        #        {"Content-Length": 123, "Content-Type": "none"})
        # print("response.GetHeaderMap(): %s" % response.GetHeaderMap())
        # print("response.GetHeaderMultimap(): %s" % (
        #        response.GetHeaderMultimap()))

    def OnUncaughtException(self, browser, frame, exception, stackTrace):
        if not "cefadvanced.html" in frame.GetUrl():
            # Exit application when javascript encountered
            # only for the cefadvanced.html example.
            return
        url = exception["scriptResourceName"]
        stackTrace = cefpython.FormatJavascriptStackTrace(stackTrace)
        if re.match(r"file:/+", url):
            # Get a relative path of the html/js file,
            # get rid of the "file://d:/.../cefpython/".
            url = re.sub(r"^file:/+", "", url)
            url = re.sub(r"[/\\]+", re.escape(os.sep), url)
            url = re.sub(r"%s" % re.escape(GetApplicationPath()),
                         "", url, flags=re.IGNORECASE)
            url = re.sub(r"^%s" % re.escape(os.sep), "", url)
        raise Exception("%s.\n"
                        "On line %s in %s.\n"
                        "Source of that line: %s\nStack trace:\n%s" % (
                        exception["message"], exception["lineNumber"],
                        url, exception["sourceLine"], stackTrace))

    def OnTitleChange(self, browser, title):
        # cefpython.WindowUtils.SetTitle(browser, "ąś")
        # return False
        return True

def ModuleExists(module):
    try:
        imp.find_module(module)
        return True
    except ImportError:
        return False

class Python:
    browser = None

    def SaveImage(self, outfile, format):
        outfile = GetApplicationPath(outfile)
        (width, height) = self.browser.GetSize(cefpython.PET_VIEW)
        buffer = self.browser.GetImage(cefpython.PET_VIEW, width, height)
        if ModuleExists("PIL"):
            self.__SaveImageWithPil(buffer, width, height, outfile, format)
        elif ModuleExists("pygame"):
            self.__SaveImageWithPygame(buffer, width, height, outfile)
        else:
            print("Could not save image, no image library found (PIL, pygame)")
        if os.path.exists(outfile):
            os.system(outfile)

    def __SaveImageWithPil(self, buffer, width, height, outfile, format):
        from PIL import Image
        image = Image.fromstring(
            "RGBA", (width,height),
            buffer.GetString(mode="rgba", origin="top-left"),
            "raw", "RGBA", 0, 1)
        image.save(outfile, format)

    def __SaveImageWithPygame(self, buffer, width, height, outfile):
        import pygame
        # Format "PNG" is read from the filename.
        surface  = pygame.image.frombuffer(
                buffer.GetString(mode="rgba", origin="top-left"),
                (width, height), "RGBA")
        pygame.image.save(surface, outfile)

    def ExecuteJavascript(self, jsCode):
        self.browser.GetMainFrame().ExecuteJavascript(jsCode)

    def LoadUrl(self):
        self.browser.GetMainFrame().LoadUrl(
                GetApplicationPath("cefsimple.html"))

    def Version(self):
        return sys.version

    def Test1(self, arg1):
        print("python.Test1(%s) called" % arg1)
        return ("This string was returned from python function python.Test1()"
                " [unicode: ąś]")

    def Test2(self, arg1, arg2, arg3):
        # ąś == b"\xc4\x85\xc5\x9b"
        # ąś == u"\u0105\u015b"
        # Displaying utf-8 characters to the console may result
        # in UnicodeDecodeError, thus let's convert it to bytes
        # and display the raw b"\xc4\x85\xc5\x9b" characters.
        arg2_original = arg2
        if type(arg2) != bytes:
            arg2 = arg2.encode(encoding="utf-8")
        print("python.Test2(%s, '%s', '%s') called" % (arg1, arg2, arg3))
        # Testing nested return values.
        return [1,2, [2.1, {'3': 3, '4': [5,6]}], "[unicode: ąś]",
                arg2_original, arg2]

    def PrintPyConfig(self):
        print("python.PrintPyConfig(): %s" % (
                self.browser.GetMainFrame().GetProperty("PyConfig")))

    def ChangePyConfig(self):
        self.browser.GetMainFrame().SetProperty("PyConfig",
                "Changed in python during runtime in python.ChangePyConfig()")

    def TestJavascriptCallback(self, jsCallback):
        if isinstance(jsCallback, cefpython.JavascriptCallback):
            print("python.TestJavascriptCallback(): jsCallback.GetName(): "
                  "%s" % jsCallback.GetName())
            print("jsCallback.Call(1, [2,3], ('tuple', 'tuple'), "
                  "'unicode string')")
            if bytes == str:
                # Python 2.7
                jsCallback.Call(1, [2,3], ('tuple', 'tuple'),
                        unicode('unicode string [ąś]', encoding="utf-8"))
            else:
                # Python 3.2 - there is no "unicode()" in python 3
                jsCallback.Call(1, [2,3], ('tuple', 'tuple'),
                        'unicode string [ąś]',
                        'bytes string [ąś]'.encode('utf-8'))
        else:
            raise Exception("python.TestJavascriptCallback() failed: "
                    "given argument is not a javascript callback function")

    def TestPythonCallbackThroughReturn(self):
        print("python.TestPythonCallbackThroughReturn() called, "
              "returning PyCallback.")
        return self.PyCallback

    def PyCallback(self, *args):
        print("python.PyCallback() called, args: %s" % str(args))

    def TestPythonCallbackThroughJavascriptCallback(self, jsCallback):
        print("python.TestPythonCallbackThroughJavascriptCallback(jsCallback) "
              "called")
        print("jsCallback.Call(PyCallback)")
        jsCallback.Call(self.PyCallback)

    def Alert(self, msg):
        print("python.Alert() called instead of window.alert()")
        win32gui.MessageBox(self.browser.GetUserData("outerWindowHandle"),
                msg, "python.Alert()", win32con.MB_ICONQUESTION)

    def ChangeAlertDuringRuntime(self):
        self.browser.GetMainFrame().SetProperty("alert", self.Alert2)

    def Alert2(self, msg):
        print("python.Alert2() called instead of window.alert()")
        win32gui.MessageBox(self.browser.GetUserData("outerWindowHandle"),
                msg, "python.Alert2()", win32con.MB_ICONSTOP)

    def Find(self, searchText, findNext=False):
        self.browser.Find(1, searchText, forward=True, matchCase=False,
                          findNext=findNext)

    def ResizeWindow(self):
        cefwindow.MoveWindow(self.browser.GetUserData("outerWindowHandle"),
                             width=500, height=500)

    def MoveWindow(self):
        cefwindow.MoveWindow(self.browser.GetUserData("outerWindowHandle"),
                             xpos=0, ypos=0)

    def GetType(self, arg1):
        return "arg1=%s, type=%s" % (arg1, type(arg1).__name__)

    def CreateSecondBrowser(self):
        # Closing second window won't quit application,
        # WM_DESTROY not defined here.
        wndproc2 = {
            win32con.WM_CLOSE: CloseWindow,
            win32con.WM_SIZE: cefpython.WindowUtils.OnSize,
            win32con.WM_SETFOCUS: cefpython.WindowUtils.OnSetFocus,
            win32con.WM_ERASEBKGND: cefpython.WindowUtils.OnEraseBackground
        }
        windowHandle2 = cefwindow.CreateWindow(
                title="SecondBrowser", className="secondbrowser",
                width=800, height=600, xpos=0, ypos=0, icon="icon.ico",
                windowProc=wndproc2)
        windowInfo2 = cefpython.WindowInfo()
        windowInfo2.SetAsChild(windowHandle2)
        browser2 = cefpython.CreateBrowserSync(
                windowInfo2, browserSettings={},
                navigateUrl=GetApplicationPath("cefsimple.html"))
        browser2.SetUserData("outerWindowHandle", windowHandle2)

    def GetUnicodeString(self):
        if bytes == str:
            # Python 2.7. Can't write u"This is unicode string \u2014"
            # because Python 3 complains.
            return unicode("This is unicode string \xe2\x80\x94".decode("utf-8"))
        else:
            return "Unicode string can be tested only in python 2.x"

    def TransparentPopup(self):
        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsPopup(self.browser.GetWindowHandle(), "transparent")
        windowInfo.SetTransparentPainting(True)
        cefpython.CreateBrowserSync(windowInfo, browserSettings={},
                navigateUrl=GetApplicationPath("cefsimple.html"))

if __name__ == "__main__":
    CefAdvanced()
