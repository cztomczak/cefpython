# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "include/cef_request_context_handler.h":
    cdef cppclass CefRequestContextHandler:
        pass
