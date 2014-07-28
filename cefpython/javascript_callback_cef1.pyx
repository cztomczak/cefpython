# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef cpp_map[int, CefRefPtr[CefV8Value]] g_v8JavascriptCallbacks
cdef cpp_map[int, CefRefPtr[CefV8Context]] g_v8JavascriptCallbackContexts
# Next callbackId.
cdef int g_v8JavascriptCallbackCount = 0

cdef int PutV8JavascriptCallback(
        CefRefPtr[CefV8Value] v8Value,
        CefRefPtr[CefV8Context] v8Context) except *:
    global g_v8JavascriptCallbacks
    global g_v8JavascriptCallbackContexts
    global g_v8JavascriptCallbackCount
    g_v8JavascriptCallbackCount += 1
    cdef int callbackId = g_v8JavascriptCallbackCount
    g_v8JavascriptCallbacks[callbackId] = v8Value
    g_v8JavascriptCallbackContexts[callbackId] = v8Context
    return callbackId

cdef CefRefPtr[CefV8Value] GetV8JavascriptCallback(
        int callbackId) except *:
    global g_v8JavascriptCallbacks
    if g_v8JavascriptCallbacks.find(callbackId) == g_v8JavascriptCallbacks.end():
        raise Exception("GetV8JavascriptCallback() failed: invalid callbackId: %s"
                % callbackId)
    return g_v8JavascriptCallbacks[callbackId]

cdef CefRefPtr[CefV8Context] GetV8JavascriptCallbackContext(
        int callbackId) except *:
    global g_v8JavascriptCallbackContexts
    if g_v8JavascriptCallbackContexts.find(callbackId) == g_v8JavascriptCallbackContexts.end():
        raise Exception("GetV8JavascriptCallbackContext() failed: invalid callbackId: %s"
                % callbackId)
    return g_v8JavascriptCallbackContexts[callbackId]

cdef void DelV8JavascriptCallback(
        int callbackId) except *:
    global g_v8JavascriptCallbacks
    global g_v8JavascriptCallbackContexts
    g_v8JavascriptCallbacks.erase(callbackId)
    g_v8JavascriptCallbackContexts.erase(callbackId)

cdef class JavascriptCallback:
    cdef int callbackId

    def __init__(self, int callbackId):
        assert callbackId, "JavascriptCallback.__init__() failed: callbackId is empty"
        self.callbackId = callbackId

    def __dealloc__(self):
        DelV8JavascriptCallback(self.callbackId)

    def Call(self, *args):
        cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.callbackId)
        cdef CefRefPtr[CefV8Context] v8Context = GetV8JavascriptCallbackContext(self.callbackId)
        cdef CefV8ValueList v8Arguments
        cdef CefRefPtr[CefV8Value] v8Retval
        cdef CefRefPtr[CefV8Exception] v8Exception
        cdef CefV8Exception* v8ExceptionPtr
        cdef int i

        # Javascript callback may be kept somewhere and later called from
        # a different v8 frame context. Need to enter js v8 context before
        # calling PyToV8Value().

        cdef cpp_bool sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())

        if not sameContext:
            Debug("JavascriptCallback.Call(): inside a different context, calling v8Context.Enter()")
            assert v8Context.get().Enter(), "v8Context.Enter() failed"

        for i in range(0, len(args)):
            v8Arguments.push_back(PyToV8Value(args[i], v8Context))

        if not sameContext:
            assert v8Context.get().Exit(), "v8Context.Exit() failed"

        v8Retval = v8Value.get().ExecuteFunctionWithContext(
                v8Context,
                <CefRefPtr[CefV8Value]>NULL,
                v8Arguments)

        cdef int lineNumber
        cdef str message
        cdef str scriptResourceName
        cdef str sourceLine
        cdef str stackTrace

        # This exception should be first caught by V8ContextHandler::OnUncaughtException().
        if v8Value.get().HasException():
            v8Exception = v8Value.get().GetException()
            v8ExceptionPtr = v8Exception.get()
            lineNumber = v8ExceptionPtr.GetLineNumber()
            message = CefToPyString(v8ExceptionPtr.GetMessage())
            scriptResourceName = CefToPyString(v8ExceptionPtr.GetScriptResourceName())
            sourceLine = CefToPyString(v8ExceptionPtr.GetSourceLine())
            stackTrace = FormatJavascriptStackTrace(GetJavascriptStackTrace(100))

            # TODO: throw exceptions according to execution context (Issue 11),
            # TODO: should we call v8ExceptionPtr.ClearException()? What if python
            # code does try: except: to catch the exception below, if it's catched then
            # js should execute further, like it never happened, and is ClearException()
            # for that?

            raise Exception("JavascriptCallback.Call() failed: javascript exception:\n"
                    "%s.\nOn line %s in %s.\n"
                    "Source of that line: %s\n\n%s"
                    % (message, lineNumber, scriptResourceName, sourceLine, stackTrace))

        if <void*>v8Retval == NULL:
            raise Exception("JavascriptCallback.Call() failed: ExecuteFunctionWithContext() "
                    "called incorrectly")

        pyRet = V8ToPyValue(v8Retval, v8Context)
        return pyRet

    def GetName(self):
        cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.callbackId)
        cdef CefString cefFuncName
        cefFuncName = v8Value.get().GetFunctionName()
        return CefToPyString(cefFuncName)
