# An example of embedding CEF browser in wxPython on Linux.
# Tested with wxPython 2.8.12.1 (gtk2-unicode).
# To install wxPython type "sudo apt-get install python-wxtools".

# This example implements a custom "_OnResourceResponse" callback
# that emulates reading response by utilizing Resourcehandler
# and WebRequest.

FIX_ENCODING_BUG = True
BROWSER_DEFAULT_ENCODING = "utf-8"

# The official CEF Python binaries come with tcmalloc hook
# disabled. But if you've built custom binaries and kept tcmalloc
# hook enabled, then be aware that in such case it is required
# for the cefpython module to be the very first import in
# python scripts. See Issue 73 in the CEF Python Issue Tracker
# for more details.

import ctypes, os, sys
libcef_so = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'libcef.so')
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

import wx
import time
import re
import uuid
import platform
import shutil

class ClientHandler:

    # RequestHandler.GetResourceHandler()
    def GetResourceHandler(self, browser, frame, request):
        # Called on the IO thread before a resource is loaded.
        # To allow the resource to load normally return None.
        print("GetResourceHandler(): url = %s" % request.GetUrl())
        resHandler = ResourceHandler()
        resHandler._clientHandler = self
        resHandler._browser = browser
        resHandler._frame = frame
        resHandler._request = request
        self._AddStrongReference(resHandler)
        return resHandler

    def _OnResourceResponse(self, browser, frame, request, requestStatus,
            requestError, response, data):
        # This callback is emulated through ResourceHandler
        # and WebRequest. Real "OnResourceResponse" is not yet
        # available in CEF 3 (as of CEF revision 1450). See
        # issue 515 in the CEF Issue Tracker:
        # https://code.google.com/p/chromiumembedded/issues/detail?id=515
        # ----
        # requestStatus => cefpython.WebRequest.Status
        #     {"Unknown", "Success", "Pending", "Canceled", "Failed"}
        # For "file://" requests the status will be "Unknown".
        # requestError => see the NetworkError wiki page
        # response.GetStatus() => http status code
        print("_OnResourceResponse()")
        print("data length = %s" % len(data))
        # Return the new data - you can modify it.
        if request.GetUrl().startswith("file://") \
                and request.GetUrl().endswith("example.html"):
            data = "<b style='color: green;'>This text was inserted through " \
                    + "_OnResourceResponse()</b><br>" + data
        # Non-english characters are not displaying correctly.
        # This is a bug in CEF. A quick fix is to get the charset
        # from response headers and insert <meta charset> into
        # the html page.
        # Bug reported on the CEF C++ Forum:
        # http://www.magpcss.org/ceforum/viewtopic.php?p=18401#p18401
        if FIX_ENCODING_BUG:
            contentType = response.GetHeader("Content-Type")
            if contentType:
                contentType = contentType.lower()
            isHtml = False
            headerCharset = ""
            if contentType and "text/html" in contentType:
                isHtml = True
            if contentType and "charset" in contentType:
                match = re.search(r"charset\s*=\s*([^\s]+)", contentType)
                if match and match.group(1):
                    headerCharset = match.group(1).lower()
            if isHtml and headerCharset \
                    and headerCharset != BROWSER_DEFAULT_ENCODING.lower():
                if not re.search(r"<meta[^<>]+charset\s*=", data, \
                        re.IGNORECASE):
                    # Only apply the fix if there is no <meta charset>
                    # available on a page.
                    data = ("<meta charset='%s' />" % headerCharset) + data
        return data

    # A strong reference to ResourceHandler must be kept
    # during the request. Some helper functions for that.
    # 1. Add reference in GetResourceHandler()
    # 2. Release reference in ResourceHandler.ReadResponse()
    #    after request is completed.

    _resourceHandlers = {}
    _resourceHandlerMaxId = 0

    def _AddStrongReference(self, resHandler):
        self._resourceHandlerMaxId += 1
        resHandler._resourceHandlerId = self._resourceHandlerMaxId
        self._resourceHandlers[resHandler._resourceHandlerId] = resHandler

    def _ReleaseStrongReference(self, resHandler):
        if resHandler._resourceHandlerId in self._resourceHandlers:
            del self._resourceHandlers[resHandler._resourceHandlerId]
        else:
            print("_ReleaseStrongReference() FAILED: resource handler " \
                    "not found, id = %s" % (resHandler._resourceHandlerId))

