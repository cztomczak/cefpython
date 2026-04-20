# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"

cdef public void BrowserProcessHandler_OnContextInitialized() noexcept with gil:
    try:
        global g_context_initialized
        Debug("BrowserProcessHandler_OnContextInitialized()")
        g_context_initialized = True
        # Browser creation is handled by BrowserProcessHandler_CreatePendingBrowsers,
        # posted as a separate task in C++ so it runs at the outer message-loop level.
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void BrowserProcessHandler_CreatePendingBrowsers() noexcept with gil:
    try:
        Debug("BrowserProcessHandler_CreatePendingBrowsers()")
        if g_pending_browsers:
            pending = list(g_pending_browsers)
            del g_pending_browsers[:]
            for params in pending:
                CreateBrowserSync(**params)
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
