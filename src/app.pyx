# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void App_OnBeforeCommandLineProcessing_BrowserProcess(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) except * with gil:
    global g_commandLineSwitches
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
        Debug("App_OnBeforeCommandLineProcessing_BrowserProcess()")
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
