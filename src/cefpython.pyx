# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

"""
CHANGES in CEF since v31..v51.
Below are listed new or modified functions/classes, but not all of them.
-------------------------------------------------------------------------------

CefEnableHighDPISupport()

CefRequestContext
    NEW BROWSER SETTINGS that can be get/set using request context:
        * GetAllPreferences - all preferences for browser's request context
        * SetPreference
        * many more methods has/get/canset...
    _cef_request_context_settings_t:
        cache_path
        persist_session_cookies
        persist_user_preferences
        ignore_certificate_errors
    PurgePluginListCache
    GetDefaultCookieManager
    GetCachePath
    IsSharingWith - possible to create new context that shares
                    storage with another context
    more methods...

CefRequestContextHandler
    OnBeforePluginLoad

CefBrowserSettings
    windowless_frame_rate - **OSR**

CefBrowserHost
    GetNavigationEntries
    PrintToPDF
    ParentWindowWillClose() - REMOVED, update .py examples
    SetWindowVisibility()
    ShowDevTools(WindowInfo, CefClient, BrowserSettings, inspect_element_at)
    CloseDevTools [DONE]
    ReplaceMisspelling
    AddWordToDictionary
    Invalidate
    NotifyMoveOrResizeStarted() - call in WM_MOVE, WM_MOVING, WM_SIZING on Win
    GetWindowlessFrameRate - **OSR**
    SetWindowlessFrameRate - **OSR**
    DragTargetDragEnter
    DragTargetDragOver
    DragTargetDragLeave
    DragTargetDrop
    DragSourceEndedAt
    DragSourceSystemDragEnded
    HasDevTools
    DownloadImage
    HasView

CefRequestHandler
    OnOpenURLFromTab
    OnBeforeResourceLoad - new arg CefRequestCallback
    OnResourceResponse
    GetResourceResponseFilter - easy way to alter response, no need for the
                         complicated wxpython-response.py example (Issue #229)
    OnResourceLoadComplete
    OnCertificateError - new args: browser and ssl_info.
                         No more need to set it using
                         cefpython.SetGlobalClientCallback()
    OnRenderViewReady

Support for handling onbeforeunload in LifespanHandler::DoClose with
the use of Browser.TryCloseBrowser() or Browser.CloseBrowser.

CefRequest
    SetReferrer
    GetReferrerURL
    GetReferrerPolicy
    GetIdentifier

CefResponse
    GetError
    SetError

CEF exposes Views/Aura framework as an alternative API
for client applications. This can be a replacement for
WinAPI/GTK/X11/Cocoa UI frameworks. See for more info:
https://bitbucket.org/chromiumembedded/cef/issues/1749

CefPrintHandler - Linux only
CefPrintSettings

CefDisplayHandler
    OnFaviconURLChange
    OnFullscreenModeChange

CefRenderHandler
    OnCursorChange - new args: type and custom_cursor_info
    StartDragging
    UpdateDragCursor
    OnScrollOffsetChanged - new args: x,y


In upstream cefclient:
1. g_signal_connect(G_OBJECT(window_), "configure-event",
                    G_CALLBACK(&RootWindowGtk::WindowConfigure), this);
   browser->GetHost()->NotifyMoveOrResizeStarted();
2. g_signal_connect(G_OBJECT(window_), "focus-in-event",
                    G_CALLBACK(&RootWindowGtk::WindowFocusIn), this);
   self->browser_window_->SetFocus(true);

When window is minimized set browser size to 0x0 to reduce resource usage.
See cefclient:
- on Windows see https://github.com/cztomczak/phpdesktop/issues/179
- on Linux see root_window_gtk.cc > WindowState

CefContextMenuHandler
    RunContextMenu
CefContextMenuParams
    GetMisspelledWord
    GetDictionarySuggestions
    IsSpellCheckEnabled
    IsCustomMenu
    IsPepperMenu

CefCompletionCallback - added to many cookie functions to run asynchronously
                        on the IO thread

include/cef_parser.h - url/css/json/etc parsers

CefResourceBundle
CefResponseFilter

CefValue

cef_get_current_platform_thread_id()
cef_get_current_platform_thread_handle()

cef_get_xdisplay();

include/cef_ssl_info.h
include/wrapper/cef_helpers.h - CefDeleteOnThread() free object on
                                the specified thread
include/wrapper/cef_resource_manager.h

CefPostData
    HasExcludedElements

-------------------------------------------------------------------------------
END OF: CHANGES in CEF since v31..v47.
"""

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
# -  Note that acquiring the GIL is a blocking thread-synchronising operation,
#    and therefore potentially costly. It might not be worth releasing the GIL
#    for minor calculations. Usually, I/O operations and substantial
#    computations in parallel code will benefit from it.
#
# -  In regards to GIL locks see Issue #102 "Remove GIL to avoid deadlocks when
#    calling CEF functions".
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
# - When defining cpdef functions returning "cpp_bool":
#   | cpdef cpp_bool myfunc() except *:
#   Always do an additional cast when returning value, even when
#   variable is defined as py_bool:
#   | cdef py_bool returnValue
#   | return bool(returnValue)
#   Otherwise compiler warnings appear:
#   | cefpython.cpp(26533) : warning C4800: 'int' : forcing value
#   | to bool 'true' or 'false' (performance warning)
#   Lots of these warnings results in ignoring them, but sometimes
#   they are shown for a good reason. For example when you forget
#   to return a value in a function.
#
# - Always import bool from libcpp as cpp_bool, if you import it as
#   "bool" in a pxd file, then Cython will complain about bool casts
#   like "bool(1)" being invalid, in pyx files.
#
# - malloc example code:
#   from libc.stdlib cimport malloc, free
#   cdef RECT* rect = <RECT*>malloc(sizeof(RECT))
#   free(rect)
#

