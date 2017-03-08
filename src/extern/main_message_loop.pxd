# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_scoped_ptr cimport scoped_ptr

cdef extern from \
        "subprocess/main_message_loop/main_message_loop_external_pump.h":

    cdef cppclass MainMessageLoopExternalPump:
        @staticmethod
        scoped_ptr[MainMessageLoopExternalPump] Create()
