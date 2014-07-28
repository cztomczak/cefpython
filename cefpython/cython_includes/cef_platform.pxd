# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "compile_time_constants.pxi"

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefWindowHandle, CefCursorHandle, CefKeyInfo, CefWindowInfo
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport *
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport *
