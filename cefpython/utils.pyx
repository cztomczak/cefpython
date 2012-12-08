# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

TID_UI = cef_types.TID_UI
TID_IO = cef_types.TID_IO
TID_FILE = cef_types.TID_FILE

cpdef py_bool IsCurrentThread(int threadID):

    return bool(CefCurrentlyOn(<CefThreadId>threadID))

cpdef object Debug(str msg):

    if not g_debug:
        return
    msg = "cefpython: "+str(msg)
    print(msg)
    with open(GetRealPath("debug.log"), "a") as file:
        file.write(msg+"\n")

cpdef py_bool IsWindowHandle(int windowHandle):

    IF UNAME_SYSNAME == "Windows":
        return bool(IsWindow(<HWND>windowHandle))
    return False

cpdef str GetSystemError():

    IF UNAME_SYSNAME == "Windows":
        cdef DWORD errorCode = GetLastError()
        return "Error Code = %d" % (errorCode)
    return ""
