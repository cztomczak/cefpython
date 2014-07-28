# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

include "compile_time_constants.pxi"

from cef_base cimport CefBase
from cef_string cimport CefString
from libcpp cimport bool as cpp_bool

cdef extern from "include/cef_command_line.h":
    cdef cppclass CefCommandLine(CefBase):
        void AppendSwitch(CefString& name)
        void AppendSwitchWithValue(CefString& name, CefString& value)
        CefString GetCommandLineString()
        cpp_bool HasSwitch(const CefString& name)
        CefString GetSwitchValue(const CefString& name)
