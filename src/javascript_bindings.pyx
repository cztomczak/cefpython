# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef class JavascriptBindings:
    # By default binding only to top frame.
    cdef public py_bool bindToFrames
    cdef public py_bool bindToPopups
    cdef public dict functions
    cdef public dict properties
    cdef public dict objects

    def __init__(self, bindToFrames=False, bindToPopups=False):
        self.functions = {}
        self.properties = {}
        self.objects = {}

        self.bindToFrames = bool(bindToFrames)
        self.bindToPopups = bool(bindToPopups)

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

    cpdef object GetFunctionOrMethod(self, py_string name):
        # Name can be "someFunc" or "object.someMethod".
        cdef list words
        if "." in name:
            words = name.split(".")
            return self.GetObjectMethod(words[0], words[1])
        else:
            return self.GetFunction(name)

    cpdef py_void SetProperty(self, py_string name, object value):
        cdef object allowed = self.IsValueAllowedRecursively(value) # returns True or string.
        if allowed is not True:
            raise Exception("JavascriptBindings.SetProperty() failed: name=%s, "
                            "not allowed type: %s (this may be a type of a nested value)"
                            % (name, allowed))

        cdef object valueType = type(value)
        if IsFunctionOrMethod(valueType):
            self.functions[name] = value
        else:
            self.properties[name] = value

    cpdef py_void Rebind(self):
        # Rebind() is called for both first-time binding and rebinding.
        cdef PyBrowser pyBrowser
        cdef dict functions
        cdef dict properties
        cdef dict objects
        cdef dict methods
        for browserId, pyBrowser in g_pyBrowsers.iteritems():
            if pyBrowser.GetJavascriptBindings() != self:
                continue
            # Send to the Renderer process: functions, properties,
            # objects and its methods, bindToFrames.
            functions = {}
            for funcName in self.functions:
                functions[funcName] = None
            properties = self.properties
            objects = {}
            for objectName in self.objects:
                methods = {}
                for methodName in self.objects[objectName]:
                    methods[methodName] = None
                objects[objectName] = methods
            pyBrowser.SendProcessMessage(cef_types.PID_RENDERER,
                    0, "DoJavascriptBindings", [{
                            "functions": functions,
                            "properties": properties,
                            "objects": objects,
                            "bindToFrames": self.bindToFrames
                            }])

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
        elif valueType == long:
            return True
        elif valueType == type(None):
            return True
        elif IsFunctionOrMethod(valueType):
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
        elif valueType == str or valueType == bytes:
            return True
        elif PY_MAJOR_VERSION < 3 and valueType == unicode:
            # The unicode type is not defined in Python 3.
            return True
        elif valueType == tuple:
            return True
        else:
            return valueType.__name__
