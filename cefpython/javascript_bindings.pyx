# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef class JavascriptBindings:
    # By default binding only to top frame.
    cdef public int bindToFrames
    cdef public int bindToPopups
    cdef public dict functions
    cdef public dict properties
    cdef public dict objects

    # V8ContextHandler_OnContextCreated inserts frames here that should have
    # javascript bindings, it is later needed to do rebinding using Rebind()
    # method. All frames are here, the main too, frames may be from different
    # Browser objects.
    cdef public dict frames # frameIdentifier(int64) : tuple(PyBrowser, PyFrame())

    def __init__(self, bindToFrames=False, bindToPopups=False):
        self.functions = {}
        self.properties = {}
        self.objects = {}
        self.frames = {}

        self.bindToFrames = int(bindToFrames)
        self.bindToPopups = int(bindToPopups)

    cpdef py_bool GetBindToFrames(self):
        return bool(self.bindToFrames)

    cpdef py_bool GetBindToPopups(self):
        return bool(self.bindToPopups)

    cpdef py_void SetFunction(self, py_string name, object func):
        self.SetProperty(name, func)

    cpdef py_void SetObject(self, py_string name, object obj):
        if not hasattr(obj, "__class__"):
            raise Exception("JavascriptBindings.SetObject() failed: name=%s, "
                            "__class__ attribute missing, this is not an object" % name)
        cdef dict methods = {}
        cdef py_string key
        cdef object method
        cdef object predicate = inspect.ismethod
        if isinstance(obj, (PyBrowser, PyFrame)):
            predicate = inspect.isbuiltin
        for value in inspect.getmembers(obj, predicate=predicate):
            key = value[0]
            method = value[1]
            methods[key] = method
        self.objects[name] = methods

    cpdef object GetFunction(self, py_string name):
        if name in self.functions:
            return self.functions[name]

    cpdef dict GetFunctions(self):
        return self.functions

    cpdef dict GetObjects(self):
        return self.objects

    cpdef object GetObjectMethod(self, py_string objectName, py_string methodName):
        if objectName in self.objects:
            if methodName in self.objects[objectName]:
                return self.objects[objectName][methodName]

    cpdef py_void SetProperty(self, py_string name, object value):
        cdef object allowed = self.IsValueAllowedRecursively(value) # returns True or string.
        if allowed is not True:
            raise Exception("JavascriptBindings.SetProperty() failed: name=%s, "
                            "not allowed type: %s (this may be a type of a nested value)"
                            % (name, allowed))

        cdef object valueType = type(value)
        if valueType == types.FunctionType or valueType == types.MethodType:
            self.functions[name] = value
        else:
            self.properties[name] = value

    cdef py_void AddFrame(self, PyBrowser pyBrowser, PyFrame pyFrame):
        if pyFrame.GetIdentifier() not in self.frames:
            self.frames[pyFrame.GetIdentifier()] = (pyBrowser, pyFrame)

    cdef py_void RemoveFrame(self, PyBrowser pyBrowser, PyFrame pyFrame):
        if pyFrame.GetIdentifier() in self.frames:
            del self.frames[pyFrame.GetIdentifier()]

    cpdef py_void Rebind(self):
        assert IsThread(TID_UI), (
                "JavascriptBindings.Rebind() may only be called on UI thread")

        cdef CefRefPtr[CefBrowser] cefBrowser
        cdef CefRefPtr[CefFrame] cefFrame
        cdef CefRefPtr[CefV8Context] v8Context
        cdef cpp_bool sameContext
        cdef PyBrowser pyBrowser
        cdef PyFrame pyFrame

        for frameId in self.frames:
            pyBrowser = self.frames[frameId][0]
            pyFrame = self.frames[frameId][1]
            cefBrowser = pyBrowser.GetCefBrowser()
            cefFrame = pyFrame.GetCefFrame()
            v8Context = cefFrame.get().GetV8Context()

            sameContext = v8Context.get().IsSame(cef_v8_static.GetCurrentContext())
            if not sameContext:
                Debug("JavascriptBindings.Rebind(): inside a different context, calling v8Context.Enter()")
                assert v8Context.get().Enter(), "v8Context.Enter() failed"

            V8ContextHandler_OnContextCreated(cefBrowser, cefFrame, v8Context)

            if not sameContext:
                assert v8Context.get().Exit(), "v8Context.Exit() failed"

    cpdef dict GetProperties(self):
        return self.properties

    @staticmethod
    def IsValueAllowed(object value):
        return JavascriptBindings.IsValueAllowedRecursively(value) is True

    @staticmethod
    def IsValueAllowedRecursively(object value, py_bool recursion=False):
        # When making changes here modify also Frame.SetProperty() as it
        # checks for FunctionType, MethodType.

        cdef object valueType = type(value)
        cdef object valueType2
        cdef object key

        if valueType == list:
            for val in value:
                valueType2 = JavascriptBindings.IsValueAllowedRecursively(val, True)
                if valueType2 is not True:
                    return valueType2.__name__
            return True
        elif valueType == bool:
            return True
        elif valueType == float:
            return True
        elif valueType == int:
            return True
        elif valueType == type(None):
            return True
        elif valueType == types.FunctionType or valueType == types.MethodType:
            if recursion:
                return valueType.__name__
            else:
                return True
        elif valueType == dict:
            for key in value:
                valueType2 = JavascriptBindings.IsValueAllowedRecursively(value[key], True)
                if valueType2 is not True:
                    return valueType2.__name__
            return True
        elif valueType == str:
            return True
        elif valueType == unicode:
            return True
        elif valueType == tuple:
            return True
        else:
            return valueType.__name__
