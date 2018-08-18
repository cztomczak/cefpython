# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"
include "../frame.pyx"
include "../process_message_utils.pyx"

cdef public void AccessibilityHandler_OnAccessibilityTreeChange(
            CefRefPtr[CefValue] cefValue
            ) except * with gil:
    cdef object value = CefValueToPyValue(cefValue)
    cdef object callback
    try:
        callback = GetGlobalClientCallback("OnAccessibilityTreeChange")
        if callback:
            callback(value=value)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void AccessibilityHandler_OnAccessibilityLocationChange(
            CefRefPtr[CefValue] cefValue
            ) except * with gil:
    cdef object value = CefValueToPyValue(cefValue)
    cdef object callback
    try:
        callback = GetGlobalClientCallback("OnAccessibilityLocationChange")
        if callback:
            callback(value=value)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