# All .pyx files need to be included in this file.
# Includes being made in other .pyx files are allowed to help
# IDE completion, but will be removed during cython compilation.

# Version file is generated by the compile.bat/compile.py script.
include "__version__.pyx"

include "compile_time_constants.pxi"


# -----------------------------------------------------------------------------
# IMPORTS

# noinspection PyUnresolvedReferences
import os
import sys
# noinspection PyUnresolvedReferences
import cython
# noinspection PyUnresolvedReferences
import platform
# noinspection PyUnresolvedReferences
import traceback
# noinspection PyUnresolvedReferences
import time
# noinspection PyUnresolvedReferences
import types
# noinspection PyUnresolvedReferences
import re
# noinspection PyUnresolvedReferences
import copy
# noinspection PyUnresolvedReferences
import inspect # used by JavascriptBindings.__SetObjectMethods()
# noinspection PyUnresolvedReferences
import urllib
# noinspection PyUnresolvedReferences
import json
# noinspection PyUnresolvedReferences
import datetime
# noinspection PyUnresolvedReferences
import random

if sys.version_info.major == 2:
    # noinspection PyUnresolvedReferences
    import urlparse
else:
    # noinspection PyUnresolvedReferences
    from urllib import parse as urlparse

if sys.version_info.major == 2:
    # noinspection PyUnresolvedReferences
    from urllib import pathname2url as urllib_pathname2url
else:
    # noinspection PyUnresolvedReferences
    from urllib.request import pathname2url as urllib_pathname2url

# noinspection PyUnresolvedReferences
from cpython.version cimport PY_MAJOR_VERSION
# noinspection PyUnresolvedReferences
import weakref

# We should allow multiple string types: str, unicode, bytes.
# PyToCefString() can handle them all.
# Important:
#   If you set it to basestring, Cython will accept exactly(!)
#   str/unicode in Py2 and str in Py3. This won't work in Py3
#   as we might want to pass bytes as well. Also it will
#   reject string subtypes, so using it in publi API functions
#   would be a bad idea.
ctypedef object py_string

# You can't use "void" along with cpdef function returning None, it is planned to be
# added to Cython in the future, creating this virtual type temporarily. If you
# change it later to "void" then don't forget to add "except *".
ctypedef object py_void
ctypedef long long WindowHandle

