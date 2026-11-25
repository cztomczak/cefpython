# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from libc.stdint cimport int64_t

cdef extern from "client_handler/web_request_client.h":

    cdef cppclass WebRequestClient:
        WebRequestClient(int64_t webRequestId)
