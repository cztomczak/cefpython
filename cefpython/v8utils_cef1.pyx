# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# CefV8 Objects, Arrays and Functions can be created or modified only 
# inside V8 context, you need to call CefV8Context::Enter() and 
# CefV8Context::Exit(), see:
# http://code.google.com/p/chromiumembedded/issues/detail?id=203

cdef list CefV8StackTraceToPython(CefRefPtr[CefV8StackTrace] cefTrace):
    cdef int frameNumber
    cdef int frameCount = cefTrace.get().GetFrameCount()
    cdef CefRefPtr[CefV8StackFrame] cefFrame
    cdef CefV8StackFrame* framePtr
    cdef list pyTrace = []

    for frameNumber in range(0, frameCount):
        cefFrame = cefTrace.get().GetFrame(frameNumber)
        framePtr = cefFrame.get()
        pyFrame = {}
        pyFrame["script"] = CefToPyString(framePtr.GetScriptName())
        pyFrame["scriptOrSourceUrl"] = CefToPyString(
                framePtr.GetScriptNameOrSourceURL())
        pyFrame["function"] = CefToPyString(framePtr.GetFunctionName())
        pyFrame["line"] = framePtr.GetLineNumber()
        pyFrame["column"] = framePtr.GetColumn()
        pyFrame["isEval"] = framePtr.IsEval()
        pyFrame["isConstructor"] = framePtr.IsConstructor()
        pyTrace.append(pyFrame)

    return pyTrace

cpdef list GetJavascriptStackTrace(int frameLimit=100):
    assert IsThread(TID_UI), (
            "cefpython.GetJavascriptStackTrace() may only be called on the UI thread")
    cdef CefRefPtr[CefV8StackTrace] cefTrace = (
            cef_v8_stack_trace.GetCurrent(frameLimit))
    return CefV8StackTraceToPython(cefTrace)

cpdef str FormatJavascriptStackTrace(list stackTrace):
    cdef str formatted = ""
    cdef dict frame
    for frameNumber, frame in enumerate(stackTrace):
        formatted += "\t[%s] %s() in %s on line %s (col:%s)\n" % (
                frameNumber,
                frame["function"],
                frame["scriptOrSourceUrl"],
                frame["line"],
                frame["column"])
    return formatted

cdef object V8ToPyValue(
        CefRefPtr[CefV8Value] v8Value,
        CefRefPtr[CefV8Context] v8Context,
        int nestingLevel=0):

    # With nestingLevel > 10 we get system exceptions.
    if nestingLevel > 8:
        raise Exception("V8ToPyValue() failed: data passed from Javascript to "
                "Python has more than 8 levels of nesting, this is probably an infinite "
                "recursion, stopping.")

    cdef CefV8Value* v8ValuePtr = v8Value.get()
    cdef CefString cefString
    cdef CefString cefFuncName
    cdef cpp_vector[CefString] keys
    cdef cpp_vector[CefString].iterator iterator

    cdef list pyArray
    cdef int callbackId
    cdef dict pyDict

    # A test against IsArray should be done before IsObject().
    if v8ValuePtr.IsArray():
        pyArray = []
        for key in range(0, v8ValuePtr.GetArrayLength()):
            pyArray.append(V8ToPyValue(
                    v8ValuePtr.GetValue(<int>int(key)),
                    v8Context,
                    nestingLevel+1))
        return pyArray
    elif v8ValuePtr.IsBool():
        return v8ValuePtr.GetBoolValue()
    elif v8ValuePtr.IsDate():
        # TODO: convert it to string with no error.
        raise Exception("V8ToPyValue() failed: Date object is not supported, "
                "you are not allowed to pass it from Javascript to Python.")
    elif v8ValuePtr.IsInt():
        # A check against IsInt() must be done before IsDouble(), as any js integer
        # returns true when calling IsDouble().
        return v8ValuePtr.GetIntValue()
    elif v8ValuePtr.IsUInt():
        return v8ValuePtr.GetUIntValue()
    elif v8ValuePtr.IsDouble():
        return v8ValuePtr.GetDoubleValue()
    elif v8ValuePtr.IsFunction():
        callbackId = PutV8JavascriptCallback(v8Value, v8Context)
        return JavascriptCallback(callbackId)
    elif v8ValuePtr.IsNull():
        return None
    elif v8ValuePtr.IsObject():
        # A test against IsObject() should be done after IsArray().
        # Remember about increasing the nestingLevel.
        v8ValuePtr.GetKeys(keys)
        iterator = keys.begin()
        pyDict = {}
        while iterator != keys.end():
            cefString = deref(iterator)
            key = CefToPyString(cefString)
            value = V8ToPyValue(
                    v8ValuePtr.GetValue(cefString),
                    v8Context,
                    nestingLevel+1)
            pyDict[key] = value
            preinc(iterator)
        return pyDict
    elif v8ValuePtr.IsString():
        return CefToPyString(v8ValuePtr.GetStringValue())
    elif v8ValuePtr.IsUndefined():
        return None
    else:
        raise Exception("V8ToPyValue() failed: unknown type of CefV8Value.")

