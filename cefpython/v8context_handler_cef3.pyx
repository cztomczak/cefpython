# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# In CEF 3 there is no V8ContextHandler, the methods OnContextCreated(),
# OnContextReleased(), OnUncaughtException() are in CefRenderProcessHandler
# and are called in the Renderer process, we use process messaging to
# recreate these events in the Browser process, but the timing will be
# a bit delayed due to asynchronous way this is being done.

cdef public void V8ContextHandler_OnContextCreated(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame
        ) except * with gil:
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
        int browserId,
        int64 frameId
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    try:
        # Due to multi-process architecture in CEF 3, this function won't
        # get called for the main frame in main browser. To send a message
        # from the renderer process a parent browser is used. If this was
        # a main frame then this would mean that the browser is being 
        # destroyed, thus we can't send a process message using this browser.
        # There is no guarantee that this will get called for frames in the
        # main browser, if the browser is destroyed shortly after the frames
        # were released.
        Debug("V8ContextHandler_OnContextReleased()")
        pyBrowser = GetPyBrowserById(browserId)
        pyFrame = GetPyFrameById(browserId, frameId)
        if pyBrowser and pyFrame:
            clientCallback = pyBrowser.GetClientCallback("OnContextReleased")
            if clientCallback:
                clientCallback(pyBrowser, pyFrame)
        else:
            if not pyBrowser:
                Debug("V8ContextHandler_OnContextReleased() WARNING: " \
                        "pyBrowser not found")
            if not pyFrame:
                Debug("V8ContextHandler_OnContextReleased() WARNING: " \
                        "pyFrame not found")
        RemovePyFrame(browserId, frameId)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
