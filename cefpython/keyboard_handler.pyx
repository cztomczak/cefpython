# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# cef_key_event_type_t
KEYEVENT_RAWKEYDOWN = cef_types.KEYEVENT_RAWKEYDOWN
KEYEVENT_KEYDOWN = cef_types.KEYEVENT_KEYDOWN
KEYEVENT_KEYUP = cef_types.KEYEVENT_KEYUP
KEYEVENT_CHAR = cef_types.KEYEVENT_CHAR

# cef_event_flags_t
EVENTFLAG_NONE = cef_types.EVENTFLAG_NONE
EVENTFLAG_CAPS_LOCK_ON = cef_types.EVENTFLAG_CAPS_LOCK_ON
EVENTFLAG_SHIFT_DOWN = cef_types.EVENTFLAG_SHIFT_DOWN
EVENTFLAG_CONTROL_DOWN = cef_types.EVENTFLAG_CONTROL_DOWN
EVENTFLAG_ALT_DOWN = cef_types.EVENTFLAG_ALT_DOWN
EVENTFLAG_LEFT_MOUSE_BUTTON = cef_types.EVENTFLAG_LEFT_MOUSE_BUTTON
EVENTFLAG_MIDDLE_MOUSE_BUTTON = cef_types.EVENTFLAG_MIDDLE_MOUSE_BUTTON
EVENTFLAG_RIGHT_MOUSE_BUTTON = cef_types.EVENTFLAG_RIGHT_MOUSE_BUTTON
# Mac OS-X command key.
EVENTFLAG_COMMAND_DOWN = cef_types.EVENTFLAG_COMMAND_DOWN
EVENTFLAG_NUM_LOCK_ON = cef_types.EVENTFLAG_NUM_LOCK_ON
EVENTFLAG_IS_KEY_PAD = cef_types.EVENTFLAG_IS_KEY_PAD
EVENTFLAG_IS_LEFT = cef_types.EVENTFLAG_IS_LEFT
EVENTFLAG_IS_RIGHT = cef_types.EVENTFLAG_IS_RIGHT

cdef dict CefToPyKeyEvent(const cef_types.CefKeyEvent& cefKeyEvent):
    pyKeyEvent = {
        "type": cefKeyEvent.type,
        "modifiers": cefKeyEvent.modifiers,
        "windows_key_code": cefKeyEvent.windows_key_code,
        "native_key_code": cefKeyEvent.native_key_code,
        "is_system_key": cefKeyEvent.is_system_key,
        "character": cefKeyEvent.character,
        "unmodified_character": cefKeyEvent.unmodified_character,
        "focus_on_editable_field": cefKeyEvent.focus_on_editable_field
    }
    return pyKeyEvent

cdef public cpp_bool KeyboardHandler_OnPreKeyEvent(
        CefRefPtr[CefBrowser] cefBrowser,
        const cef_types.CefKeyEvent& cefEvent,
        cef_types.CefEventHandle cefEventHandle,
        cpp_bool* cefIsKeyboardShortcut
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef dict pyEvent
    cdef list pyIsKeyboardShortcutOut
    cdef py_bool returnValue
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyEvent = CefToPyKeyEvent(cefEvent)
        pyIsKeyboardShortcutOut = [cefIsKeyboardShortcut[0]]
        callback = pyBrowser.GetClientCallback("OnPreKeyEvent")
        if callback:
            returnValue = callback(pyBrowser, pyEvent, 
                    <object>PyLong_FromVoidPtr(cefEventHandle),
                    pyIsKeyboardShortcutOut)
            cefIsKeyboardShortcut[0] = \
                    <cpp_bool>bool(pyIsKeyboardShortcutOut[0])
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool KeyboardHandler_OnKeyEvent(
        CefRefPtr[CefBrowser] cefBrowser,
        const cef_types.CefKeyEvent& cefEvent,
        cef_types.CefEventHandle cefEventHandle
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef dict pyEvent
    cdef py_bool returnValue
    cdef object callback
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        pyEvent = CefToPyKeyEvent(cefEvent)
        callback = pyBrowser.GetClientCallback("OnKeyEvent")
        if callback:
            returnValue = callback(pyBrowser, pyEvent,
                    <object>PyLong_FromVoidPtr(cefEventHandle))
            return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
