# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

cdef void DatetimeToCefTimeT(object pyDatetime, cef_time_t& timeT) except *:
    if not isinstance(pyDatetime, datetime.datetime):
        raise Exception("Expected object of type datetime.datetime")
    timeT.year = pyDatetime.year
    timeT.month = pyDatetime.month
    timeT.day_of_week = pyDatetime.weekday()
    timeT.day_of_month = pyDatetime.day
    timeT.hour = pyDatetime.hour
    timeT.minute = pyDatetime.minute
    timeT.second = pyDatetime.second
    # Milliseconds/microseconds are ignored.
    timeT.millisecond = 0

cdef object CefTimeTToDatetime(cef_time_t timeT):
    cdef int year = timeT.year
    if year < datetime.MINYEAR:
        year = datetime.MINYEAR
    if year > datetime.MAXYEAR:
        year = datetime.MAXYEAR
    cdef int month = timeT.month
    if month == 0:
        month = 1
    cdef int day_of_month = timeT.day_of_month
    if day_of_month == 0:
        day_of_month = 1
    cdef int second = timeT.second
    if second > 59:
        # Ignore leap seconds as datetime.datetime() allows 0-59 only.
        second = 59
    # Milliseconds/microseconds are ignored.
    return datetime.datetime(year, month, day_of_month,
            timeT.hour, timeT.minute, second)