# noinspection PyUnresolvedReferences
from cpython cimport PyLong_FromVoidPtr
# noinspection PyUnresolvedReferences
from cpython cimport bool as py_bool
# noinspection PyUnresolvedReferences
from libcpp cimport bool as cpp_bool
# noinspection PyUnresolvedReferences
from libcpp.map cimport map as cpp_map
# noinspection PyUnresolvedReferences
from multimap cimport multimap as cpp_multimap
# noinspection PyUnresolvedReferences
from libcpp.pair cimport pair as cpp_pair
# noinspection PyUnresolvedReferences
from libcpp.vector cimport vector as cpp_vector
# noinspection PyUnresolvedReferences
from libcpp.string cimport string as cpp_string
# noinspection PyUnresolvedReferences
from wstring cimport wstring as cpp_wstring
# noinspection PyUnresolvedReferences
from libc.string cimport strlen
# noinspection PyUnresolvedReferences
from libc.string cimport memcpy
# preincrement and dereference must be "as" otherwise not seen.
# noinspection PyUnresolvedReferences
from cython.operator cimport preincrement as preinc, dereference as deref
# noinspection PyUnresolvedReferences

# from cython.operator cimport address as addr # Address of an c++ object?

# noinspection PyUnresolvedReferences
from libc.stdlib cimport calloc, malloc, free
# noinspection PyUnresolvedReferences
from libc.stdlib cimport atoi

# When pyx file cimports * from a pxd file and that pxd cimports * from another pxd
# then these names will be visible in pyx file.

# Circular imports are allowed in form "cimport ...", but won't work if you do
# "from ... cimport *", this is important to know in pxd files.

# noinspection PyUnresolvedReferences
from libc.stdint cimport uint64_t
# noinspection PyUnresolvedReferences
from libc.stdint cimport uintptr_t

# noinspection PyUnresolvedReferences
cimport ctime

IF UNAME_SYSNAME == "Windows":
    from windows cimport *
    from dpi_aware_win cimport *
ELIF UNAME_SYSNAME == "Linux":
    from linux cimport *
ELIF UNAME_SYSNAME == "Darwin":
    from mac cimport *

from cpp_utils cimport *
from task cimport *

from cef_string cimport *
cdef extern from *:
    # noinspection PyUnresolvedReferences
    ctypedef CefString ConstCefString "const CefString"

# cannot cimport *, that would cause name conflicts with constants
# noinspection PyUnresolvedReferences
from cef_types cimport (
    CefSettings, CefBrowserSettings, CefRect, CefPoint,
    CefRequestContextSettings,
    CefKeyEvent, CefMouseEvent, CefScreenInfo,
    PathKey, PK_DIR_EXE, PK_DIR_MODULE,
)

from cef_task cimport *
from cef_platform cimport *
from cef_ptr cimport *
from cef_app cimport *
from cef_browser cimport *
# noinspection PyUnresolvedReferences
cimport cef_browser_static
from cef_client cimport *
from client_handler cimport *
from cef_frame cimport *
from cef_time cimport *
from cef_values cimport *
from cefpython_app cimport *
from cef_process_message cimport *
from cef_web_plugin cimport *
from cef_request_handler cimport *
from cef_request cimport *
from cef_cookie cimport *
from cef_string_visitor cimport *
# noinspection PyUnresolvedReferences
cimport cef_cookie_manager_namespace
from cookie_visitor cimport *
from string_visitor cimport *
from cef_callback cimport *
from cef_response cimport *
from cef_resource_handler cimport *
from resource_handler cimport *
from cef_urlrequest cimport *
from web_request_client cimport *
from cef_command_line cimport *
from cef_request_context cimport *
from cef_request_context_handler cimport *
from request_context_handler cimport *
from cef_jsdialog_handler cimport *
from cef_path_util cimport *
from cef_drag_data cimport *
from cef_image cimport *
from main_message_loop cimport *
from cef_scoped_ptr cimport scoped_ptr


# -----------------------------------------------------------------------------
# GLOBAL VARIABLES

g_debug = False
g_debugFile = "debug.log"

# When put None here and assigned a local dictionary in Initialize(), later
# while running app this global variable was garbage collected, see topic:
# https://groups.google.com/d/topic/cython-users/0dw3UASh7HY/discussion
# The string_encoding key must be set early here and also in Initialize.
g_applicationSettings = {"string_encoding": "utf-8"}
g_commandLineSwitches = {}

cdef scoped_ptr[MainMessageLoopExternalPump] g_external_message_pump

# noinspection PyUnresolvedReferences
cdef cpp_bool _MessageLoopWork_wasused = False

