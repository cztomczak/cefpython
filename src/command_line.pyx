# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef void AppendSwitchesToCommandLine(
        CefRefPtr[CefCommandLine] cefCommandLine,
        dict switches
        ) except * with gil:
    # Called from:
    # 1. App_OnBeforeCommandLineProcessing_BrowserProcess()
    # 2. BrowserProcessHandler_OnRenderProcessThreadCreated()
    cdef PyCommandLine pyCommandLine = CreatePyCommandLine(cefCommandLine)
    cdef py_string switch
    cdef py_string value
    for switch, value in switches.iteritems():
        if not isinstance(switch, basestring) or switch[0] == '-':
            Debug("Invalid command line switch: %s" % switch)
            continue
        if value:
            if pyCommandLine.HasSwitch(switch)\
                    and value == pyCommandLine.GetSwitchValue(switch):
                Debug("Switch already set, ignoring: %s" % switch)
            else:
              pyCommandLine.AppendSwitchWithValue(switch, value)
        else:
            if pyCommandLine.HasSwitch(switch):
                Debug("Switch already set, ignoring: %s" % switch)
            else:
              pyCommandLine.AppendSwitch(switch)

cdef PyCommandLine CreatePyCommandLine(
        CefRefPtr[CefCommandLine] cefCommandLine):
    cdef PyCommandLine pyCommandLine = PyCommandLine()
    pyCommandLine.cefCommandLine = cefCommandLine
    return pyCommandLine

cdef class PyCommandLine:
    cdef CefRefPtr[CefCommandLine] cefCommandLine

    cdef py_void AppendSwitch(self, py_string switch):
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        self.cefCommandLine.get().AppendSwitch(cefSwitch)

    cdef py_void AppendSwitchWithValue(self, py_string switch, py_string value):
        cdef CefString cefSwitch
        cdef CefString cefValue
        cefSwitch = PyToCefStringValue(switch)
        cefValue = PyToCefStringValue(value)
        self.cefCommandLine.get().AppendSwitchWithValue(cefSwitch, cefValue)

    cdef py_string GetCommandLineString(self):
        return CefToPyString(self.cefCommandLine.get().GetCommandLineString())

    cdef py_bool HasSwitch(self, py_string switch):
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        return self.cefCommandLine.get().HasSwitch(cefSwitch)

    cdef py_string GetSwitchValue(self, py_string switch):
        cdef CefString cefValue
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        cefValue = self.cefCommandLine.get().GetSwitchValue(cefSwitch)
        return CefToPyString(cefValue)
