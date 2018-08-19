# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from cef_string cimport CefString

cdef extern from "include/cef_file_util.h":
    void CefLoadCRLSetsFile(const CefString& path)
