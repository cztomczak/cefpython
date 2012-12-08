# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef c_map[int, CefRefPtr[CefV8Value]] g_v8JavascriptCallbacks
cdef c_map[int, CefRefPtr[CefV8Context]] g_v8JavascriptCallbackContexts
cdef int g_v8JavascriptCallbackCount = 0 # next callbackID

cdef int PutV8JavascriptCallback(CefRefPtr[CefV8Value] v8Value, CefRefPtr[CefV8Context] v8Context) except *:

    global g_v8JavascriptCallbacks
    global g_v8JavascriptCallbackContexts
    global g_v8JavascriptCallbackCount
    g_v8JavascriptCallbackCount += 1
    cdef int callbackID = g_v8JavascriptCallbackCount
    g_v8JavascriptCallbacks[callbackID] = v8Value
    g_v8JavascriptCallbackContexts[callbackID] = v8Context
    return callbackID

cdef CefRefPtr[CefV8Value] GetV8JavascriptCallback(int callbackID) except *:

    global g_v8JavascriptCallbacks
    if g_v8JavascriptCallbacks.find(callbackID) == g_v8JavascriptCallbacks.end():
        raise Exception("GetV8JavascriptCallback() failed: invalid callbackID: %s" % callbackID)
    return g_v8JavascriptCallbacks[callbackID]

cdef CefRefPtr[CefV8Context] GetV8JavascriptCallbackContext(int callbackID) except *:

    global g_v8JavascriptCallbackContexts
    if g_v8JavascriptCallbackContexts.find(callbackID) == g_v8JavascriptCallbackContexts.end():
        raise Exception("GetV8JavascriptCallbackContext() failed: invalid callbackID: %s" % callbackID)
    return g_v8JavascriptCallbackContexts[callbackID]

cdef void DelV8JavascriptCallback(int callbackID) except *:

    global g_v8JavascriptCallbacks
    global g_v8JavascriptCallbackContexts
    g_v8JavascriptCallbacks.erase(callbackID)
    g_v8JavascriptCallbackContexts.erase(callbackID)

class JavascriptCallback:

    __callbackID = None # an int

    def __init__(self, callbackID):

        assert callbackID, "JavascriptCallback.__init__() failed: callbackID is empty"
        self.__callbackID = callbackID

    def __del__(self):

        DelV8JavascriptCallback(self.__callbackID)

    def Call(self, *args):

        cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.__callbackID)
        cdef CefRefPtr[CefV8Context] v8Context = GetV8JavascriptCallbackContext(self.__callbackID)
        cdef CefV8ValueList v8Arguments
        cdef CefRefPtr[CefV8Value] v8Retval
        cdef CefRefPtr[CefV8Exception] v8Exception
        cdef CefV8Exception* v8ExceptionPtr

        # Javascript callback may be kept somewhere and later called from a different v8 frame context.
        # Need to enter js v8 context before calling PyValueToV8Value().

        cdef c_bool sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())

        if not sameContext:
            Debug("JavascriptCallback.Call(): inside a different context, calling v8Context.Enter()")
            assert v8Context.get().Enter(), "v8Context.Enter() failed"

        for i in range(0, len(args)):
            v8Arguments.push_back(PyValueToV8Value(args[i], v8Context))

        if not sameContext:
            assert v8Context.get().Exit(), "v8Context.Exit() failed"

        v8Retval = v8Value.get().ExecuteFunctionWithContext(v8Context, <CefRefPtr[CefV8Value]>NULL, v8Arguments)

        # This exception should be first caught by V8ContextHandler::OnUncaughtException().

        if v8Value.get().HasException():

            v8Exception = v8Value.get().GetException()
            v8ExceptionPtr = v8Exception.get()
            lineNumber = v8ExceptionPtr.GetLineNumber()
            message = ToPyString(v8ExceptionPtr.GetMessage())
            scriptResourceName = ToPyString(v8ExceptionPtr.GetScriptResourceName())
            sourceLine = ToPyString(v8ExceptionPtr.GetSourceLine())

            # TODO: throw exceptions according to execution context (Issue 11),

            # TODO: should we call v8ExceptionPtr.ClearException()? What if python code does try: except:
            # to catch the exception below, if it's catched then js should execute further, like it never happened,
            # and is ClearException() for that?

            stackTrace = FormatJavascriptStackTrace(GetJavascriptStackTrace(100))

            raise Exception("JavascriptCallback.Call() failed: javascript exception:\n%s.\nOn line %s in %s.\n"
                            "Source of that line: %s\n\n%s" % (message, lineNumber, scriptResourceName, sourceLine, stackTrace))

        if <void*>v8Retval == NULL:
            raise Exception("JavascriptCallback.Call() failed: ExecuteFunctionWithContext() called incorrectly")

        pyRet = V8ValueToPyValue(v8Retval, v8Context)

        return pyRet

    def GetName(self):

        cdef CefRefPtr[CefV8Value] v8Value = GetV8JavascriptCallback(self.__callbackID)
        cdef CefString cefFuncName
        cefFuncName = v8Value.get().GetFunctionName()
        return ToPyString(cefFuncName)
