# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString
from libcpp.vector cimport vector as cpp_vector

cdef extern from "include/cef_callback.h":

    cdef cppclass CefCallback:
        void Continue()
        void Cancel()

    cdef cppclass CefCompletionCallback:
        void OnComplete()

