# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef public cpp_bool V8FunctionHandler_Execute(
        CefRefPtr[CefV8Context] v8Context,
        int pythonCallbackId,
        CefString& cefFuncName,
        CefRefPtr[CefV8Value] cefObject, # receiver ('this' object) of the function.
        CefV8ValueList& v8Arguments,
        CefRefPtr[CefV8Value]& cefReturnValue,
        CefString& cefException
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyFrame pyFrame
    cdef JavascriptBindings javascriptBindings
    cdef cpp_vector[CefRefPtr[CefV8Value]].iterator iterator
    cdef CefRefPtr[CefV8Value] cefValue
    cdef object pythonCallback
    cdef list arguments
    cdef str functionName
    cdef object pyReturnValue
    cdef object pyFunction
    cdef str objectName
    cdef str objectMethod

    try:
        if pythonCallbackId:
            pythonCallback = GetPythonCallback(pythonCallbackId)

            arguments = []
            iterator = v8Arguments.begin()
            while iterator != v8Arguments.end():
                cefValue = deref(iterator)
                arguments.append(V8ToPyValue(cefValue, v8Context))
                preinc(iterator)

            pyReturnValue = pythonCallback(*arguments)
            # Can't use "arg = " for a referenced argument, bug in Cython,
            # see comment in RequestHandler_OnProtocolExecution() for
            # more details.
            cefReturnValue.swap(PyToV8Value(pyReturnValue, v8Context))

            return <cpp_bool>True
        else:
            pyBrowser = GetPyBrowser(v8Context.get().GetBrowser())
            pyFrame = GetPyFrame(v8Context.get().GetFrame())
            functionName = CefToPyString(cefFuncName)

            javascriptBindings = pyBrowser.GetJavascriptBindings()
            if not javascriptBindings:
                return <cpp_bool>False

            if functionName.find(".") == -1:
                pyFunction = javascriptBindings.GetFunction(functionName)
                if not pyFunction:
                    return <cpp_bool>False
            else:
                # functionName == "myobject.someMethod"
                (objectName, methodName) = functionName.split(".")
                pyFunction = javascriptBindings.GetObjectMethod(objectName, methodName)
                if not pyFunction:
                    return <cpp_bool>False

            # GetBindToFrames/GetBindToPopups must also be checked in:
            # V8FunctionHandler_Execute() and OnContextCreated(), so that calling
            # a non-existent  property on window object throws an error.

            if not pyFrame.IsMain() and not javascriptBindings.GetBindToFrames():
                return <cpp_bool>False

            if pyBrowser.IsPopup() and not javascriptBindings.GetBindToPopups():
                return <cpp_bool>False

            arguments = []
            iterator = v8Arguments.begin()
            while iterator != v8Arguments.end():
                cefValue = deref(iterator)
                arguments.append(V8ToPyValue(cefValue, v8Context))
                preinc(iterator)

            pyReturnValue = pyFunction(*arguments)
            cefReturnValue.swap(PyToV8Value(pyReturnValue, v8Context))

            return <cpp_bool>True

    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