class ResourceHandler:

    # The methods of this class will always be called
    # on the IO thread.

    _resourceHandlerId = None
    _clientHandler = None
    _browser = None
    _frame = None
    _request = None
    _responseHeadersReadyCallback = None
    _webRequest = None
    _webRequestClient = None
    _offsetRead = 0

    def ProcessRequest(self, request, callback):
        print("ProcessRequest()")
        # 1. Start the request using WebRequest
        # 2. Return True to handle the request
        # 3. Once response headers are ready call
        #    callback.Continue()
        self._responseHeadersReadyCallback = callback
        self._webRequestClient = WebRequestClient()
        self._webRequestClient._resourceHandler = self
        # Need to set AllowCacheCredentials and AllowCookies for
        # the cookies to work during POST requests (Issue 127).
        # To skip cache set the SkipCache request flag.
        request.SetFlags(cefpython.Request.Flags["AllowCachedCredentials"]\
                | cefpython.Request.Flags["AllowCookies"])
        # A strong reference to the WebRequest object must kept.
        self._webRequest = cefpython.WebRequest.Create(
                request, self._webRequestClient)
        return True

    def GetResponseHeaders(self, response, responseLengthOut, redirectUrlOut):
        print("GetResponseHeaders()")
        # 1. If the response length is not known set
        #    responseLengthOut[0] to -1 and ReadResponse()
        #    will be called until it returns False.
        # 2. If the response length is known set
        #    responseLengthOut[0] to a positive value
        #    and ReadResponse() will be called until it
        #    returns False or the specified number of bytes
        #    have been read.
        # 3. Use the |response| object to set the mime type,
        #    http status code and other optional header values.
        # 4. To redirect the request to a new URL set
        #    redirectUrlOut[0] to the new url.
        assert self._webRequestClient._response, "Response object empty"
        wrcResponse = self._webRequestClient._response
        response.SetStatus(wrcResponse.GetStatus())
        response.SetStatusText(wrcResponse.GetStatusText())
        response.SetMimeType(wrcResponse.GetMimeType())
        if wrcResponse.GetHeaderMultimap():
            response.SetHeaderMultimap(wrcResponse.GetHeaderMultimap())
        print("headers: ")
        print(wrcResponse.GetHeaderMap())
        responseLengthOut[0] = self._webRequestClient._dataLength
        if not responseLengthOut[0]:
            # Probably a cached page? Or a redirect?
            pass

    def ReadResponse(self, dataOut, bytesToRead, bytesReadOut, callback):
        # print("ReadResponse()")
        # 1. If data is available immediately copy up to
        #    bytesToRead bytes into dataOut[0], set
        #    bytesReadOut[0] to the number of bytes copied,
        #    and return true.
        # 2. To read the data at a later time set
        #    bytesReadOut[0] to 0, return true and call
        #    callback.Continue() when the data is available.
        # 3. To indicate response completion return false.
        if self._offsetRead < self._webRequestClient._dataLength:
            dataChunk = self._webRequestClient._data[\
                    self._offsetRead:(self._offsetRead + bytesToRead)]
            self._offsetRead += len(dataChunk)
            dataOut[0] = dataChunk
            bytesReadOut[0] = len(dataChunk)
            return True
        self._clientHandler._ReleaseStrongReference(self)
        print("no more data, return False")
        return False

    def CanGetCookie(self, cookie):
        # Return true if the specified cookie can be sent
        # with the request or false otherwise. If false
        # is returned for any cookie then no cookies will
        # be sent with the request.
        return True

    def CanSetCookie(self, cookie):
        # Return true if the specified cookie returned
        # with the response can be set or false otherwise.
        return True

    def Cancel(self):
        # Request processing has been canceled.
        pass

class WebRequestClient:

    _resourceHandler = None
    _data = ""
    _dataLength = -1
    _response = None

    def OnUploadProgress(self, webRequest, current, total):
        pass

    def OnDownloadProgress(self, webRequest, current, total):
        pass

    def OnDownloadData(self, webRequest, data):
        # print("OnDownloadData()")
        self._data += data

    def OnRequestComplete(self, webRequest):
        print("OnRequestComplete()")
        # cefpython.WebRequest.Status = {"Unknown", "Success",
        #         "Pending", "Canceled", "Failed"}
        statusText = "Unknown"
        if webRequest.GetRequestStatus() in cefpython.WebRequest.Status:
            statusText = cefpython.WebRequest.Status[\
                    webRequest.GetRequestStatus()]
        print("status = %s" % statusText)
        print("error code = %s" % webRequest.GetRequestError())
        # Emulate OnResourceResponse() in ClientHandler:
        self._response = webRequest.GetResponse()
        # Are webRequest.GetRequest() and
        # self._resourceHandler._request the same? What if
        # there was a redirect, what will GetUrl() return
        # for both of them?
        self._data = self._resourceHandler._clientHandler._OnResourceResponse(
                self._resourceHandler._browser,
                self._resourceHandler._frame,
                webRequest.GetRequest(),
                webRequest.GetRequestStatus(),
                webRequest.GetRequestError(),
                webRequest.GetResponse(),
                self._data)
        self._dataLength = len(self._data)
        # ResourceHandler.GetResponseHeaders() will get called
        # after _responseHeadersReadyCallback.Continue() is called.
        self._resourceHandler._responseHeadersReadyCallback.Continue()

