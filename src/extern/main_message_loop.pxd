# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libcpp.memory cimport unique_ptr

cdef extern from \
        "subprocess/main_message_loop/main_message_loop_external_pump.h":

    cdef cppclass MainMessageLoopExternalPump:
        @staticmethod
        unique_ptr[MainMessageLoopExternalPump] Create()
