# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
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
#   In the same way you can import function with a different name, this one
#   imports a static method Create() while adding a prefix "CefSome_":
#   | cdef extern from "..":
#   |   static CefRefPtr[CefSome] CefSome_Create "CefSome::Create"()
#
# - Declaring C++ classes in Cython. Storing python callbacks
#   in a C++ class using Py_INCREF, Py_DECREF. Calling from
#   C++ using PyObject_CallMethod.
#   | http://stackoverflow.com/a/17070382/623622
#   Disadvantage: when calling python callback from the C++ class
#   declared in Cython there is no easy way to propagate the python
#   exceptions when they occur during execution of the callback.
#
# - | cdef char* other_c_string = py_string
#   This is a very fast operation after which other_c_string points
#   to the byte string buffer of the Python string itself. It is
#   tied to the life time of the Python string. When the Python
#   string is garbage collected, the pointer becomes invalid.
#
# - Do not define cpdef functions returning "cpp_bool":
#   | cpdef cpp_bool myfunc() except *:
#   This causes compiler warnings like this:
#   | cefpython.cpp(26533) : warning C4800: 'int' : forcing value
#   | to bool 'true' or 'false' (performance warning)
#   Do instead declare "py_bool" as return type:
#   | cpdef py_bool myufunc():
#   Lots of these warnings results in ignoring them, but sometimes
#   they are shown for a good reason, for example when you forget
#   to return a value in a function.
#
# - Always import bool from libcpp as cpp_bool, if you import it as
#   "bool" in a pxd file, then Cython will complain about bool casts
#   like "bool(1)" being invalid, in pyx files.

# All .pyx files need to be included in this file.

include "cython_includes/compile_time_constants.pxi"
include "imports.pyx"

# -----------------------------------------------------------------------------
# Global variables

g_debug = False
g_debugFile = "debug.log"

# When put None here and assigned a local dictionary in Initialize(), later 
# while running app this global variable was garbage collected, see topic:
# https://groups.google.com/d/topic/cython-users/0dw3UASh7HY/discussion
g_applicationSettings = {}
g_commandLineSwitches = {}

cdef dict g_globalClientCallbacks = {}

# If ApplicationSettings.unique_request_context_per_browser is False
# then a shared request context is used for all browsers. Otherwise
# a unique one is created for each call to CreateBrowserSync.
cdef CefRefPtr[CefRequestContext] g_sharedRequestContext

# -----------------------------------------------------------------------------

include "utils.pyx"
include "string_utils.pyx"
IF UNAME_SYSNAME == "Windows":
    include "string_utils_win.pyx"
include "time_utils.pyx"

include "browser.pyx"
include "frame.pyx"

include "settings.pyx"
IF UNAME_SYSNAME == "Windows" and CEF_VERSION == 1:
    # Off-screen rendering currently supported only on Windows
    include "paint_buffer_cef1.pyx"

IF UNAME_SYSNAME == "Windows":
    include "window_utils_win.pyx"
    IF CEF_VERSION == 1:
        include "http_authentication_win.pyx"
ELIF UNAME_SYSNAME == "Linux":
    include "window_utils_linux.pyx"

include "javascript_bindings.pyx"
include "virtual_keys.pyx"

IF CEF_VERSION == 1:
    include "window_info_cef1.pyx"
    include "cookie_cef1.pyx"
    include "load_handler_cef1.pyx"
    include "keyboard_handler_cef1.pyx"
    include "request_cef1.pyx"
    include "web_request_cef1.pyx"
    include "stream.pyx"
    include "content_filter.pyx"
    include "request_handler_cef1.pyx"
    include "response_cef1.pyx"
    include "display_handler_cef1.pyx"
    include "lifespan_handler_cef1.pyx"
    IF UNAME_SYSNAME == "Windows":
        # Off-screen rendering currently supported only on Windows.
        include "render_handler_cef1.pyx"
    include "drag_data.pyx"
    include "drag_handler.pyx"
    include "download_handler.pyx"
    include "v8context_handler_cef1.pyx"
    include "v8function_handler_cef1.pyx"
    include "v8utils_cef1.pyx"
    include "javascript_callback_cef1.pyx"
    include "python_callback_cef1.pyx"
    include "network_error_cef1.pyx"

IF CEF_VERSION == 3:
    include "window_info_cef3.pyx"
    include "process_message_utils.pyx"
    include "v8context_handler_cef3.pyx"
    include "v8function_handler_cef3.pyx"
    include "javascript_callback_cef3.pyx"
    include "python_callback_cef3.pyx"
    include "lifespan_handler_cef3.pyx"
    include "display_handler_cef3.pyx"
    include "keyboard_handler_cef3.pyx"
    include "web_plugin_info_cef3.pyx"
    include "request_cef3.pyx"
    include "request_handler_cef3.pyx"
    include "cookie_cef3.pyx"
    include "string_visitor_cef3.pyx"
    include "load_handler_cef3.pyx"
    include "network_error_cef3.pyx"
    include "browser_process_handler_cef3.pyx"
    include "paint_buffer_cef3.pyx"
    include "render_handler_cef3.pyx"
    include "callback_cef3.pyx"
    include "resource_handler_cef3.pyx"
    include "response_cef3.pyx"
    include "web_request_cef3.pyx"
    include "command_line.pyx"
    include "app.pyx"
    include "javascript_dialog_handler.pyx"

