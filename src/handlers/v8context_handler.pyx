# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# In CEF 3 there is no V8ContextHandler, the methods OnContextCreated(),
# OnContextReleased(), OnUncaughtException() are in CefRenderProcessHandler
# and are called in the Renderer process, we use process messaging to
# recreate these events in the Browser process, but the timing will be
# a bit delayed due to asynchronous way this is being done.

include "../cefpython.pyx"
include "../browser.pyx"
include "../frame.pyx"
from libc.stdint cimport int64_t

cdef public void V8ContextHandler_OnContextCreated(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef object clientCallback
    cdef JavascriptBindings jsBindings
    try:
        # These V8 events are reconstructed in the browser process from
        # asynchronous IPC messages sent by the renderer (see note at the top
        # of this file), so a frame from a rapid create -> navigate -> destroy
        # sequence can already be detached by the time we run here, in which
        # case CefFrame::GetBrowser() returns NULL. There is then no browser to
        # bind to or dispatch a callback for, so skipping is the correct thing
        # to do.
        if not cefFrame.get().GetBrowser().get():
            Debug("OnContextCreated: frame has no browser (detached during"
                  " lifecycle transition), skipping")
            return
        pyBrowser = GetPyBrowser(cefBrowser, "OnContextCreated")
        pyBrowser.SetUserData("__v8ContextCreated", True)
        pyFrame = GetPyFrame(cefFrame)
        # Re-send the JS bindings to the renderer. OnContextCreated fires for
        # each new V8 context (page load, navigation, cross-origin navigation
        # under site isolation); a fresh context has none of the previously
        # injected globals, so they must be resent or bindings would be lost
        # after navigation. Do this before the user callback so that any
        # ExecuteJavascript the user issues from OnContextCreated finds its
        # globals already registered when it reaches the renderer (both travel
        # the same IPC channel).
        if pyFrame.IsMain():
            jsBindings = pyBrowser.GetJavascriptBindings()
            if jsBindings:
                jsBindings.Rebind()
        # User defined callback
        clientCallback = pyBrowser.GetClientCallback("OnContextCreated")
        if clientCallback:
            clientCallback(browser=pyBrowser, frame=pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnContextReleased(
        int browserId,
        CefString frameId
        ) noexcept with gil:
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
        if not pyBrowser:
            Debug("OnContextReleased: Browser doesn't exist anymore, id={id}"
                  .format(id=str(browserId)))
            RemovePyFrame(browserId, CefToPyString(frameId))
            return
        pyFrame = GetPyFrameById(browserId, CefToPyString(frameId))
        # Frame may already be destroyed while IPC messaging was executing
        # (Issue #431).
        if pyFrame:
            clientCallback = pyBrowser.GetClientCallback("OnContextReleased")
            if clientCallback:
                clientCallback(browser=pyBrowser, frame=pyFrame)
        RemovePyFrame(browserId, CefToPyString(frameId))
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
