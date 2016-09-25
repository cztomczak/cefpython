# Copyright (c) 2016 CEF Python. See the Authors and License files.

from cef_scoped_ptr cimport scoped_ptr

cdef extern from \
        "subprocess/main_message_loop/main_message_loop_external_pump.h":

    cdef cppclass MainMessageLoopExternalPump:
        @staticmethod
        scoped_ptr[MainMessageLoopExternalPump] Create()