# -----------------------------------------------------------------------------
# Utility functions to provide settings to the C++ browser process code.

cdef public void cefpython_GetDebugOptions(
        cpp_bool* debug,
        cpp_string* debugFile
        ) except * with gil:
    # Called from subprocess/cefpython_app.cpp -> CefPythonApp constructor.
    cdef cpp_string cppString = g_debugFile
    try:
        debug[0] = <cpp_bool>bool(g_debug)
        debugFile.assign(cppString)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool ApplicationSettings_GetBool(const char* key
        ) except * with gil:
    # Called from client_handler/client_handler.cpp for example
    cdef py_string pyKey = CharToPyString(key)
    if pyKey in g_applicationSettings:
        return bool(g_applicationSettings[pyKey])
    return False

cdef public cpp_bool ApplicationSettings_GetBoolFromDict(const char* key1,
        const char* key2) except * with gil:
    cdef py_string pyKey1 = CharToPyString(key1)
    cdef py_string pyKey2 = CharToPyString(key2)
    cdef object dictValue # Yet to be checked whether it is `dict`
    if pyKey1 in g_applicationSettings:
        dictValue = g_applicationSettings[pyKey1]
        if type(dictValue) != dict:
            return False
        if pyKey2 in dictValue:
            return bool(dictValue[pyKey2])
    return False

# -----------------------------------------------------------------------------

# If you've built custom binaries with tcmalloc hook enabled on
# Linux, then do not to run any of the CEF code until Initialize()
# is called. See Issue 73 in the CEF Python Issue Tracker.

def Initialize(applicationSettings=None, commandLineSwitches=None):
    if not applicationSettings:
        applicationSettings = {}
    # Debug settings need to be set before Debug() is called
    # and before the CefPythonApp class is instantiated.
    global g_debug
    global g_debugFile
    if "debug" in applicationSettings:
        g_debug = bool(applicationSettings["debug"])
    if "log_file" in applicationSettings:
        g_debugFile = applicationSettings["log_file"]

    Debug("Initialize() called")

    # -------------------------------------------------------------------------
    # CEF Python only options - default values

    if "debug" not in applicationSettings:
        applicationSettings["debug"] = False
    if "string_encoding" not in applicationSettings:
        applicationSettings["string_encoding"] = "utf-8"
    if "unique_request_context_per_browser" not in applicationSettings:
        applicationSettings["unique_request_context_per_browser"] = False
    if "downloads_enabled" not in applicationSettings:
        applicationSettings["downloads_enabled"] = True
    if "remote_debugging_port" not in applicationSettings:
        applicationSettings["remote_debugging_port"] = 0

    # Mouse context menu
    if "context_menu" not in applicationSettings:
        applicationSettings["context_menu"] = {}
    menuItems = ["enabled", "navigation", "print", "view_source",\
            "external_browser", "devtools"]
    for item in menuItems:
        if item not in applicationSettings["context_menu"]:
            applicationSettings["context_menu"][item] = True

    # Remote debugging port. If value is 0 we will generate a random
    # port. To disable remote debugging set value to -1.
    if applicationSettings["remote_debugging_port"] == 0:
        # Generate a random port.  
        applicationSettings["remote_debugging_port"] =\
                random.randint(49152, 65535) 
    elif applicationSettings["remote_debugging_port"] == -1:
        # Disable remote debugging
        applicationSettings["remote_debugging_port"] = 0

    # -------------------------------------------------------------------------

    # CEF options - default values.
    if not "multi_threaded_message_loop" in applicationSettings:
        applicationSettings["multi_threaded_message_loop"] = False
    IF CEF_VERSION == 3:
        if not "single_process" in applicationSettings:
            applicationSettings["single_process"] = False

    cdef CefRefPtr[CefApp] cefApp

    IF CEF_VERSION == 3:
        cefApp = <CefRefPtr[CefApp]?>new CefPythonApp()
        IF UNAME_SYSNAME == "Windows":
            cdef HINSTANCE hInstance = GetModuleHandle(NULL)
            cdef CefMainArgs cefMainArgs = CefMainArgs(hInstance)
        ELIF UNAME_SYSNAME == "Linux":
            # TODO: use the CefMainArgs(int argc, char** argv) constructor.
            cdef CefMainArgs cefMainArgs
        cdef int exitCode = 1
        with nogil:
            exitCode = CefExecuteProcess(cefMainArgs, cefApp)
        Debug("CefExecuteProcess(): exitCode = %s" % exitCode)
        if exitCode >= 0:
            sys.exit(exitCode)

    # Make a copy as applicationSettings is a reference only
    # that might get destroyed later.
    global g_applicationSettings
    for key in applicationSettings:
        g_applicationSettings[key] = copy.deepcopy(applicationSettings[key])

    cdef CefSettings cefApplicationSettings
    SetApplicationSettings(applicationSettings, &cefApplicationSettings)

    if commandLineSwitches:
        # Make a copy as commandLineSwitches is a reference only
        # that might get destroyed later.
        global g_commandLineSwitches
        for key in commandLineSwitches:
            g_commandLineSwitches[key] = copy.deepcopy(
                    commandLineSwitches[key])

    Debug("CefInitialize()")
    cdef cpp_bool ret
    IF CEF_VERSION == 1:
        with nogil:
            ret = CefInitialize(cefApplicationSettings, cefApp)
    ELIF CEF_VERSION == 3:
        with nogil:
            ret = CefInitialize(cefMainArgs, cefApplicationSettings, cefApp)

    if not ret:
        Debug("CefInitialize() failed")
    return ret

