# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/cef_base.h":

    cdef cppclass CefBase:
        int AddRef()
        int Release()
        int GetRefCt()
