# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

KEYEVENT_RAWKEYDOWN = cef_types.KEYEVENT_RAWKEYDOWN
KEYEVENT_KEYDOWN = cef_types.KEYEVENT_KEYDOWN
KEYEVENT_KEYUP = cef_types.KEYEVENT_KEYUP
KEYEVENT_CHAR = cef_types.KEYEVENT_CHAR

KEY_NONE = 0
KEY_SHIFT = cef_types.KEY_SHIFT
KEY_CTRL = cef_types.KEY_CTRL
KEY_ALT = cef_types.KEY_ALT
KEY_META  = cef_types.KEY_META
KEY_KEYPAD = cef_types.KEY_KEYPAD

cdef public cpp_bool KeyboardHandler_OnKeyEvent(
        CefRefPtr[CefBrowser] cefBrowser,
        cef_types.cef_handler_keyevent_type_t eventType,
        int code,
        int modifiers,
        cpp_bool isSystemKey,
        cpp_bool isAfterJavascript
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnKeyEvent")
        if callback:
            return bool(callback(
                    pyBrowser,
                    <int>eventType,
                    code,
                    modifiers,
                    isSystemKey,
                    isAfterJavascript))
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
