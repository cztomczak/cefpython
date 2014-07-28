# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# ------------------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------------------

cdef object g_userDownloadHandlers = weakref.WeakValueDictionary()
cdef int g_userDownloadHandlerMaxId = 0

# ------------------------------------------------------------------------------
# PyDownloadHandler
# ------------------------------------------------------------------------------

cdef CefRefPtr[CefDownloadHandler] StoreUserDownloadHandler(
        object userDownloadHandler) except *:
    ValidateUserDownloadHandler(userDownloadHandler)
    global g_userDownloadHandlerMaxId
    global g_userDownloadHandlers
    g_userDownloadHandlerMaxId += 1
    g_userDownloadHandlers[g_userDownloadHandlerMaxId] = userDownloadHandler
    cdef CefRefPtr[CefDownloadHandler] downloadHandler = (
            <CefRefPtr[CefDownloadHandler]?>new DownloadHandler(
                    g_userDownloadHandlerMaxId))
    return downloadHandler

cdef object GetPyDownloadHandler(int downloadHandlerId):
    global g_userDownloadHandlers
    cdef object userDownloadHandler
    cdef PyDownloadHandler pyDownloadHandler
    if downloadHandlerId in g_userDownloadHandlers:
        userDownloadHandler = g_userDownloadHandlers[downloadHandlerId]
        pyDownloadHandler = PyDownloadHandler(userDownloadHandler)
        return pyDownloadHandler

cdef void ValidateUserDownloadHandler(object handler) except *:
    assert handler, "DownloadHandler is empty"
    has_OnData = hasattr(handler, "OnData") and (
            callable(getattr(handler, "OnData")))
    has_OnComplete = hasattr(handler, "OnComplete") and (
            callable(getattr(handler, "OnComplete")))
    assert has_OnData, "DownloadHandler is missing OnData() method"
    assert has_OnComplete, "DownloadHandler is missing OnComplete() method"

cdef class PyDownloadHandler:
    cdef object userDownloadHandler

    def __init__(self, object userDownloadHandler):
        assert not isinstance(userDownloadHandler, int), (
                "DownloadHandler is not a valid object")
        self.userDownloadHandler = userDownloadHandler

    cdef object GetCallback(self, str funcName):
        if self.userDownloadHandler and (
                hasattr(self.userDownloadHandler, funcName) and (
                callable(getattr(self.userDownloadHandler, funcName)))):
            return getattr(self.userDownloadHandler, funcName)

# ------------------------------------------------------------------------------
# C++ DownloadHandler
# ------------------------------------------------------------------------------

cdef public cpp_bool DownloadHandler_ReceivedData(
        int downloadHandlerId,
        void* data,
        int data_size
        ) except * with gil:
    cdef PyDownloadHandler pyDownloadHandler
    cdef object callback
    cdef py_bool ret
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        pyDownloadHandler = GetPyDownloadHandler(downloadHandlerId)
        if pyDownloadHandler:
            callback = pyDownloadHandler.GetCallback("OnData")
            if callback:
                ret = callback(VoidPtrToString(data, data_size))
                return bool(ret)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void DownloadHandler_Complete(
        int downloadHandlerId
        ) except * with gil:
    cdef PyDownloadHandler pyDownloadHandler
    cdef object callback
    try:
        assert IsThread(TID_UI), "Must be called on the UI thread"
        pyDownloadHandler = GetPyDownloadHandler(downloadHandlerId)
        if pyDownloadHandler:
            callback = pyDownloadHandler.GetCallback("OnComplete")
            if callback:
                callback()
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
