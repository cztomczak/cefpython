# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

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
#   | RetValue& Assign "operator="(T* p)
#   | object.Assign(T*)
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
# noinspection PyUnresolvedReferences
import struct
# noinspection PyUnresolvedReferences
import base64

# Must use compile-time condition instead of checking sys.version_info.major
# otherwise results in "ImportError: cannot import name urlencode" strange
# error in Python 3.6.
IF PY_MAJOR_VERSION == 2:
    # noinspection PyUnresolvedReferences
    import urlparse
    # noinspection PyUnresolvedReferences
    from urllib import urlencode as urllib_urlencode
    from urllib import quote as urlparse_quote
ELSE:
    # noinspection PyUnresolvedReferences
    from urllib import parse as urlparse
    from urllib.parse import quote as urlparse_quote
    # noinspection PyUnresolvedReferences
    from urllib.parse import urlencode as urllib_urlencode

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

# You can't use "void" along with cpdef function returning None, it is
# planned to be added to Cython in the future, creating this virtual
# type temporarily. If you change it later to "void" then don't forget
# to add "except *".
ctypedef object py_void

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
from libcpp.memory cimport unique_ptr
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
ctypedef uintptr_t WindowHandle

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

IF UNAME_SYSNAME == "Linux":
    cimport x11

from cef_string cimport *
cdef extern from *:
    # noinspection PyUnresolvedReferences
    ctypedef CefString ConstCefString "const CefString"

# cannot cimport *, that would cause name conflicts with constants
# noinspection PyUnresolvedReferences
from cef_types cimport (
    CefSettings, CefBrowserSettings, CefRect, CefSize, CefPoint,
    CefKeyEvent, CefMouseEvent, CefScreenInfo,
    PathKey, PK_DIR_EXE, PK_DIR_MODULE,
    cef_log_severity_t,
)

# noinspection PyUnresolvedReferences
from cef_ptr cimport CefRefPtr

from cef_task cimport *
from cef_platform cimport *
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
# noinspection PyUnresolvedReferences
from cef_views cimport *
from cef_log cimport *
from cef_file_util cimport *

# -----------------------------------------------------------------------------
# GLOBAL VARIABLES

g_debug = False

# When put None here and assigned a local dictionary in Initialize(), later
# while running app this global variable was garbage collected, see topic:
# https://groups.google.com/d/topic/cython-users/0dw3UASh7HY/discussion
# The string_encoding key must be set early here and also in Initialize.
g_applicationSettings = {"string_encoding": "utf-8"}
g_commandLineSwitches = {}
g_browser_settings = {}

# If ApplicationSettings.unique_request_context_per_browser is False
# then a shared request context is used for all browsers. Otherwise
# a unique one is created for each call to CreateBrowserSync.
# noinspection PyUnresolvedReferences
cdef CefRefPtr[CefRequestContext] g_shared_request_context

cdef unique_ptr[MainMessageLoopExternalPump] g_external_message_pump

cdef py_bool g_MessageLoop_called = False
cdef py_bool g_MessageLoopWork_called = False
cdef py_bool g_cef_initialized = False

cdef dict g_globalClientCallbacks = {}

# -----------------------------------------------------------------------------

include "cef_types.pyx"
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
include "handlers/accessibility_handler.pyx"
include "handlers/browser_process_handler.pyx"
include "handlers/cookie_access_filter.pyx"
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
        cpp_bool* debug
        ) except * with gil:
    # Called from subprocess/cefpython_app.cpp -> CefPythonApp constructor.
    try:
        debug[0] = <cpp_bool>bool(g_debug)
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
    # applicationSettings and commandLineSwitches argument
    # names are kept for backward compatibility.
    application_settings = applicationSettings
    command_line_switches = commandLineSwitches

    # Alternative names for existing parameters
    if "settings" in kwargs:
        assert not applicationSettings, "Bad arguments"
        application_settings = kwargs["settings"]
        del kwargs["settings"]
    if "switches" in kwargs:
        assert not command_line_switches, "Bad arguments"
        command_line_switches = kwargs["switches"]
        del kwargs["switches"]
    for kwarg in kwargs:
        raise Exception("Invalid argument: "+kwarg)

    if command_line_switches:
        # Make a copy as commandLineSwitches is a reference only
        # that might get destroyed later.
        global g_commandLineSwitches
        for key in command_line_switches:
            g_commandLineSwitches[key] = copy.deepcopy(
                    command_line_switches[key])
    # Use g_commandLineSwitches if you need to modify or access
    # command line switches inside this function.
    del command_line_switches
    del commandLineSwitches

    IF UNAME_SYSNAME == "Linux":
        # Fix Issue #231 - Discovery of the "icudtl.dat" file fails on Linux.
        cdef str py_module_dir = GetModuleDirectory()
        cdef CefString cef_module_dir
        PyToCefString(py_module_dir, cef_module_dir)
        CefOverridePath(PK_DIR_EXE, cef_module_dir)\
                or Debug("ERROR: CefOverridePath failed")
        CefOverridePath(PK_DIR_MODULE, cef_module_dir)\
                or Debug("ERROR: CefOverridePath failed")
    # END IF UNAME_SYSNAME == "Linux":

    if not application_settings:
        application_settings = {}

    # Debug settings need to be set before Debug() is called
    # and before the CefPythonApp class is instantiated.
    global g_debug
    if "--debug" in sys.argv:
        application_settings["debug"] = True
        application_settings["log_file"] = os.path.join(os.getcwd(),
                                                        "debug.log")
        application_settings["log_severity"] = LOGSEVERITY_INFO
        sys.argv.remove("--debug")
    if "debug" in application_settings:
        g_debug = bool(application_settings["debug"])
    if "log_severity" in application_settings:
        if application_settings["log_severity"] <= LOGSEVERITY_INFO:
            g_debug = True

    Debug("Initialize() called")

    # Additional initialization on Mac, see util_mac.mm.
    IF UNAME_SYSNAME == "Darwin":
        MacInitialize()

    # ------------------------------------------------------------------------
    # CEF Python only options
    # ------------------------------------------------------------------------

    if "debug" not in application_settings:
        application_settings["debug"] = False
    if "log_severity" not in application_settings:
        # By default show only errors. Don't show on Linux X server non-fatal
        # errors like "WARNING:x11_util.cc(1409)] X error received".
        application_settings["log_severity"] = LOGSEVERITY_ERROR
    if "string_encoding" not in application_settings:
        application_settings["string_encoding"] = "utf-8"
    if "unique_request_context_per_browser" not in application_settings:
        application_settings["unique_request_context_per_browser"] = False
    if "downloads_enabled" not in application_settings:
        application_settings["downloads_enabled"] = True
    if "remote_debugging_port" not in application_settings:
        application_settings["remote_debugging_port"] = 0
    if "app_user_model_id" in application_settings:
        g_commandLineSwitches["app-user-model-id"] =\
                application_settings["app_user_model_id"]

    # ------------------------------------------------------------------------
    # Paths
    # ------------------------------------------------------------------------
    cdef str module_dir = GetModuleDirectory()
    if platform.system() == "Darwin":
        if  "framework_dir_path" not in application_settings:
            application_settings["framework_dir_path"] = os.path.join(
                    module_dir, "Chromium Embedded Framework.framework")
    if "locales_dir_path" not in application_settings:
        if platform.system() != "Darwin":
            application_settings["locales_dir_path"] = os.path.join(
                    module_dir, "locales")
    if "resources_dir_path" not in application_settings:
        application_settings["resources_dir_path"] = module_dir
        if platform.system() == "Darwin":
            # "framework_dir_path" will always be set, see code above.
            application_settings["resources_dir_path"] = os.path.join(
                    application_settings["framework_dir_path"],
                    "Resources")
    if "browser_subprocess_path" not in application_settings:
        application_settings["browser_subprocess_path"] = os.path.join(
                module_dir, "subprocess")

    # ------------------------------------------------------------------------
    # Mouse context menu
    # ------------------------------------------------------------------------
    if "context_menu" not in application_settings:
        application_settings["context_menu"] = {}
    menuItems = ["enabled", "navigation", "print", "view_source",
            "external_browser", "devtools"]
    for item in menuItems:
        if item not in application_settings["context_menu"]:
            application_settings["context_menu"][item] = True

    # ------------------------------------------------------------------------
    # Remote debugging port.
    # ------------------------------------------------------------------------
    # If value is 0 we will generate a random port. To disable
    # remote debugging set value to -1.
    if application_settings["remote_debugging_port"] == 0:
        # Generate a random port.
        application_settings["remote_debugging_port"] =\
                random.randint(49152, 65535)
    elif application_settings["remote_debugging_port"] == -1:
        # Disable remote debugging
        application_settings["remote_debugging_port"] = 0

    # ------------------------------------------------------------------------
    # CEF options - default values
    # ------------------------------------------------------------------------
    if not "multi_threaded_message_loop" in application_settings:
        application_settings["multi_threaded_message_loop"] = False
    # ------------------------------------------------------------------------

    # ------------------------------------------------------------------------
    # Fix GPUCache/ folder creation when using in-memory cache (Issue #419)
    # ------------------------------------------------------------------------
    if not "cache_path" in application_settings:
        application_settings["cache_path"] = ""
    if not application_settings["cache_path"]:
        g_commandLineSwitches["disable-gpu-shader-disk-cache"] = ""

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

    # NOTE: CefExecuteProcess shall not be called here. It should
    #       be called only in the subprocess main.cpp.

    # Make a copy as applicationSettings is a reference only
    # that might get destroyed later.
    global g_applicationSettings
    for key in application_settings:
        g_applicationSettings[key] = copy.deepcopy(application_settings[key])

    cdef CefSettings cefApplicationSettings
    # No sandboxing for the subprocesses
    cefApplicationSettings.no_sandbox = 1
    SetApplicationSettings(application_settings, &cefApplicationSettings)

    # External message pump
    if GetAppSetting("external_message_pump")\
            and not g_external_message_pump.get():
        Debug("Create external message pump")
        global g_external_message_pump
        # Using .reset() here to assign new instance was causing
        # MainMessageLoopExternalPump destructor to be called. Strange.
        g_external_message_pump = MainMessageLoopExternalPump.Create()

    Debug("CefInitialize()")
    cdef cpp_bool ret
    with nogil:
        ret = CefInitialize(cefMainArgs, cefApplicationSettings, cefApp, NULL)

    global g_cef_initialized
    g_cef_initialized = True

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
                      window_title="",
                      **kwargs):
    # Alternative names for existing parameters
    if "window_info" in kwargs:
        windowInfo = kwargs["window_info"]
        del kwargs["window_info"]
    if "settings" in kwargs:
        browserSettings = kwargs["settings"]
        del kwargs["settings"]
    if "url" in kwargs:
        navigateUrl = kwargs["url"]
        del kwargs["url"]
    for kwarg in kwargs:
        raise Exception("Invalid argument: "+kwarg)

    Debug("CreateBrowserSync() called")
    assert IsThread(TID_UI), (
            "cefpython.CreateBrowserSync() may only be called on the UI thread")

    """
    # CEF views
    # noinspection PyUnresolvedReferences
    cdef CefRefPtr[CefWindow] cef_window
    # noinspection PyUnresolvedReferences
    cdef CefRefPtr[CefBoxLayout] cef_box_layout
    cdef CefBoxLayoutSettings cef_box_layout_settings
    cdef CefRefPtr[CefPanel] cef_panel
    if not windowInfo and browserSettings \
            and "window_title" in browserSettings:
        # noinspection PyUnresolvedReferences
        cef_window = CefWindow.CreateTopLevelWindow(
                <CefRefPtr[CefWindowDelegate]?>NULL)
        Debug("CefWindow.GetChildViewCount = "
              +str(cef_window.get().GetChildViewCount()))

        cef_window.get().CenterWindow(CefSize(800, 600))
        cef_window.get().SetBounds(CefRect(0, 0, 800, 600))
        # noinspection PyUnresolvedReferences
        #cef_box_layout = cef_window.get().SetToBoxLayout(
        #        cef_box_layout_settings)
        #cef_box_layout.get().SetFlexForView(cef_window, 1)
        cef_window.get().SetToFillLayout()
        # noinspection PyUnresolvedReferences
        cef_panel = CefPanel.CreatePanel(<CefRefPtr[CefPanelDelegate]?>NULL)
        cef_window.get().AddChildView(cef_panel)
        cef_window.get().Layout()
        cef_window.get().SetVisible(True)
        cef_window.get().Show()
        cef_window.get().RequestFocus()
        windowInfo = WindowInfo()
        windowInfo.SetAsChild(cef_window.get().GetWindowHandle())
        Debug("CefWindow handle = "
              +str(<uintptr_t>cef_window.get().GetWindowHandle()))
    """

    # Only title was set in hello_world.py example
    if windowInfo and not windowInfo.windowType:
        windowInfo.SetAsChild(0)

    # No window info provided
    if not windowInfo:
        windowInfo = WindowInfo()
        windowInfo.SetAsChild(0)
    elif not isinstance(windowInfo, WindowInfo):
        raise Exception("CreateBrowserSync() failed: windowInfo: invalid object")

    if window_title and windowInfo.parentWindowHandle == 0:
        windowInfo.windowName = window_title

    # Browser settings
    if not browserSettings:
        browserSettings = {}
    # CEF Python only settings
    if "inherit_client_handlers_for_popups" not in browserSettings:
        browserSettings["inherit_client_handlers_for_popups"] = True
    cdef CefBrowserSettings cefBrowserSettings
    SetBrowserSettings(browserSettings, &cefBrowserSettings)

    cdef CefWindowInfo cefWindowInfo
    SetCefWindowInfo(cefWindowInfo, windowInfo)

    cdef CefString cefNavigateUrl
    PyToCefString(navigateUrl, cefNavigateUrl)

    Debug("CefBrowser::CreateBrowserSync()")
    cdef CefRefPtr[ClientHandler] clientHandler =\
            <CefRefPtr[ClientHandler]?>new ClientHandler()
    cdef CefRefPtr[CefBrowser] cefBrowser

    # Request context - part 1/2.
    createSharedRequestContext = bool(not g_shared_request_context.get())
    cdef CefRefPtr[CefRequestContext] cefRequestContext
    cdef CefRefPtr[RequestContextHandler] requestContextHandler =\
            <CefRefPtr[RequestContextHandler]?>new RequestContextHandler(
                    cefBrowser)
    if g_applicationSettings["unique_request_context_per_browser"]:
        cefRequestContext = CefRequestContext.CreateContext(
                CefRequestContext.GetGlobalContext(),
                <CefRefPtr[CefRequestContextHandler]?>requestContextHandler)
    elif createSharedRequestContext:
        cefRequestContext = CefRequestContext.CreateContext(
                CefRequestContext.GetGlobalContext(),
                <CefRefPtr[CefRequestContextHandler]?>requestContextHandler)
        g_shared_request_context.Assign(cefRequestContext.get())
    else:
        cefRequestContext.Assign(g_shared_request_context.get())

    cdef CefRefPtr[CefDictionaryValue] extra_info

    # CEF browser creation.
    with nogil:
        cefBrowser = cef_browser_static.CreateBrowserSync(
                cefWindowInfo, <CefRefPtr[CefClient]?>clientHandler,
                cefNavigateUrl, cefBrowserSettings, extra_info,
                cefRequestContext)

    if not cefBrowser or not cefBrowser.get():
        Debug("CefBrowser::CreateBrowserSync() failed")
        return None
    else:
        Debug("CefBrowser::CreateBrowserSync() succeeded")

    Debug("CefBrowser window handle = "
          +str(<uintptr_t>cefBrowser.get().GetHost().get().GetWindowHandle()))

    # Make a copy as browserSettings is a reference only that might
    # get destroyed later.
    global g_browser_settings
    cdef int browser_id = cefBrowser.get().GetIdentifier()
    g_browser_settings[browser_id] = {}
    for key in browserSettings:
        g_browser_settings[browser_id][key] =\
            copy.deepcopy(browserSettings[key])

    # Request context - part 2/2.
    if g_applicationSettings["unique_request_context_per_browser"]:
        requestContextHandler.get().SetBrowser(cefBrowser)
    else:
        if createSharedRequestContext:
            requestContextHandler.get().SetBrowser(cefBrowser)

    cdef PyBrowser pyBrowser = GetPyBrowser(cefBrowser)
    pyBrowser.SetUserData("__outerWindowHandle",
                          int(windowInfo.parentWindowHandle))

    """
    if cef_window.get():
        cef_window.get().ReorderChildView(cef_panel, -1)
        cef_window.get().Layout()
        cef_window.get().Show()
        cef_window.get().RequestFocus()
    """

    if windowInfo.parentWindowHandle == 0\
            and windowInfo.windowType == "child"\
            and windowInfo.windowName:
        # Set window title in hello_world.py example
        IF UNAME_SYSNAME == "Linux":
            x11.SetX11WindowTitle(cefBrowser,
                                  PyStringToChar(windowInfo.windowName))
        ELIF UNAME_SYSNAME == "Darwin":
            MacSetWindowTitle(cefBrowser,
                              PyStringToChar(windowInfo.windowName))

    return pyBrowser

