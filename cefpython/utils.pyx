# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

TID_UI = cef_types.TID_UI
TID_IO = cef_types.TID_IO
TID_FILE = cef_types.TID_FILE

cpdef py_bool IsThread(int threadID):
    return bool(CefCurrentlyOn(<CefThreadId>threadID))

cpdef object Debug(str msg):
    if not g_debug:
        return
    msg = "cefpython: "+str(msg)
    print(msg)
    if g_debugFile:
        with open(g_debugFile, "a") as file:
            file.write(msg+"\n")

cpdef str GetSystemError():
    IF UNAME_SYSNAME == "Windows":
        cdef DWORD errorCode = GetLastError()
        return "Error Code = %d" % (errorCode)
    return ""

cpdef str GetNavigateUrl(py_string url):
    # Only local file paths: some.html, some/some.html, D:\, /var, file://
    if re.search(r"^file:", url, re.I) or re.search(r"^[a-zA-Z]:", url) or (
            not re.search(r"^[\w-]+:", url)):
        # Need to encode chinese characters in local file paths,
        # otherwise CEF will try to encode them by itself, but it
        # won't work with python's string encoding, will encode as:
        # >> %EF%BF%97%EF%BF%80%EF%BF%83%EF%BF%A6
        # but should be:
        # >> %E6%A1%8C%E9%9D%A2
        url = urllib_pathname2url(url)
    return str(url)

IF CEF_VERSION == 1:

    cpdef py_bool IsKeyModifier(int key, int modifiers):
        if key == KEY_NONE:
            # Same as: return (KEY_CTRL & modifiers) != KEY_CTRL
            # and (KEY_ALT & modifiers) != KEY_ALT
            # and (KEY_SHIFT & modifiers) != KEY_SHIFT
            return ((KEY_SHIFT  | KEY_CTRL | KEY_ALT) & modifiers) == 0
        return (key & modifiers) == key
