# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from python_ref cimport PyObject

cdef extern from "Python.h":
    cdef PyObject* PyLong_FromVoidPtr(void *p)
