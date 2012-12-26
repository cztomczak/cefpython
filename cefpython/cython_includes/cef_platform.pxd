# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport *
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport *
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport *
