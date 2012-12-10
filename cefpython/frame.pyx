# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef dict g_pyFrames = {}

cdef PyFrame GetPyFrame(CefRefPtr[CefFrame] cefFrame):
    global g_pyFrames

    if <void*>cefFrame == NULL or not cefFrame.get():
        Debug("GetPyFrame(): returning None")
        return

    cdef PyFrame pyFrame
    # long long
    cdef object frameId = cefFrame.get().GetIdentifier()

    if frameId in g_pyFrames:
        return g_pyFrames[frameId]

    for id, pyFrame in g_pyFrames.items():
        if not pyFrame.cefFrame.get():
            Debug("GetPyFrame(): removing an empty CefFrame reference, frameId=%s" % id)
            del g_pyFrames[id]

    # Debug("GetPyFrame(): creating new PyFrame, frameId=%s" % frameId)
    pyFrame = PyFrame()
    pyFrame.cefFrame = cefFrame
    g_pyFrames[frameId] = pyFrame
    return pyFrame

cdef class PyFrame:
    cdef CefRefPtr[CefFrame] cefFrame

    cdef CefRefPtr[CefFrame] GetCefFrame(self) except *:
        if <void*>self.cefFrame != NULL and self.cefFrame.get():
            return self.cefFrame
        raise Exception("PyFrame.GetCefFrame() failed: CefFrame was destroyed")

    def __init__(self):
        pass

    cpdef py_void CallFunction(self, funcName, ...):
        pass

    cpdef object CallFunctionSync(self, funcName, ...):
        # CefV8 Objects, Arrays and Functions can be created only inside V8 context,
        # you need to call CefV8Context::Enter() and CefV8Context::Exit():
        # http://code.google.com/p/chromiumembedded/issues/detail?id=203
        # Entering context should be done for Frame::CallFunction().
        # You must check current context and Enter it if not same, before calling
        # PyToV8Value().
        # TODO: call Frame->GetV8Context?()->GetGlobal?() you get a window object,
        # now iterate through its all properties and compare to funcName, you get a
        # real javascript object which you can call and be able to get return value, also
        # you can pass python callbacks this way.'''
        pass

    cpdef py_void Copy(self):
        self.GetCefFrame().get().Copy()

    cpdef py_void Cut(self):
        self.GetCefFrame().get().Cut()

    cpdef py_void Delete(self):
        self.GetCefFrame().get().Delete()

    cpdef py_void ExecuteJavascript(self, py_string jsCode, py_string scriptUrl="",
            int startLine=0):
        cdef CefString cefJsCode

        if bytes == str:
            # Python 2.7
            cefJsCode.FromASCII(<char*>jsCode)
        else:
            # Python 3 requires bytes when converting to char*
            bytesJsCode = jsCode.encode("utf-8")
            cefJsCode.FromASCII(<char*>bytesJsCode)

        if not scriptUrl:
            scriptUrl = ""
        cdef CefString cefScriptUrl
        PyToCefString(scriptUrl, cefScriptUrl)

        if not startLine:
            startLine = -1

        self.GetCefFrame().get().ExecuteJavaScript(cefJsCode, cefScriptUrl, startLine)

    cpdef object EvalJavascript(self):
        # TODO: CefV8Context > Eval
        pass

    cpdef object GetIdentifier(self):
        return self.GetCefFrame().get().GetIdentifier()

    cpdef str GetName(self):

        return CefToPyString(self.GetCefFrame().get().GetName())

    IF CEF_VERSION == 1:

        cpdef object GetProperty(self, py_string name):
            assert IsCurrentThread(TID_UI), (
                    "Frame.GetProperty() may only be called on the UI thread")

            cdef CefRefPtr[CefV8Context] v8Context = self.GetCefFrame().get().GetV8Context()
            cdef CefRefPtr[CefV8Value] window = v8Context.get().GetGlobal()

            cdef CefString cefPropertyName
            PyToCefString(name, cefPropertyName)

            cdef CefRefPtr[CefV8Value] v8Value = window.get().GetValue(cefPropertyName)
            return V8ToPyValue(v8Value, v8Context)

    IF CEF_VERSION == 1:

        cpdef str GetSource(self):
            IF CEF_VERSION == 1:
                assert IsCurrentThread(TID_UI), (
                        "Frame.GetSource() may only be called on the UI thread")
            return CefToPyString(self.GetCefFrame().get().GetSource())

        cpdef str GetText(self):
            IF CEF_VERSION == 1:
                assert IsCurrentThread(TID_UI), (
                        "Frame.GetText() may only be called on the UI thread")
            return CefToPyString(self.GetCefFrame().get().GetText())

    cpdef str GetUrl(self):
        return CefToPyString(self.GetCefFrame().get().GetURL())

    cpdef py_bool IsFocused(self):
        IF CEF_VERSION == 1:
            assert IsCurrentThread(TID_UI), (
                    "Frame.IsFocused() may only be called on the UI thread")
        return self.GetCefFrame().get().IsFocused()

    cpdef py_bool IsMain(self):
        return self.GetCefFrame().get().IsMain()

    cpdef  py_void LoadRequest(self):
        pass

    cpdef py_void LoadString(self, py_string value, py_string url):
        cdef CefString cefValue
        cdef CefString cefUrl
        PyToCefString(value, cefValue)
        PyToCefString(url, cefUrl)
        self.GetCefFrame().get().LoadString(cefValue, cefUrl)

    cpdef py_void LoadUrl(self, py_string url):
        cdef CefString cefUrl
        PyToCefString(url, cefUrl)
        self.GetCefFrame().get().LoadURL(cefUrl)

    cpdef py_void Paste(self):
        self.GetCefFrame().get().Paste()

    IF CEF_VERSION == 1:
        cpdef py_void Print(self):
            self.GetCefFrame().get().Print()

    cpdef py_void Redo(self):
        self.GetCefFrame().get().Redo()

    cpdef py_void SelectAll(self):
        self.GetCefFrame().get().SelectAll()

    IF CEF_VERSION == 1:

        cpdef py_void SetProperty(self, py_string name, object value):
            assert IsCurrentThread(TID_UI), (
                    "Frame.SetProperty() may only be called on the UI thread")

            if not JavascriptBindings.IsValueAllowed(value):
                valueType = JavascriptBindings.__IsValueAllowed(value)
                raise Exception("Frame.SetProperty() failed: name=%s, "
                        "not allowed type: %s (this may be a type of a nested value)"
                        % (name, valueType))

            cdef CefRefPtr[CefV8Context] v8Context = self.GetCefFrame().get().GetV8Context()
            cdef CefRefPtr[CefV8Value] window = v8Context.get().GetGlobal()

            cdef CefString cefPropertyName
            PyToCefString(name, cefPropertyName)

            cdef c_bool sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())
            if not sameContext:
                Debug("Frame.SetProperty(): inside a different context, calling v8Context.Enter()")
                assert v8Context.get().Enter(), "v8Context.Enter() failed"

            window.get().SetValue(
                    cefPropertyName,
                    PyToV8Value(value, v8Context),
                    V8_PROPERTY_ATTRIBUTE_NONE)

            if not sameContext:
                assert v8Context.get().Exit(), "v8Context.Exit() failed"

    cpdef py_void Undo(self):
        self.GetCefFrame().get().Undo()

    cpdef py_void ViewSource(self):
        self.GetCefFrame().get().ViewSource()
