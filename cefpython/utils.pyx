# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

TID_UI = cef_types.TID_UI
TID_IO = cef_types.TID_IO
TID_FILE = cef_types.TID_FILE

cpdef py_bool IsString(object maybeString):
    # In Python 2.7 string types are: 1) str/bytes 2) unicode.
    # In Python 3 string types are: 1) bytes 2) str
    if type(maybeString) == bytes or type(maybeString) == str \
            or (PY_MAJOR_VERSION < 3 and type(maybeString) == unicode):
        return True
    return False

cpdef py_bool IsThread(int threadID):
    return bool(CefCurrentlyOn(<CefThreadId>threadID))

# TODO: this function needs to accept unicode strings, use the
#       logic from wxpython.py/ExceptHook to handle printing
#       unicode strings and writing them to file (codecs.open).
#       This change is required to work with Cython 0.20.

cpdef object Debug(str msg):
    if not g_debug:
        return
    msg = "[CEF Python] "+str(msg)
    print(msg)
    if g_debugFile:
        try:
            with open(g_debugFile, "a") as file:
                file.write(msg+"\n")
        except:
            print("[CEF Python] WARNING: failed writing to debug file: %s" % (
                    g_debugFile))


cpdef str GetSystemError():
    IF UNAME_SYSNAME == "Windows":
        cdef DWORD errorCode = GetLastError()
        return "Error Code = %d" % (errorCode)
    ELSE:
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
        url = re.sub("^file%3A", "file:", url)
        # Allow hash when loading urls. The pathname2url function
        # replaced hashes with "%23" (Issue 114).
        url = url.replace("%23", "#")
    return str(url)

IF CEF_VERSION == 1:
    cpdef py_bool IsKeyModifier(int key, int modifiers):
        if key == KEY_NONE:
            # Same as: return (KEY_CTRL & modifiers) != KEY_CTRL
            # and (KEY_ALT & modifiers) != KEY_ALT
            # and (KEY_SHIFT & modifiers) != KEY_SHIFT
            return ((KEY_SHIFT  | KEY_CTRL | KEY_ALT) & modifiers) == 0
        return (key & modifiers) == key

cpdef str GetModuleDirectory():
    import re, os, platform
    if platform.system() == "Linux" and os.getenv("CEFPYTHON3_PATH"):
        # cefpython3 package __init__.py sets CEFPYTHON3_PATH.
        # When cefpython3 is installed as debian package, this
        # env variable is the only way of getting valid path.
        return os.getenv("CEFPYTHON3_PATH")
    if hasattr(sys, "frozen"):
        path = os.path.dirname(sys.executable)
    elif "__file__" in globals():
        path = os.path.dirname(os.path.realpath(__file__))
    else:
        path = os.getcwd()
    if platform.system() == "Windows":
        # On linux this regexp would give:
        # "\/home\/czarek\/cefpython\/cefpython\/cef1\/linux\/binaries"
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
    path = re.sub(r"[/\\]+$", "", path)
    return str(path)
