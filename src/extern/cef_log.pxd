# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "client_handler/cef_log.h":
    void cef_log_info(char* msg)
    void cef_log_warning(char* msg)
    void cef_log_error(char* msg)
