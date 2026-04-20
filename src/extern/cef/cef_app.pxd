# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Circular imports are allowed in form "cimport ...",
# but won't work if you do "from ... cimport *".

include "platform_cimports.pxi"

from cef_types cimport CefSettings
from cef_ptr cimport CefRefPtr
from libcpp cimport bool as cpp_bool

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
