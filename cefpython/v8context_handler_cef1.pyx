# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

V8_PROPERTY_ATTRIBUTE_NONE = cef_types.V8_PROPERTY_ATTRIBUTE_NONE
V8_PROPERTY_ATTRIBUTE_READONLY = cef_types.V8_PROPERTY_ATTRIBUTE_READONLY
V8_PROPERTY_ATTRIBUTE_DONTENUM = cef_types.V8_PROPERTY_ATTRIBUTE_DONTENUM
V8_PROPERTY_ATTRIBUTE_DONTDELETE = cef_types.V8_PROPERTY_ATTRIBUTE_DONTDELETE

cdef public void V8ContextHandler_OnContextCreated(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefV8Context] cefContext
        ) except * with gil:
    # This handler may also be called by JavascriptBindings.Rebind().
    # This handler may be called multiple times for the same frame - rebinding.

    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame

    cdef JavascriptBindings javascriptBindings
    cdef dict javascriptFunctions
    cdef dict javascriptProperties
    cdef dict javascriptObjects

    cdef CefRefPtr[V8FunctionHandler] functionHandler
    cdef CefRefPtr[CefV8Handler] v8Handler
    cdef CefRefPtr[CefV8Value] v8Window
    cdef CefRefPtr[CefV8Value] v8Function
    cdef CefRefPtr[CefV8Value] v8Object
    cdef CefRefPtr[CefV8Value] v8Method

    cdef CefString cefFunctionName
    cdef CefString cefPropertyName
    cdef CefString cefMethodName
    cdef CefString cefObjectName

    cdef object key
    cdef object value
    cdef py_string functionName
    cdef py_string objectName

    cdef object clientCallback

    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyBrowser.SetUserData("__v8ContextCreated", True)
        pyFrame = GetPyFrame(cefFrame)

        javascriptBindings = pyBrowser.GetJavascriptBindings()
        if not javascriptBindings:
            return

        javascriptFunctions = javascriptBindings.GetFunctions()
        javascriptProperties = javascriptBindings.GetProperties()
        javascriptObjects = javascriptBindings.GetObjects()

        if not javascriptFunctions and not javascriptProperties and not javascriptObjects:
            return

        # This checks GetBindToFrames/GetBindToPopups must also be made in both:
        # FunctionHandler_Execute() and OnContextCreated(), so that calling
        # a non-existent  property on window object throws an error.

        if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
            return

        # This check is probably not needed, as GetPyBrowser() will already pass bindings=None,
        # if this is a popup window and bindToPopups is False.

        if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
            return

        v8Window = cefContext.get().GetGlobal()

        if javascriptProperties:
            for key,value in javascriptProperties.items():
                key = str(key)
                PyToCefString(key, cefPropertyName)
                v8Window.get().SetValue(
                        cefPropertyName,
                        PyToV8Value(value, cefContext),
                        V8_PROPERTY_ATTRIBUTE_NONE)

        if javascriptFunctions or javascriptObjects:
            functionHandler = <CefRefPtr[V8FunctionHandler]>new V8FunctionHandler()
            functionHandler.get().SetContext(cefContext)
            v8Handler = <CefRefPtr[CefV8Handler]>functionHandler.get()

        if javascriptFunctions:
            for functionName in javascriptFunctions:
                functionName = str(functionName)
                PyToCefString(functionName, cefFunctionName)
                v8Function = cef_v8_static.CreateFunction(cefFunctionName, v8Handler)
                v8Window.get().SetValue(cefFunctionName, v8Function, V8_PROPERTY_ATTRIBUTE_NONE)

        if javascriptObjects:
            for objectName in javascriptObjects:
                v8Object = cef_v8_static.CreateObject(<CefRefPtr[CefV8Accessor]>NULL)
                PyToCefString(objectName, cefObjectName)
                v8Window.get().SetValue(
                        cefObjectName, v8Object, V8_PROPERTY_ATTRIBUTE_NONE)

                for methodName in javascriptObjects[objectName]:
                    methodName = str(methodName)
                    # cefMethodName = "myobject.someMethod"
                    PyToCefString(objectName+"."+methodName, cefMethodName)
                    v8Method = cef_v8_static.CreateFunction(cefMethodName, v8Handler)
                    # cefMethodName = "someMethod"
                    PyToCefString(methodName, cefMethodName)
                    v8Object.get().SetValue(
                            cefMethodName, v8Method, V8_PROPERTY_ATTRIBUTE_NONE)

        # User defined callback.
        clientCallback = pyBrowser.GetClientCallback("OnContextCreated")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame)

    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnContextReleased(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefV8Context] cefContext
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)
        # User defined callback.
        clientCallback = pyBrowser.GetClientCallback("OnContextReleased")
        if clientCallback:
            clientCallback(pyBrowser, pyFrame)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void V8ContextHandler_OnUncaughtException(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRefPtr[CefFrame] cefFrame,
        CefRefPtr[CefV8Context] cefContext,
        CefRefPtr[CefV8Exception] cefException,
        CefRefPtr[CefV8StackTrace] cefStackTrace
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef CefRefPtr[CefV8Exception] v8Exception
    cdef CefV8Exception* v8ExceptionPointer
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyFrame = GetPyFrame(cefFrame)

        v8ExceptionPointer = cefException.get()
        pyException = {}
        pyException["lineNumber"] = v8ExceptionPointer.GetLineNumber()
        pyException["message"] = CefToPyString(v8ExceptionPointer.GetMessage())
        pyException["scriptResourceName"] = CefToPyString(
                v8ExceptionPointer.GetScriptResourceName())
        pyException["sourceLine"] = CefToPyString(v8ExceptionPointer.GetSourceLine())

        pyStackTrace = CefV8StackTraceToPython(cefStackTrace)

        callback = pyBrowser.GetClientCallback("OnUncaughtException")
        if callback:
            callback(pyBrowser, pyFrame, pyException, pyStackTrace)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
