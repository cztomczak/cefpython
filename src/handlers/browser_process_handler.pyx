# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"

cdef public void BrowserProcessHandler_OnRenderProcessThreadCreated(
        CefRefPtr[CefListValue] extra_info
        ) except * with gil:
    try:
        # Keys 0 and 1 are already set in C++ code - to pass debug options.
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnBeforeChildProcessLaunch(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) except * with gil:
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
        Debug("BrowserProcessHandler_OnBeforeChildProcessLaunch()")
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
