# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libc.stdint cimport int64_t

cdef extern from "client_handler/resource_handler.h":

    cdef cppclass ResourceHandler:
        ResourceHandler(int64_t resourceHandlerId)
