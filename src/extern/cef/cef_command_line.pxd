# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

include "compile_time_constants.pxi"

from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_command_line.h":
    cdef cppclass CefCommandLine:
        void AppendSwitch(CefString& name)
        void AppendSwitchWithValue(CefString& name, CefString& value)
        CefString GetCommandLineString()
        cpp_bool HasSwitch(const CefString& name)
        CefString GetSwitchValue(const CefString& name)
