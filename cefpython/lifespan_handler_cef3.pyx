# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void LifespanHandler_OnBeforeClose(
        CefRefPtr[CefBrowser] cefBrowser
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnBeforeClose")
        if callback:
            callback(pyBrowser)
        RemovePythonCallbacksForBrowser(pyBrowser.GetIdentifier())
        RemovePyFramesForBrowser(pyBrowser.GetIdentifier())
        RemovePyBrowser(pyBrowser.GetIdentifier())
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
