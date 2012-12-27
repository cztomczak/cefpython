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

cpdef py_void ExceptHook(object type, object value, object traceObject):
    cdef str error = "\n".join(
            traceback.format_exception(type, value, traceObject))
    cdef object file
    with open(GetRealPath("error.log"), "a") as file:
        file.write("\n[%s] %s\n"
                % (time.strftime("%Y-%m-%d %H:%M:%S"), error))
    print("\n"+error+"\n")
    CefQuitMessageLoop()
    CefShutdown()
    # So that "finally" does not execute.
    os._exit(1)

cpdef str GetRealPath(py_string file=None, py_bool encodeUrl=False):
    # This function is defined in 2 files: cefpython.pyx and cefwindow.py, if you
    # make changes edit both files. If file is None return current directory,
    # without trailing slash. encodeUrl param - will call urllib.pathname2url(),
    # only when file is empty (current dir) or is relative path ("test.html",
    # "some/test.html"), we need to encode it before passing to CreateBrowser(),
    # otherwise it is encoded by CEF internally and becomes (chinese characters):
    # >> %EF%BF%97%EF%BF%80%EF%BF%83%EF%BF%A6
    # but should be:
    # >> %E6%A1%8C%E9%9D%A2

    cdef str path

    if file is None:
        file = ""

    if file.find("/") != 0 and file.find("\\") != 0 and not re.search(r"^[a-zA-Z]+:[/\\]?", file):
        # Execute this block only when relative path ("test.html", "some\test.html")
        # or file is empty (current dir).
        # 1. find != 0 >> not starting with / or \ (/ - linux absolute path, \ - just to be sure)
        # 2. not re.search >> not (D:\\ or D:/ or D: or http:// or ftp:// or file://),
        #     "D:" is also valid absolute path ("D:cefpython" in chrome becomes
        #     "file:///D:/cefpython/")

        if hasattr(sys, "frozen"):
            path = os.path.dirname(sys.executable)
        elif "__file__" in globals():
            path = os.path.dirname(os.path.realpath(__file__))
        else:
            path = os.getcwd()

        path = path + os.sep + file
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        # Directory without trailing slash.
        path = re.sub(r"[/\\]+$", "", path)

        if encodeUrl:
            return urllib_pathname2url(path)
        else:
            return path

    return str(file)

IF CEF_VERSION == 1:

    cpdef py_bool IsKeyModifier(int key, int modifiers):
        if key == KEY_NONE:
            # Same as: return (KEY_CTRL & modifiers) != KEY_CTRL
            # and (KEY_ALT & modifiers) != KEY_ALT
            # and (KEY_SHIFT & modifiers) != KEY_SHIFT
            return ((KEY_SHIFT  | KEY_CTRL | KEY_ALT) & modifiers) == 0
        return (key & modifiers) == key