# Which method to use for message loop processing.
#   EVT_IDLE - wx application has priority (default)
#   EVT_TIMER - cef browser has priority
# It seems that Flash content behaves better when using a timer.
# IMPORTANT! On Linux EVT_IDLE does not work, the events seems to
# be propagated only when you move your mouse, which is not the
# expected behavior, it is recommended to use EVT_TIMER on Linux,
# so set this value to False.
USE_EVT_IDLE = False

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

class MainFrame(wx.Frame):
    browser = None
    mainPanel = None

    def __init__(self):
        wx.Frame.__init__(self, parent=None, id=wx.ID_ANY,
                title='wxPython CEF 3 example', size=(800,600))
        self.CreateMenu()

        # Cannot attach browser to the main frame as this will cause
        # the menu not to work.
        # --
        # You also have to set the wx.WANTS_CHARS style for
        # all parent panels/controls, if it's deeply embedded.
        self.mainPanel = wx.Panel(self, style=wx.WANTS_CHARS)

        windowInfo = cefpython.WindowInfo()
        windowInfo.SetAsChild(self.mainPanel.GetGtkWidget())
        # Linux requires adding "file://" for local files,
        # otherwise /home/some will be replaced as http://home/some
        self.browser = cefpython.CreateBrowserSync(
            windowInfo,
            # If there are problems with Flash you can disable it here,
            # by disabling all plugins.
            browserSettings={"plugins_disabled": False,
                    "default_encoding": BROWSER_DEFAULT_ENCODING},
            navigateUrl="file://"+GetApplicationPath("example.html"))

        clientHandler = ClientHandler()
        self.browser.SetClientHandler(clientHandler)

        self.Bind(wx.EVT_CLOSE, self.OnClose)
        if USE_EVT_IDLE:
            # Bind EVT_IDLE only for the main application frame.
            self.Bind(wx.EVT_IDLE, self.OnIdle)

    def CreateMenu(self):
        filemenu = wx.Menu()
        filemenu.Append(1, "Open")
        exit = filemenu.Append(2, "Exit")
        self.Bind(wx.EVT_MENU, self.OnClose, exit)
        aboutmenu = wx.Menu()
        aboutmenu.Append(1, "CEF Python")
        menubar = wx.MenuBar()
        menubar.Append(filemenu,"&File")
        menubar.Append(aboutmenu, "&About")
        self.SetMenuBar(menubar)

    def OnClose(self, event):
        # In wx.chromectrl calling browser.CloseBrowser() and/or
        # self.Destroy() in OnClose is causing crashes when embedding
        # multiple browser tabs. The solution is to call only 
        # browser.ParentWindowWillClose. Behavior of this example
        # seems different as it extends wx.Frame, while ChromeWindow
        # from chromectrl extends wx.Window. Calling CloseBrowser
        # and Destroy does not cause crashes, but is not recommended.
        # Call ParentWindowWillClose and event.Skip() instead. See 
        # also Issue 107.
        self.browser.ParentWindowWillClose()
        event.Skip()

    def OnIdle(self, event):
        cefpython.MessageLoopWork()

class MyApp(wx.App):
    timer = None
    timerID = 1
    timerCount = 0

    def OnInit(self):
        if not USE_EVT_IDLE:
            self.CreateTimer()
        frame = MainFrame()
        self.SetTopWindow(frame)
        frame.Show()
        return True

    def CreateTimer(self):
        # See "Making a render loop":
        # http://wiki.wxwidgets.org/Making_a_render_loop
        # Another approach is to use EVT_IDLE in MainFrame,
        # see which one fits you better.
        self.timer = wx.Timer(self, self.timerID)
        self.timer.Start(10) # 10ms
        wx.EVT_TIMER(self, self.timerID, self.OnTimer)

    def OnTimer(self, event):
        self.timerCount += 1
        # print("wxpython.py: OnTimer() %d" % self.timerCount)
        cefpython.MessageLoopWork()

    def OnExit(self):
        # When app.MainLoop() returns, MessageLoopWork() should
        # not be called anymore.
        if not USE_EVT_IDLE:
            self.timer.Stop()

if __name__ == '__main__':
    sys.excepthook = ExceptHook
    settings = {
        "debug": False, # cefpython debug messages in console and in log_file
        "log_severity": cefpython.LOGSEVERITY_INFO, # LOGSEVERITY_VERBOSE
        "log_file": GetApplicationPath("debug.log"), # Set to "" to disable.
        "release_dcheck_enabled": True, # Enable only when debugging.
        # This directories must be set on Linux
        "locales_dir_path": cefpython.GetModuleDirectory()+"/locales",
        "resources_dir_path": cefpython.GetModuleDirectory(),
        "browser_subprocess_path": "%s/%s" % (
            cefpython.GetModuleDirectory(), "subprocess")
    }
    # print("browser_subprocess_path="+settings["browser_subprocess_path"])
    cefpython.Initialize(settings)
    print('wx.version=%s' % wx.version())
    app = MyApp(False)
    app.MainLoop()
    # Let wx.App destructor do the cleanup before calling cefpython.Shutdown().
    del app
    cefpython.Shutdown()
