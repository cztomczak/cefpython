# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from cef_types_wrappers cimport CefRect
from libcpp.vector cimport vector as cpp_vector

cdef extern from "include/cef_render_handler.h":

    ctypedef cpp_vector[CefRect] CefRectVector