def CreateBrowserSync(windowInfo, browserSettings, navigateUrl, requestContext=None):
    Debug("CreateBrowserSync() called")
    assert IsThread(TID_UI), (
            "cefpython.CreateBrowserSync() may only be called on the UI thread")

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
    cdef CefRefPtr[ClientHandler] clientHandler =\
            <CefRefPtr[ClientHandler]?>new ClientHandler()
    cdef CefRefPtr[CefBrowser] cefBrowser

    # Request context - part 1/2.
    createSharedRequestContext = bool(not g_sharedRequestContext.get())
    cdef CefRefPtr[CefRequestContext] cefRequestContext
    cdef CefRefPtr[RequestContextHandler] requestContextHandler =\
            <CefRefPtr[RequestContextHandler]?>new RequestContextHandler(\
                    cefBrowser)
    if g_applicationSettings["unique_request_context_per_browser"]:
        cefRequestContext = CefRequestContext_CreateContext(\
                <CefRefPtr[CefRequestContextHandler]?>requestContextHandler)
    else:
        if createSharedRequestContext:
            cefRequestContext = CefRequestContext_CreateContext(\
                    <CefRefPtr[CefRequestContextHandler]?>\
                            requestContextHandler)
            g_sharedRequestContext.Assign(cefRequestContext.get())
        else:
            cefRequestContext.Assign(g_sharedRequestContext.get())

    # CEF browser creation.
    with nogil:
        cefBrowser = cef_browser_static.CreateBrowserSync(
                cefWindowInfo, <CefRefPtr[CefClient]?>clientHandler,
                cefNavigateUrl, cefBrowserSettings,
                cefRequestContext)

    if <void*>cefBrowser == NULL or not cefBrowser.get():
        Debug("CefBrowser::CreateBrowserSync() failed")
        return None
    else:
        Debug("CefBrowser::CreateBrowserSync() succeeded")

    # Request context - part 2/2.
    if g_applicationSettings["unique_request_context_per_browser"]:
        requestContextHandler.get().SetBrowser(cefBrowser)
    else:
        if createSharedRequestContext:
            requestContextHandler.get().SetBrowser(cefBrowser)

    cdef PyBrowser pyBrowser = GetPyBrowser(cefBrowser)
    pyBrowser.SetUserData("__outerWindowHandle", int(windowInfo.parentWindowHandle))

    # IF CEF_VERSION == 3:
        # Test whether process message sent before renderer thread is created
        # will be delivered - OK.
        # Debug("Sending 'CreateBrowserSync() done' message to the Renderer")
        # pyBrowser.SendProcessMessage(cef_types.PID_RENDERER,
        #        "CreateBrowserSync() done")

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
    with nogil:
        CefQuitMessageLoop()

def Shutdown():
    if g_sharedRequestContext.get():
        # A similar release is done in RemovePyBrowser and CloseBrowser.
        # This one is probably redundant. Additional testing should be done.
        Debug("Shutdown: releasing shared request context")
        g_sharedRequestContext.Assign(NULL)
    Debug("Shutdown()")
    with nogil:
        CefShutdown()

def SetOsModalLoop(py_bool modalLoop):
    cdef cpp_bool cefModalLoop = bool(modalLoop)
    with nogil:
        CefSetOSModalLoop(cefModalLoop)

cpdef py_void SetGlobalClientCallback(py_string name, object callback):
    global g_globalClientCallbacks
    if name in ["OnCertificateError", "OnBeforePluginLoad"]:
        g_globalClientCallbacks[name] = callback
    else:
        raise Exception("SetGlobalClientCallback() failed: " \
                "invalid callback name = %s" % name)

cpdef object GetGlobalClientCallback(py_string name):
    global g_globalClientCallbacks
    if name in g_globalClientCallbacks:
        return g_globalClientCallbacks[name]
    else:
        return None
