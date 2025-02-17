# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

from ctime cimport time_t
from libc.stdint cimport int64_t

cdef extern from "include/internal/cef_time.h":
    ctypedef struct cef_time_t:
        int year
        int month
        int day_of_week
        int day_of_month
        int hour
        int minute
        int second
        int millisecond

    ctypedef struct cef_basetime_t:
        int64_t val

cdef extern from "include/internal/cef_types.h":
    cdef cppclass CefTime:
        CefTime()
        CefTime(cef_time_t&)
        void SetTimeT(time_t r)
        time_t GetTimeT()