# Any function calling PyToV8Value must be inside that v8Context,
# check current context and call Enter if required otherwise exception is
# thrown while trying to create an array, object or function.

cdef CefRefPtr[CefV8Value] PyToV8Value(
        object pyValue,
        CefRefPtr[CefV8Context] v8Context,
        int nestingLevel=0) except *:

    # With nestingLevel > 10 we get system exceptions.
    if nestingLevel > 8:
        raise Exception("PyToV8Value() failed: data passed from Python "
                "to Javascript has more than 8 levels of nesting, this is probably "
                "an infinite recursion, stopping.")

    cdef cpp_bool sameContext
    if g_debug:
        sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())
        if not sameContext:
            raise Exception("PyToV8Value() called in wrong v8 context")

    cdef CefString cefString
    cdef CefRefPtr[CefV8Value] v8Value
    cdef CefString cefFuncName
    cdef type pyValueType = type(pyValue)

    if pyValueType == tuple:
        pyValue = list(pyValue)

    # Check type again, as code above may have changed it.
    pyValueType = type(pyValue)

    cdef int index
    cdef object value
    cdef CefRefPtr[V8FunctionHandler] v8FunctionHandler
    cdef CefRefPtr[CefV8Handler] v8Handler
    cdef int callbackId
    cdef object key

    if pyValueType == list:
        v8Value = cef_v8_static.CreateArray(len(pyValue))
        for index,value in enumerate(pyValue):
            v8Value.get().SetValue(
                    index,
                    PyToV8Value(value, v8Context, nestingLevel+1))
        return v8Value
    elif pyValueType == bool:
        return cef_v8_static.CreateBool(bool(pyValue))
    elif pyValueType == int:
        return cef_v8_static.CreateInt(int(pyValue))
    elif pyValueType == long:
        # Int32 range is -2147483648..2147483647, we've increased the
        # minimum size by one as Cython was throwing a warning:
        # "unary minus operator applied to unsigned type, result still 
        # unsigned".
        if pyValue <= 2147483647 and pyValue >= -2147483647:
            return cef_v8_static.CreateInt(int(pyValue))
        else:
            PyToCefString(str(pyValue), cefString)
            return cef_v8_static.CreateString(cefString)
    elif pyValueType == float:
        return cef_v8_static.CreateDouble(float(pyValue))
    elif pyValueType == types.FunctionType or pyValueType == types.MethodType:
        v8FunctionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
        v8FunctionHandler.get().SetContext(v8Context)
        v8Handler = <CefRefPtr[CefV8Handler]>v8FunctionHandler.get()
        PyToCefString(pyValue.__name__, cefFuncName)
         # V8PythonCallback.
        v8Value = cef_v8_static.CreateFunction(cefFuncName, v8Handler)
        callbackId = PutPythonCallback(pyValue)
        v8FunctionHandler.get().SetCallback_RemovePythonCallback(
                <RemovePythonCallback_type>RemovePythonCallback)
        v8FunctionHandler.get().SetPythonCallbackID(callbackId)
        return v8Value
    elif pyValueType == type(None):
        return cef_v8_static.CreateNull()
    elif pyValueType == dict:
        v8Value = cef_v8_static.CreateObject(<CefRefPtr[CefV8Accessor]>NULL)
        for key, value in pyValue.items():
            # A dict may have an int key, a string key or even a tuple key:
            # {0: 12, '0': 12, (0, 1): 123}
            # Remember about increasing nestingLevel.
            PyToCefString(str(key), cefString)
            v8Value.get().SetValue(
                    cefString,
                    PyToV8Value(value, v8Context, nestingLevel+1),
                    V8_PROPERTY_ATTRIBUTE_NONE)
        return v8Value
    elif pyValueType == bytes or pyValueType == str \
            or (PY_MAJOR_VERSION < 3 and pyValueType == unicode):
        # The unicode type is not defined in Python 3.
        PyToCefString(pyValue, cefString)
        return cef_v8_static.CreateString(cefString)
    elif pyValueType == type:
        PyToCefString(str(pyValue), cefString)
        return cef_v8_static.CreateString(cefString)
    else:
        raise Exception("PyToV8Value() failed: an unsupported python type "
                "was passed from python to javascript: %s, value: %s"
                % (pyValueType.__name__, pyValue))