cdef dict g_globalClientCallbacks = {}

# If ApplicationSettings.unique_request_context_per_browser is False
# then a shared request context is used for all browsers. Otherwise
# a unique one is created for each call to CreateBrowserSync.
# noinspection PyUnresolvedReferences
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

IF UNAME_SYSNAME == "Windows":
    include "window_utils_win.pyx"
    include "dpi_aware_win.pyx"
ELIF UNAME_SYSNAME == "Linux":
    include "window_utils_linux.pyx"
ELIF UNAME_SYSNAME == "Darwin":
    include "window_utils_mac.pyx"

include "task.pyx"
include "javascript_bindings.pyx"
include "virtual_keys.pyx"
include "window_info.pyx"
include "process_message_utils.pyx"
include "javascript_callback.pyx"
include "python_callback.pyx"
include "web_plugin_info.pyx"
include "request.pyx"
include "cookie.pyx"
include "string_visitor.pyx"
include "network_error.pyx"
include "paint_buffer.pyx"
include "callback.pyx"
include "response.pyx"
include "web_request.pyx"
include "command_line.pyx"
include "app.pyx"
include "drag_data.pyx"
include "helpers.pyx"
include "image.pyx"

# Handlers
include "handlers/browser_process_handler.pyx"
include "handlers/display_handler.pyx"
include "handlers/focus_handler.pyx"
include "handlers/javascript_dialog_handler.pyx"
include "handlers/keyboard_handler.pyx"
include "handlers/lifespan_handler.pyx"
include "handlers/load_handler.pyx"
include "handlers/render_handler.pyx"
include "handlers/resource_handler.pyx"
include "handlers/request_handler.pyx"
include "handlers/v8context_handler.pyx"
include "handlers/v8function_handler.pyx"

# -----------------------------------------------------------------------------
# Utility functions to provide settings to the C++ browser process code.

cdef public void cefpython_GetDebugOptions(
        cpp_bool* debug,
        cpp_string* debugFile
        ) except * with gil:
    # Called from subprocess/cefpython_app.cpp -> CefPythonApp constructor.
    cdef cpp_string cppString = PyStringToChar(g_debugFile)
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

cdef public cpp_string ApplicationSettings_GetString(const char* key
        ) except * with gil:
    cdef py_string pyKey = CharToPyString(key)
    cdef cpp_string cppString
    if pyKey in g_applicationSettings:
        cppString = PyStringToChar(AnyToPyString(g_applicationSettings[pyKey]))
    return cppString

cdef public int CommandLineSwitches_GetInt(const char* key) except * with gil:
    cdef py_string pyKey = CharToPyString(key)
    if pyKey in g_commandLineSwitches:
        return int(g_commandLineSwitches[pyKey])
    return 0

# -----------------------------------------------------------------------------

# If you've built custom binaries with tcmalloc hook enabled on
# Linux, then do not to run any of the CEF code until Initialize()
# is called. See Issue #73 in the CEF Python Issue Tracker.

