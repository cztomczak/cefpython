# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef public void App_OnBeforeCommandLineProcessing_BrowserProcess(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) except * with gil:
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
        Debug("App_OnBeforeCommandLineProcessing_BrowserProcess()")
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
