# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef JavascriptCallback CreateJavascriptCallback(int callbackId,
        CefRefPtr[CefBrowser] cefBrowser, object frameId, py_string functionName):
    # frameId is int64
    cdef JavascriptCallback jsCallback = JavascriptCallback()
    jsCallback.callbackId = callbackId
    cdef PyBrowser browser = GetPyBrowser(cefBrowser)
    jsCallback.frame = browser.GetFrameByIdentifier(frameId)
    jsCallback.functionName = functionName
    Debug("Created javascript callback, callbackId=%s, functionName=%s" % \
            (callbackId, functionName))
    return jsCallback

cdef class JavascriptCallback:
    cdef int callbackId
    cdef PyFrame frame
    cdef py_string functionName

    def Call(self, *args):
        # Send process message "ExecuteJavascriptCallback".
        if self.frame:
            browser = self.frame.GetBrowser()
            if browser:
                browser.SendProcessMessage(
                        cef_types.PID_RENDERER,
                        self.frame.GetIdentifier(),
                        "ExecuteJavascriptCallback",
                        [self.callbackId] + list(args))
            else:
                Debug("JavascriptCallback.Call() FAILED: browser not found, " \
                        "callbackId = %s" % self.callbackId)
        else:
            Debug("JavascriptCallback.Call() FAILED: frame not found, " \
                    "callbackId = %s" % self.callbackId)

    def GetFunctionName(self):
        return self.functionName

    def GetName(self):
        # DEPRECATED name.
        return self.GetFunctionName()

    def GetFrame(self):
        return self.frame
