# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"
include "browser.pyx"

cdef JavascriptCallback CreateJavascriptCallback(int callbackId,
        CefRefPtr[CefBrowser] cefBrowser, py_string frameId,
        py_string functionName):
    Debug("Created javascript callback, callbackId=%s, functionName=%s" % \
            (callbackId, functionName))
    cdef JavascriptCallback jsCallback = JavascriptCallback()
    jsCallback.callbackId = callbackId
    cdef PyBrowser browser = GetPyBrowser(cefBrowser)
    jsCallback.frame = browser.GetFrameByIdentifier(frameId)
    jsCallback.functionName = functionName

    return jsCallback

cdef class JavascriptCallback:
    """A javascript callback object may still live while browser/frame
    are destroyed. Always check frame/browser for None value."""
    cdef int callbackId
    cdef PyFrame frame
    cdef py_string functionName

    def Call(self, *args):
        # Send process message "ExecuteJavascriptCallback".
        if self.frame:
            browser = self.frame.GetBrowser()
            if browser:
                browser.GetMainFrame().SendProcessMessage(
                        cef_types.PID_RENDERER,
                        self.frame.GetIdentifier(),
                        "ExecuteJavascriptCallback",
                        [self.callbackId] + list(args))
            else:
                # This code probably ain't needed
                raise Exception("JavascriptCallback.Call() FAILED: browser"
                                " not found, callbackId = %s"
                                % self.callbackId)
        else:
            # This code probably ain't needed
            raise Exception("JavascriptCallback.Call() FAILED: frame not found"
                            ", callbackId = %s" % self.callbackId)

    def GetFunctionName(self):
        return self.functionName

    def GetName(self):
        """@deprecated."""
        return self.GetFunctionName()

    def GetId(self):
        return self.callbackId

    def GetFrame(self):
        return self.frame
