# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef void AppendSwitchesToCommandLine(
        CefRefPtr[CefCommandLine] cefCommandLine,
        dict switches
        ) noexcept with gil:
    # Called from:
    # 1. App_OnBeforeCommandLineProcessing_BrowserProcess()
    # 2. BrowserProcessHandler_OnRenderProcessThreadCreated()
    cdef PyCommandLine pyCommandLine = CreatePyCommandLine(cefCommandLine)
    cdef object switch
    cdef object value
    for switch, value in switches.items():
        if not isinstance(switch, (str, bytes)) or switch[0] == '-':
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

    cdef py_void AppendSwitch(self, object switch):
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        self.cefCommandLine.get().AppendSwitch(cefSwitch)

    cdef py_void AppendSwitchWithValue(self, object switch, object value):
        cdef CefString cefSwitch
        cdef CefString cefValue
        cefSwitch = PyToCefStringValue(switch)
        cefValue = PyToCefStringValue(value)
        self.cefCommandLine.get().AppendSwitchWithValue(cefSwitch, cefValue)

    cdef object GetCommandLineString(self):
        return CefToPyString(self.cefCommandLine.get().GetCommandLineString())

    cdef py_bool HasSwitch(self, object switch):
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        return self.cefCommandLine.get().HasSwitch(cefSwitch)

    cdef object GetSwitchValue(self, object switch):
        cdef CefString cefValue
        cdef CefString cefSwitch
        cefSwitch = PyToCefStringValue(switch)
        cefValue = self.cefCommandLine.get().GetSwitchValue(cefSwitch)
        return CefToPyString(cefValue)
