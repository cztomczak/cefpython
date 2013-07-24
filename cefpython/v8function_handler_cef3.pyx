# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public void V8FunctionHandler_Execute(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefString& cefFuncName,
        CefRefPtr[CefListValue] cefArguments
        ) except * with gil:
    Debug("V8FunctionHandler_Execute()")
    pass
