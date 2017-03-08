# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "compile_time_constants.pxi"

IF UNAME_SYSNAME == "Windows":
    # noinspection PyUnresolvedReferences
    from cef_win cimport *
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport *
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport *
