# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"
include "string_utils.pyx"

# noinspection PyUnresolvedReferences
cimport cef_types

TID_UI = cef_types.TID_UI
TID_FILE_BACKGROUND = cef_types.TID_FILE_BACKGROUND
TID_FILE_USER_VISIBLE = cef_types.TID_FILE_USER_VISIBLE
TID_FILE_USER_BLOCKING = cef_types.TID_FILE_USER_BLOCKING
TID_IO = cef_types.TID_IO
TID_RENDERER = cef_types.TID_RENDERER

g_browserProcessThreads = [
    TID_UI,
    TID_FILE_BACKGROUND,
    TID_FILE_USER_VISIBLE,
    TID_FILE_USER_BLOCKING,
    TID_IO,
]

cpdef py_bool IsString(object maybeString):
    # In Python 2.7 string types are: 1) str/bytes 2) unicode.
    # In Python 3 string types are: 1) bytes 2) str
    if type(maybeString) == bytes or type(maybeString) == str \
            or (PY_MAJOR_VERSION < 3 and type(maybeString) == unicode):
        return True
    return False

cpdef py_bool IsThread(int threadID):
    return bool(CefCurrentlyOn(<CefThreadId>threadID))

# TODO: this function needs to accept unicode strings, use the
#       logic from wxpython.py/ExceptHook to handle printing
#       unicode strings and writing them to file (codecs.open).
#       This change is required to work with Cython 0.20.


cdef str GetLogPrefix(int severity):
    pid = os.getpid()
    if hasattr(threading, "get_native_id"):
        tid = threading.get_native_id()
    else:
        tid = threading.get_ident()
    timestamp = datetime.datetime.now().strftime("%m%d/%H%M%S.%f")
    severity_string = ""
    if severity == LOGSEVERITY_INFO:
        severity_string = "INFO"
    elif severity == LOGSEVERITY_WARNING:
        severity_string = "WARNING"
    elif severity == LOGSEVERITY_ERROR:
        severity_string = "ERROR"
    global g_commandLineSwitches
    if "log-items" in g_commandLineSwitches and g_commandLineSwitches["log-items"] == "none":
        return f"{severity_string}"
    else:
        return f"{pid}:{tid}:{timestamp}:{severity_string}"

cdef bytes GetLogTag():
    if len(sys.argv) and sys.argv[0]:
        return ("cefpython:" + os.path.basename(sys.argv[0])).encode("utf-8")
    return b"cefpython"

cdef object LogMessage(py_string msg, int severity):
    # In Python 3 str or bytes may be passed
    if type(msg) != str and type(msg) == bytes:
        msg = msg.decode("utf-8", "replace")
    # Convert to str in case other kind of object was passed
    msg = str(msg)
    if g_cef_initialized_successfully:
        if (severity == LOGSEVERITY_INFO):
            cef_log_info(GetLogTag(), PyStringToChar(msg))
        elif (severity == LOGSEVERITY_WARNING):
            cef_log_warning(GetLogTag(), PyStringToChar(msg))
        elif (severity == LOGSEVERITY_ERROR):
            cef_log_error(GetLogTag(), PyStringToChar(msg))
    elif g_applicationSettings.get("log_severity", LOGSEVERITY_ERROR) <= severity:
        # CEF logging is not available until CefInitialize() succeeds, and
        # before that Chromium sends messages to its own default destination
        # (a debug.log next to python.exe on Windows). Write to stderr
        # directly so that these messages are not lost (Issue #709).
        if sys.stderr:  # None when run with pythonw.exe
            try:
                tag = GetLogTag().decode("utf-8", "replace")
                sys.stderr.write("[" + GetLogPrefix(severity) + ":" + tag + ":0] " + msg + "\n")
                sys.stderr.flush()
                return
            except (OSError, ValueError):
                # Closed or broken stderr must not break the application.
                pass
        # No usable stderr: fall back to Chromium's default destination,
        # which on Windows is a debug.log next to the executable.
        if (severity == LOGSEVERITY_INFO):
            cef_log_info(GetLogTag(), PyStringToChar(msg))
        elif (severity == LOGSEVERITY_WARNING):
            cef_log_warning(GetLogTag(), PyStringToChar(msg))
        elif (severity == LOGSEVERITY_ERROR):
            cef_log_error(GetLogTag(), PyStringToChar(msg))

cpdef object Debug(py_string msg):
    LogMessage(msg, LOGSEVERITY_INFO)

cpdef object Warning(py_string msg):
    LogMessage(msg, LOGSEVERITY_WARNING)

cpdef object Error(py_string msg):
    LogMessage(msg, LOGSEVERITY_ERROR)

cpdef str GetSystemError():
    IF UNAME_SYSNAME == "Windows":
        cdef DWORD errorCode = GetLastError()
        return "Error Code = %d" % errorCode
    ELSE:
        return ""

cpdef py_bool IsFunctionOrMethod(object valueType):
    if (valueType == types.FunctionType
            or valueType == types.MethodType
            or valueType == types.BuiltinFunctionType
            or valueType == types.BuiltinMethodType
            or valueType.__name__ == "cython_function_or_method"):
        return True
    return False
