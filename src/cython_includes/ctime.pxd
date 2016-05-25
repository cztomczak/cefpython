# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

cdef extern from "time.h":
    ctypedef struct time_t:
        pass
    ctypedef struct tm:
        int tm_sec
        int tm_min
        int tm_hour
        int tm_mday
        int tm_mon
        int tm_year
        int tm_wday
        int tm_yday
        int tm_isdst

    size_t strftime (char* ptr, size_t maxsize, const char* format,
                 const tm* timeptr )
    tm* localtime (const time_t* timer)
    time_t mktime (tm* timeptr)