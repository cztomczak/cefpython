# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

from ctime cimport time_t

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

cdef extern from "include/internal/cef_types_wrappers.h":
    cdef cppclass CefTime:
        CefTime()
        CefTime(cef_time_t&)
        void SetTimeT(time_t r)
        time_t GetTimeT()
