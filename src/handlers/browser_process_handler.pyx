# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"

cdef public void BrowserProcessHandler_OnContextInitialized() noexcept with gil:
    cdef object callback
    try:
        global g_context_initialized
        Debug("BrowserProcessHandler_OnContextInitialized()")
        g_context_initialized = True
        # The CEF context is now ready — this is the earliest point at which a
        # browser may be created (CEF's Chrome runtime initializes the browser
        # context asynchronously; see CreateBrowserSync). Notify the
        # application so it can create its browser here, matching CEF's
        # cefsimple sample.
        callback = GetGlobalClientCallback("OnContextInitialized")
        if callback:
            callback()
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnRenderProcessThreadCreated(
        CefRefPtr[CefListValue] extra_info
        ) noexcept with gil:
    try:
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_OnBeforeChildProcessLaunch(
        CefRefPtr[CefCommandLine] cefCommandLine
        ) noexcept with gil:
    try:
        AppendSwitchesToCommandLine(cefCommandLine, g_commandLineSwitches)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