def Initialize(applicationSettings=None, commandLineSwitches=None, **kwargs):

    # Alternative names for existing parameters
    if "settings" in kwargs:
        applicationSettings = kwargs["settings"]
    if "switches" in kwargs:
        commandLineSwitches = kwargs["switches"]

    # Fix Issue #231 - Discovery of the "icudtl.dat" file fails on Linux.
    # Apply patch for all platforms just in case.
    cdef str py_module_dir = GetModuleDirectory()
    cdef CefString cef_module_dir
    PyToCefString(py_module_dir, cef_module_dir)
    CefOverridePath(PK_DIR_EXE, cef_module_dir)\
            or Debug("ERROR: CefOverridePath failed")
    CefOverridePath(PK_DIR_MODULE, cef_module_dir)\
            or Debug("ERROR: CefOverridePath failed")

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

    # Mac initialization. Need to call NSApplication.sharedApplication()
    # and do NSApplication methods swizzling to implement
    # CrAppControlProtocol. See Issue 156.
    IF UNAME_SYSNAME == "Darwin":
        MacInitialize()

    # -------------------------------------------------------------------------
    # CEF Python only options - default values

    if "debug" not in applicationSettings:
        applicationSettings["debug"] = False
    if "log_severity" not in applicationSettings:
        # By default show only errors. Don't show on Linux X server non-fatal
        # errors like "WARNING:x11_util.cc(1409)] X error received".
        applicationSettings["log_severity"] = LOGSEVERITY_ERROR
    if "string_encoding" not in applicationSettings:
        applicationSettings["string_encoding"] = "utf-8"
    if "unique_request_context_per_browser" not in applicationSettings:
        applicationSettings["unique_request_context_per_browser"] = False
    if "downloads_enabled" not in applicationSettings:
        applicationSettings["downloads_enabled"] = True
    if "remote_debugging_port" not in applicationSettings:
        applicationSettings["remote_debugging_port"] = 0
    if "auto_zooming" not in applicationSettings:
        IF UNAME_SYSNAME == "Windows":
            if DpiAware.IsProcessDpiAware():
                applicationSettings["auto_zooming"] = "system_dpi"

    # Paths
    cdef str module_dir = GetModuleDirectory()
    if "locales_dir_path" not in applicationSettings:
        if platform.system() != "Darwin":
            applicationSettings["locales_dir_path"] = os.path.join(
                    module_dir, "locales")
    if "resources_dir_path" not in applicationSettings:
        applicationSettings["resources_dir_path"] = module_dir
        if platform.system() == "Darwin":
            applicationSettings["resources_dir_path"] = module_dir+"/Resources"
    if "browser_subprocess_path" not in applicationSettings:
        applicationSettings["browser_subprocess_path"] = os.path.join(
                module_dir, "subprocess")

    # Mouse context menu
    if "context_menu" not in applicationSettings:
        applicationSettings["context_menu"] = {}
    menuItems = ["enabled", "navigation", "print", "view_source",
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
    if not "single_process" in applicationSettings:
        applicationSettings["single_process"] = False

    cdef CefRefPtr[CefApp] cefApp = <CefRefPtr[CefApp]?>new CefPythonApp()

    IF UNAME_SYSNAME == "Windows":
        cdef HINSTANCE hInstance = GetModuleHandle(NULL)
        cdef CefMainArgs cefMainArgs = CefMainArgs(hInstance)
    ELIF UNAME_SYSNAME == "Linux":
        # TODO: use the CefMainArgs(int argc, char** argv) constructor.
        cdef CefMainArgs cefMainArgs
    ELIF UNAME_SYSNAME == "Darwin":
        # TODO: use the CefMainArgs(int argc, char** argv) constructor.
        cdef CefMainArgs cefMainArgs
    cdef int exitCode = 1
    with nogil:
        exitCode = CefExecuteProcess(cefMainArgs, cefApp, NULL)
    Debug("CefExecuteProcess(): exitCode = %s" % exitCode)
    if exitCode >= 0:
        sys.exit(exitCode)

    # Make a copy as applicationSettings is a reference only
    # that might get destroyed later.
    global g_applicationSettings
    for key in applicationSettings:
        g_applicationSettings[key] = copy.deepcopy(applicationSettings[key])

    cdef CefSettings cefApplicationSettings
    # No sandboxing for the subprocesses
    cefApplicationSettings.no_sandbox = 1
    SetApplicationSettings(applicationSettings, &cefApplicationSettings)

    if commandLineSwitches:
        # Make a copy as commandLineSwitches is a reference only
        # that might get destroyed later.
        global g_commandLineSwitches
        for key in commandLineSwitches:
            g_commandLineSwitches[key] = copy.deepcopy(
                    commandLineSwitches[key])

    # External message pump
    if GetAppSetting("external_message_pump")\
            and not g_external_message_pump.get():
        g_external_message_pump.Assign(MainMessageLoopExternalPump.Create())

    Debug("CefInitialize()")
    cdef cpp_bool ret
    with nogil:
        ret = CefInitialize(cefMainArgs, cefApplicationSettings, cefApp, NULL)

    if not ret:
        Debug("CefInitialize() failed")

    IF UNAME_SYSNAME == "Linux":
        # Install by default.
        WindowUtils.InstallX11ErrorHandlers()

    return ret

def CreateBrowser(**kwargs):
    """Create browser asynchronously. TODO. """
    CreateBrowserSync(**kwargs)

def CreateBrowserSync(windowInfo=None,
                      browserSettings=None,
                      navigateUrl="",
                      **kwargs):
    # Alternative names for existing parameters
    if "window_info" in kwargs:
        windowInfo = kwargs["window_info"]
    if "settings" in kwargs:
        browserSettings = kwargs["settings"]
    if "url" in kwargs:
        navigateUrl = kwargs["url"]

    Debug("CreateBrowserSync() called")
    assert IsThread(TID_UI), (
            "cefpython.CreateBrowserSync() may only be called on the UI thread")

    if not windowInfo:
        windowInfo = WindowInfo()
        windowInfo.SetAsChild(0)
    elif not isinstance(windowInfo, WindowInfo):
        raise Exception("CreateBrowserSync() failed: windowInfo: invalid object")

    if not browserSettings:
        browserSettings = {}

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
    cdef CefRequestContextSettings requestContextSettings
    cdef CefRefPtr[CefRequestContext] cefRequestContext
    cdef CefRefPtr[RequestContextHandler] requestContextHandler =\
            <CefRefPtr[RequestContextHandler]?>new RequestContextHandler(
                    cefBrowser)
    if g_applicationSettings["unique_request_context_per_browser"]:
        cefRequestContext = CefRequestContext_CreateContext(
                requestContextSettings,
                <CefRefPtr[CefRequestContextHandler]?>requestContextHandler)
    else:
        if createSharedRequestContext:
            cefRequestContext = CefRequestContext_CreateContext(
                    requestContextSettings,
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

    if not _MessageLoopWork_wasused:
        global _MessageLoopWork_wasused
        _MessageLoopWork_wasused = True

    with nogil:
        CefDoMessageLoopWork()

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

    if len(g_pyBrowsers) and _MessageLoopWork_wasused:
        # There might be a case when python error occured after creating
        # browser, but before any message loop was run. In such case
        # the renderer process won't be terminated unless we run some
        # message loop work here first, try to close browser and free
        # reference, and then run some message loop work again.
        for i in range(10):
            with nogil:
                CefDoMessageLoopWork()
            time.sleep(0.01)
        browsers_list = []
        for browserId in g_pyBrowsers:
            # Cannot close browser here otherwise error:
            # > dictionary changed size during iteration
            browsers_list.append(browserId)
        for browserId in browsers_list:
            browser = GetPyBrowserById(browserId)
            if browser:
                browser.TryCloseBrowser()
            RemovePyBrowser(browserId)
        for i in range(10):
            with nogil:
                CefDoMessageLoopWork()
            time.sleep(0.01)

    if len(g_pyBrowsers):
        Error("Shutdown called, but there are still browser references alive")

    Debug("Shutdown()")
    with nogil:
        # Temporary fix for possible errors on shutdown. See this post:
        # https://magpcss.org/ceforum/viewtopic.php?p=30858#p30858
        # May be fixed by host owned message loop, see Issue 1805:
        # https://bitbucket.org/chromiumembedded/cef/issues/1805/
        if _MessageLoopWork_wasused:
            for i in range(10):
                CefDoMessageLoopWork()
        CefShutdown()
        if _MessageLoopWork_wasused:
            for i in range(10):
                CefDoMessageLoopWork()

    # Release external message pump, as in cefclient after Shutdown
    if g_external_message_pump.get():
        # Reset will set it to NULL
        g_external_message_pump.reset()


def SetOsModalLoop(py_bool modalLoop):
    cdef cpp_bool cefModalLoop = bool(modalLoop)
    with nogil:
        CefSetOSModalLoop(cefModalLoop)

cpdef py_void SetGlobalClientCallback(py_string name, object callback):
    global g_globalClientCallbacks
    if name in ["OnCertificateError", "OnBeforePluginLoad", "OnAfterCreated"]:
        g_globalClientCallbacks[name] = callback
    else:
        raise Exception("SetGlobalClientCallback() failed: "\
                "invalid callback name = %s" % name)

cpdef object GetGlobalClientCallback(py_string name):
    global g_globalClientCallbacks
    if name in g_globalClientCallbacks:
        return g_globalClientCallbacks[name]
    else:
        return None

cpdef object GetAppSetting(py_string key):
    global g_applicationSettings
    if key in g_applicationSettings:
        return g_applicationSettings[key]
    return None
