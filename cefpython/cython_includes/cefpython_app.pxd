# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_app cimport CefApp

cdef extern from "subprocess/cefpython_app.h":
    cdef cppclass CefPythonApp(CefApp):
        pass
