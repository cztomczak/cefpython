# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

include "compile_time_constants.pxi"

from cef_types_wrappers cimport CefSettings
from cef_ptr cimport CefRefPtr
from cef_base cimport CefBase
from libcpp cimport bool as cpp_bool

IF CEF_VERSION == 3:
    IF UNAME_SYSNAME == "Windows":
        from cef_win cimport CefMainArgs

cdef extern from "include/cef_app.h":

    cdef cppclass CefApp(CefBase):
        pass

    IF CEF_VERSION == 3:
        cdef int CefExecuteProcess(CefMainArgs& args, CefRefPtr[CefApp] application)

    IF CEF_VERSION == 1:
        cdef cpp_bool CefInitialize(CefSettings&, CefRefPtr[CefApp])
    ELIF CEF_VERSION == 3:
        cdef cpp_bool CefInitialize(CefMainArgs&, CefSettings&, CefRefPtr[CefApp])

    cdef void CefRunMessageLoop() nogil
    cdef void CefDoMessageLoopWork() nogil
    cdef void CefQuitMessageLoop()
    cdef void CefShutdown()

