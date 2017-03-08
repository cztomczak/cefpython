# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "cefpython.pyx"

import os
import platform
import re
import traceback
import time
import codecs


cpdef str GetModuleDirectory():
    """Get path to the cefpython module (so/pyd)."""
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
        path = re.sub(r"[/\\]+", re.escape(os.sep), path)
    path = re.sub(r"[/\\]+$", "", path)
    return os.path.abspath(path)

g_GetAppPath_dir = None

cpdef str GetAppPath(file=None):
    """Get application path."""
    # On Windows after downloading file and calling Browser.GoForward(),
    # current working directory is set to %UserProfile%.
    # Calling os.path.dirname(os.path.realpath(__file__))
    # returns for eg. "C:\Users\user\Downloads". A solution
    # is to cache path on first call.
    if not g_GetAppPath_dir:
        if hasattr(sys, "frozen"):
            adir = os.path.dirname(sys.executable)
        else:
            adir = os.getcwd()
        global g_GetAppPath_dir
        g_GetAppPath_dir = adir
    # If file is None return current directory without trailing slash.
    if file is None:
        file = ""
    # Only when relative path.
    if not file.startswith("/") and not file.startswith("\\") and (
            not re.search(r"^[\w-]+:", file)):
        path = g_GetAppPath_dir + os.sep + file
        if platform.system() == "Windows":
            path = re.sub(r"[/\\]+", re.escape(os.sep), path)
        path = re.sub(r"[/\\]+$", "", path)
        return path
    return str(file)


cpdef py_void ExceptHook(excType, excValue, traceObject):
    """Global except hook to exit app cleanly on error."""
    # This hook does the following: in case of exception write it to
    # the "error.log" file, display it to the console, shutdown CEF
    # and exit application immediately by ignoring "finally" (_exit()).
    print("[CEF Python] ExceptHook: catched exception, will shutdown CEF now")
    QuitMessageLoop()
    Shutdown()
    print("[CEF Python] ExceptHook: see the catched exception below:")
    errorMsg = "".join(traceback.format_exception(excType, excValue,
            traceObject))
    errorFile = GetAppPath("error.log")
    try:
        appEncoding = g_applicationSettings["string_encoding"]
    except:
        appEncoding = "utf-8"
    if type(errorMsg) == bytes:
        errorMsg = errorMsg.decode(encoding=appEncoding, errors="replace")
    try:
        with codecs.open(errorFile, mode="a", encoding=appEncoding) as fp:
            fp.write("\n[%s] %s\n" % (
                    time.strftime("%Y-%m-%d %H:%M:%S"), errorMsg))
    except:
        print("[CEF Python] WARNING: failed writing to error file: %s" % (
                errorFile))
    # Convert error message to ascii before printing, otherwise
    # you may get error like this:
    # | UnicodeEncodeError: 'charmap' codec can't encode characters
    errorMsg = errorMsg.encode("ascii", errors="replace")
    errorMsg = errorMsg.decode("ascii", errors="replace")
    print("\n"+errorMsg)
    # noinspection PyProtectedMember
    os._exit(1)
