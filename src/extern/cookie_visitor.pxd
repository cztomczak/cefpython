# Copyright (c) 2014 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "client_handler/cookie_visitor.h":

    cdef cppclass CookieVisitor:
        CookieVisitor(int cookieVisitorId)
