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

cpdef object Debug(py_string msg):
    """Print debug message. Will be shown only when settings.debug=True."""
    # In Python 3 str or bytes may be passed
    if type(msg) != str and type(msg) == bytes:
        msg = msg.decode("utf-8", "replace")
    # Convert to str in case other kind of object was passed
    msg = str(msg)
    msg = "[Browser process] " + msg
    # CEF logging is initialized only after CEF was initialized.
    # Otherwise the default is LOGSEVERITY_INFO and log_file is
    # none.
    if g_cef_initialized or g_debug:
        cef_log_info(PyStringToChar(msg))

cdef void NonCriticalError(py_string msg) except *:
    """Notify about error gently. Does not terminate application."""
    # In Python 3 str or bytes may be passed
    if type(msg) != str and type(msg) == bytes:
        msg = msg.decode("utf-8", "replace")
    # Convert to str in case other kind of object was passed
    msg = str(msg)
    msg = "[Browser process] " + msg
    cef_log_error(PyStringToChar(msg))

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