def MessageLoop():
    Debug("MessageLoop()")

    if not g_MessageLoop_called:
        global g_MessageLoop_called
        g_MessageLoop_called = True

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

    if not g_MessageLoopWork_called:
        global g_MessageLoopWork_called
        g_MessageLoopWork_called = True

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
    Debug("Shutdown()")

    # Run some message loop work, force closing browsers and then run
    # some message loop work again for the browsers to close cleanly.
    #
    # UPDATE: This code needs to be rechecked. There were enhancements
    #         to unrferencing globally stored Browser objects in
    #         g_pyBrowsers. See Issue #330 and its commits.
    #
    # CASE 1:
    # There might be a case when python error occured after creating
    # browser, but before any message loop was run. In such case
    # the renderer process won't be terminated unless we run some
    # message loop work here first, close browser and free
    # reference, and then run some message loop work again.
    #
    # CASE 2:
    # Application closes browser and then calls CEF shutdown. We need
    # to run some message loop work so that browser can close cleanly.
    # Looks like running message loop work is also required when
    # application runs MessageLoop() (Issue #282 and the hello_world.py
    # example).
    #
    # CASE 3:
    # Run some message loop work to fix possible errors on shutdown.
    # See this post:
    # >> https://magpcss.org/ceforum/viewtopic.php?p=30858#p30858
    # May be fixed by host owned message loop, see Issue 1805:
    # >> https://bitbucket.org/chromiumembedded/cef/issues/1805/

    # This 0.2 sec message loop work should close browsers and clean
    # CEF references. Even when CloseBrowser(True) wasn't called
    # in client app, then this code below should close it cleanly.
    # Looks like CEF detects that parent window was destroyed
    # and closes browser automatically if you give it some time.
    # If the time was not enough, then there is an emergency plan,
    # the code block further down that checks len(g_pyBrowsers).
    for _ in range(20):
        for __ in range(10):
            with nogil:
                CefDoMessageLoopWork()
        time.sleep(0.01)

    # Emergency plan in case the code above didn't close browsers,
    # and neither browsers were closed in client app. This code
    # will force closing browsers by calling CloseBrowser(True)
    # and then free global g_pyBrowsers list that keeps CEF
    # references alive.
    if len(g_pyBrowsers):
        browsers_list = []
        for browserId in g_pyBrowsers:
            # Cannot close browser here otherwise error:
            # > dictionary changed size during iteration
            browsers_list.append(browserId)
        browser_close_forced = False
        for browserId in browsers_list:
            browser = GetPyBrowserById(browserId)
            if browser and browserId not in g_closed_browsers:
                Debug("WARNING: Browser was not closed with CloseBrowser call."
                      " Will close it safely now, but this will delay CEF"
                      " shutdown by 0.2 sec.")
                browser.CloseBrowser(True)
                browser_close_forced = True
            browser = None  # free reference
            RemovePyBrowser(browserId)
        if browser_close_forced:
            for _ in range(20):
                for __ in range(10):
                    with nogil:
                        CefDoMessageLoopWork()
                time.sleep(0.01)
        # Message loop work was run, so handlers callbacks might got called
        # and browsers might still be in g_pyBrowsers.
        for browserId in browsers_list:
            if browserId in g_pyBrowsers:
                RemovePyBrowser(browserId)

    # If the the two code blocks above, that tried to close browsers
    # and free CEF references, failed, then display an error about it!
    if len(g_pyBrowsers):
        NonCriticalError("Shutdown called, but there are still browser"
                         " references alive")

    # Release shared request context. In the past this was sometimes
    # causing segmentation fault. See Issue #333:
    # https://github.com/cztomczak/cefpython/issues/333
    # Debug("Free g_shared_request_context")
    # g_shared_request_context.Assign(NULL)

    # Release external message pump before CefShutdown, so that
    # message pump timer is killed.
    if g_external_message_pump.get():
        Debug("Reset external message pump")
        # Reset will set it to NULL
        g_external_message_pump.reset()

    Debug("CefShutdown()")
    with nogil:
        CefShutdown()

    # Additional cleanup on Mac, see util_mac.mm.
    IF UNAME_SYSNAME == "Darwin":
        MacShutdown()

