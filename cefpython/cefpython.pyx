# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# IMPORTANT notes:
#
# - cdef/cpdef functions returning something other than a Python object
#   should have in its declaration "except *", otherwise exceptions are
#   ignored. Those cdef/cpdef that return "object" have "except *" by
#   default. The setup/compile.py script will check for functions missing
#   "except *" and will display an error message about that, but it's
#   not perfect and won't detect all cases.
#
# - TODO: add checking for "except * with gil" in functions with the
#   "public" keyword
#
# - about acquiring/releasing GIL lock, see discussion here:
#   https://groups.google.com/forum/?fromgroups=#!topic/cython-users/jcvjpSOZPp0
#
# - <CefRefPtr[ClientHandler]?>new ClientHandler()
#   <...?> means to throw an error if the cast is not allowed
#
# - in client handler callbacks (or others that are called from C++ and
#   use "except * with gil") must embrace all code in try..except otherwise
#   the error will  be ignored, only printed to the output console, this is the
#   default behavior of Cython, to remedy this you are supposed to add "except *"
#   in function declaration, unfortunately it does not work, some conflict with
#   CEF threading, see topic at cython-users for more details:
#   https://groups.google.com/d/msg/cython-users/CRxWoX57dnM/aufW3gXMhOUJ.
#
# - CTags requires all functions/methods imported in .pxd files to be preceded with "cdef",
#   otherwise they are not indexed.
#
# - __del__ method does not exist in Extension Types (cdef class),
#   you have to use __dealloc__ instead, try to remember that as
#   defining __del__ will not raise any warning and could lead to
#   memory leaks.
#
# - CefString.c_str() is safe to use only on Windows, on Ubuntu 64bit
#   for a "Pers" string it returns: "P\x00e\x00r\x00s\x00", which is
#   most probably not what you expected.
#
# - You can rename methods when importing in pxd files:
#   | cdef cppclass _Object "Object":
#
# - Supporting operators that are not yet supported:
#   | CefRefPtr[T]& Assign "operator="(T* p)
#   | cefBrowser.Assign(CefBrowser*)

# Global variables.

g_debug = False
g_debugFile = None

# When put None here and assigned a local dictionary in Initialize(), later while
# running app this global variable was garbage collected, see topic:
# https://groups.google.com/d/topic/cython-users/0dw3UASh7HY/discussion
g_applicationSettings = {}

# All .pyx files need to be included here.

include "cython_includes/compile_time_constants.pxi"
include "imports.pyx"

include "utils.pyx"
include "string_utils.pyx"
IF UNAME_SYSNAME == "Windows":
    include "string_utils_win.pyx"
include "time_utils.pyx"

include "window_info.pyx"
include "browser.pyx"
include "frame.pyx"

IF CEF_VERSION == 1:
    include "cookie.pyx"

include "settings.pyx"
IF UNAME_SYSNAME == "Windows":
    # Off-screen rendering currently supported only on Windows
    include "paint_buffer.pyx"

IF UNAME_SYSNAME == "Windows":
    include "window_utils_win.pyx"
    IF CEF_VERSION == 1:
        include "http_authentication_win.pyx"
ELIF UNAME_SYSNAME == "Linux":
    include "window_utils_linux.pyx"

IF CEF_VERSION == 1:
    include "load_handler.pyx"
    include "keyboard_handler.pyx"
    include "virtual_keys.pyx"
    include "request.pyx"
    include "web_request.pyx"
    include "stream.pyx"
    include "content_filter.pyx"
    include "request_handler.pyx"
    include "response.pyx"
    include "display_handler.pyx"
    include "lifespan_handler.pyx"
    IF UNAME_SYSNAME == "Windows":
        # Off-screen rendering currently supported only on Windows.
        include "render_handler.pyx"
    include "drag_data.pyx"
    include "drag_handler.pyx"
    include "download_handler.pyx"

IF CEF_VERSION == 1:
    include "v8context_handler.pyx"
    include "v8function_handler.pyx"
    include "v8utils.pyx"
    include "javascript_bindings.pyx"
    include "javascript_callback.pyx"
    include "python_callback.pyx"

# Client handler.
cdef CefRefPtr[ClientHandler] g_clientHandler = (
        <CefRefPtr[ClientHandler]?>new ClientHandler())

