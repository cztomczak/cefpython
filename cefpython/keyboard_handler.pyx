# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

KEYEVENT_RAWKEYDOWN = <int>cef_types.KEYEVENT_RAWKEYDOWN
KEYEVENT_KEYDOWN = <int>cef_types.KEYEVENT_KEYDOWN
KEYEVENT_KEYUP = <int>cef_types.KEYEVENT_KEYUP
KEYEVENT_CHAR = <int>cef_types.KEYEVENT_CHAR

KEY_NONE = 0
KEY_SHIFT = <int>cef_types.KEY_SHIFT
KEY_CTRL = <int>cef_types.KEY_CTRL
KEY_ALT = <int>cef_types.KEY_ALT
KEY_META  = <int>cef_types.KEY_META
KEY_KEYPAD = <int>cef_types.KEY_KEYPAD

cdef public c_bool KeyboardHandler_OnKeyEvent(
        CefRefPtr[CefBrowser] cefBrowser,
        cef_types.cef_handler_keyevent_type_t eventType,
        int code,
        int modifiers,
        c_bool isSystemKey,
        c_bool isAfterJavascript
        ) except * with gil:

    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        if not pyBrowser:
            Debug("KeyboardHandler_OnKeyEvent() failed: pyBrowser is %s" % pyBrowser)
            return False
        callback = pyBrowser.GetClientCallback("OnKeyEvent")
        if callback:
            return bool(callback(pyBrowser, <int>eventType, code, modifiers, isSystemKey, isAfterJavascript))
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

