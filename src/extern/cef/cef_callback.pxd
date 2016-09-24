# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "include/cef_callback.h":

    cdef cppclass CefCallback:
        void Continue()
        void Cancel()

    cdef cppclass CefCompletionCallback:
        void OnComplete()