def Initialize(applicationSettings=None):
    Debug("-" * 60)
    Debug("Initialize() called")

    cdef CefRefPtr[CefApp] cefApp

    IF CEF_VERSION == 3:
        cdef HINSTANCE hInstance = GetModuleHandle(NULL)
        cdef CefMainArgs cefMainArgs = CefMainArgs(hInstance)
        cdef int exitCode
        exitCode = CefExecuteProcess(cefMainArgs, cefApp)
        Debug("CefExecuteProcess(): exitCode = %s" % exitCode)
        if exitCode >= 0:
            exit(exitCode)

    if not applicationSettings:
        applicationSettings = {}
    if not "multi_threaded_message_loop" in applicationSettings:
        applicationSettings["multi_threaded_message_loop"] = False
    if not "unicode_to_bytes_encoding" in applicationSettings:
        applicationSettings["unicode_to_bytes_encoding"] = "utf-8"
    IF CEF_VERSION == 3:
        if not "single_process" in applicationSettings:
            applicationSettings["single_process"] = False

    # We must make a copy as applicationSettings is a reference only that might get destroyed.
    global g_applicationSettings
    for key in applicationSettings:
        g_applicationSettings[key] = copy.deepcopy(applicationSettings[key])

    cdef CefSettings cefApplicationSettings
    SetApplicationSettings(applicationSettings, &cefApplicationSettings)

    Debug("CefInitialize()")
    cdef cpp_bool ret
    IF CEF_VERSION == 1:
        ret = CefInitialize(cefApplicationSettings, cefApp)
    ELIF CEF_VERSION == 3:
        ret = CefInitialize(cefMainArgs, cefApplicationSettings, cefApp)

    if not ret: Debug("CefInitialize() failed")
    return ret

def CreateBrowserSync(windowInfo, browserSettings, navigateUrl):
    Debug("CreateBrowserSync() called")
    assert IsThread(TID_UI), (
            "cefpython.CreateBrowserSync() can only be called on UI thread")

    if not isinstance(windowInfo, WindowInfo):
        raise Exception("CreateBrowserSync() failed: windowInfo: invalid object")

    cdef CefBrowserSettings cefBrowserSettings
    SetBrowserSettings(browserSettings, &cefBrowserSettings)

    cdef CefWindowInfo cefWindowInfo
    SetCefWindowInfo(cefWindowInfo, windowInfo)

    navigateUrl = GetNavigateUrl(navigateUrl)
    Debug("navigateUrl: %s" % navigateUrl)
    cdef CefString cefNavigateUrl
    PyToCefString(navigateUrl, cefNavigateUrl)

    Debug("CefBrowser::CreateBrowserSync()")
    global g_clientHandler
    cdef CefRefPtr[CefBrowser] cefBrowser = cef_browser_static.CreateBrowserSync(
            cefWindowInfo, <CefRefPtr[CefClient]?>g_clientHandler, cefNavigateUrl,
            cefBrowserSettings)

    if <void*>cefBrowser == NULL:
        Debug("CefBrowser::CreateBrowserSync() failed")
        return None
    else:
        Debug("CefBrowser::CreateBrowserSync() succeeded")

    cdef PyBrowser pyBrowser = GetPyBrowser(cefBrowser)
    pyBrowser.SetUserData("__outerWindowHandle", int(windowInfo.parentWindowHandle))

    return pyBrowser

def MessageLoop():
    Debug("MessageLoop()")
    with nogil:
        CefRunMessageLoop()

def MessageLoopWork():
    # Perform a single iteration of CEF message loop processing.
    # This function is used to integrate the CEF message loop
    # into an existing application message loop.

    # Anything that can block for a significant amount of time
    # and is thread-safe should release the GIL:
    # https://groups.google.com/d/msg/cython-users/jcvjpSOZPp0/KHpUEX8IhnAJ
    # GIL must be released here otherwise we will get dead lock
    # when calling from c++ to python.

    with nogil:
        CefDoMessageLoopWork();

def SingleMessageLoop():
    # @deprecated, use MessageLoopWork() instead
    MessageLoopWork()

def QuitMessageLoop():
    Debug("QuitMessageLoop()")
    CefQuitMessageLoop()

def Shutdown():
    Debug("Shutdown()")
    CefShutdown()
