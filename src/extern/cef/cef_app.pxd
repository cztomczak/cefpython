# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

include "compile_time_constants.pxi"

from cef_types cimport CefSettings
from cef_ptr cimport CefRefPtr
from libcpp cimport bool as cpp_bool

IF UNAME_SYSNAME == "Windows":
    from cef_win cimport CefMainArgs
ELIF UNAME_SYSNAME == "Linux":
    from cef_linux cimport CefMainArgs
ELIF UNAME_SYSNAME == "Darwin":
    from cef_mac cimport CefMainArgs

cdef extern from "include/cef_app.h":

    cdef cppclass CefApp:
        pass

    cdef int CefExecuteProcess(CefMainArgs& args,
                               CefRefPtr[CefApp] application,
                               void* windows_sandbox_info
                               ) nogil

    cdef cpp_bool CefInitialize(CefMainArgs&,
                                CefSettings&, CefRefPtr[CefApp],
                                void* windows_sandbox_info
                                ) nogil

    cdef void CefRunMessageLoop() nogil
    cdef void CefDoMessageLoopWork() nogil
    cdef void CefQuitMessageLoop() nogil
    cdef void CefShutdown() nogil
    cdef void CefSetOSModalLoop(cpp_bool osModalLoop) nogil
