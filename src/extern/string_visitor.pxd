# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

cdef extern from "client_handler/string_visitor.h":

    cdef cppclass StringVisitor:
        StringVisitor(int stringVisitorId)
