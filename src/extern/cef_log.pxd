# Copyright (c) 2017 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "client_handler/cef_log.h":
    void cef_log_info(const char* tag, const char* msg)
    void cef_log_warning(const char* tag, const char* msg)
    void cef_log_error(const char* tag, const char* msg)