def SetOsModalLoop(py_bool modalLoop):
    cdef cpp_bool cefModalLoop = bool(modalLoop)
    with nogil:
        CefSetOSModalLoop(cefModalLoop)

cpdef py_void SetGlobalClientCallback(py_string name, object callback):
    global g_globalClientCallbacks
    # Global callbacks are prefixed with "_" in documentation.
    # Accept both with and without a prefix.
    if name.startswith("_"):
        name = name[1:]
    if name in ["OnCertificateError", "OnAfterCreated",
                "OnAccessibilityTreeChange", "OnAccessibilityLocationChange"]:
        g_globalClientCallbacks[name] = callback
    else:
        raise Exception("SetGlobalClientCallback() failed: "\
                "invalid callback name = %s" % name)

cpdef py_void SetGlobalClientHandler(object clientHandler):
    if not hasattr(clientHandler, "__class__"):
        raise Exception("SetGlobalClientHandler() failed: __class__ "
                        "attribute missing")
    cdef dict methods = {}
    cdef py_string key
    cdef object method
    cdef tuple value
    for value in inspect.getmembers(clientHandler,
            predicate=inspect.ismethod):
        key = value[0]
        method = value[1]
        if key and key[0:2] != '__':
            SetGlobalClientCallback(key, method)

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

cpdef dict GetVersion():
    # These variable are set when building the module.
    # noinspection PyUnresolvedReferences
    return dict(
        version=__version__,
        chrome_version=__chrome_version__,
        cef_version=__cef_version__,
        cef_api_hash_platform=__cef_api_hash_platform__,
        cef_api_hash_universal=__cef_api_hash_universal__,
        cef_commit_hash=__cef_commit_hash__,
        cef_commit_number=__cef_commit_number__,
    )

cpdef LoadCrlSetsFile(py_string path):
    CefLoadCRLSetsFile(PyToCefStringValue(path))

cpdef GetDataUrl(data, mediatype="html"):
    if PY_MAJOR_VERSION >= 3:
        data = data.encode("utf-8", "replace")
    b64 = base64.b64encode(data).decode("utf-8", "replace")
    ret = "data:text/html;base64,{data}".format(data=b64)
    return ret
