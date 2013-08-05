# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void BrowserProcessHandler_OnRenderProcessThreadCreated(
        CefRefPtr[CefListValue] extra_info
        ) except * with gil:
    global g_debug
    global g_applicationSettings
    cdef py_string logFile
    try:
        logFile = "debug.log"
        if "log_file" in g_applicationSettings:
            logFile = g_applicationSettings["log_file"]
        extra_info.get().SetBool(0, g_debug)
        extra_info.get().SetString(1, PyToCefStringValue(logFile))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
