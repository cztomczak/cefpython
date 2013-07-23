# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# In CEF 3 there is no V8ContextHandler, the methods OnContextCreated(),
# OnContextReleased(), OnUncaughtException() are in CefRenderProcessHandler
# and are called in the Renderer process, we use process messaging to
# recreate these events in the Browser process, but the timing will be
# a bit delayed due to asynchronous way this is being done.

cdef public void V8ContextHandler_OnContextCreated(
        CefRefPtr[CefBrowser] cefBrowser,
        int64 frameIdentifier
        ) except * with gil:
    cdef CefRefPtr[CefFrame] cefFrame = cefBrowser.get().GetFrame(
            frameIdentifier)
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        Debug("V8ContextHandler_OnContextCreated()")
        pyBrowser = GetPyBrowser(cefBrowser)
        pyBrowser.SetUserData("__v8ContextCreated", True)
        pyFrame = GetPyFrame(cefFrame)
        # User defined callback.
        clientCallback = pyBrowser.GetClientCallback("OnContextCreated")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnContextReleased(
        CefRefPtr[CefBrowser] cefBrowser,
        int64 frameIdentifier
        ) except * with gil:
    cdef CefRefPtr[CefFrame] cefFrame = cefBrowser.get().GetFrame(
            frameIdentifier)
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        Debug("V8ContextHandler_OnContextReleased()")
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        # User defined callback.
        clientCallback = pyBrowser.GetClientCallback("OnContextReleased")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
