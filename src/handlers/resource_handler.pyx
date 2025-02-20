# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
from libc.stdint cimport int64_t
import weakref

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------

# See StoreUserCookieVisitor().
cdef object g_userResourceHandler = weakref.WeakValueDictionary()
cdef int g_userResourceHandlerMaxId = 0


# -----------------------------------------------------------------------------
# ResourceHandler
# -----------------------------------------------------------------------------

cdef py_void ValidateUserResourceHandler(object userResourceHandler):
    cdef list methods = ["ProcessRequest", "GetResponseHeaders",
            "ReadResponse", "Cancel"]
    for method in methods:
        if userResourceHandler and hasattr(userResourceHandler, method)\
                and callable(getattr(userResourceHandler, method)):
            # Okay.
            continue
        else:
            raise Exception("ResourceHandler object is missing method: %s"\
                    % method)

cdef CefRefPtr[CefResourceHandler] CreateResourceHandler(
        object userResourceHandler) except *:
    ValidateUserResourceHandler(userResourceHandler)
    cdef int resourceHandlerId = StoreUserResourceHandler(userResourceHandler)
    cdef CefRefPtr[CefResourceHandler] resourceHandler =\
            <CefRefPtr[CefResourceHandler]?>new ResourceHandler(
                resourceHandlerId)
    return resourceHandler

cdef int StoreUserResourceHandler(object userResourceHandler) except *:
    global g_userResourceHandlerMaxId
    global g_userResourceHandler
    g_userResourceHandlerMaxId += 1
    g_userResourceHandler[g_userResourceHandlerMaxId] = userResourceHandler
    return g_userResourceHandlerMaxId

cdef PyResourceHandler GetPyResourceHandler(int resourceHandlerId):
    global g_userResourceHandler
    cdef object userResourceHandler
    cdef PyResourceHandler pyResourceHandler
    if resourceHandlerId in g_userResourceHandler:
        userResourceHandler = g_userResourceHandler[resourceHandlerId]
        pyResourceHandler = PyResourceHandler(userResourceHandler)
        return pyResourceHandler

cdef class PyResourceHandler:
    cdef object userResourceHandler

    def __init__(self, object userResourceHandler):
        self.userResourceHandler = userResourceHandler

    cdef object GetCallback(self, str funcName):
        if self.userResourceHandler and (
                hasattr(self.userResourceHandler, funcName) and (
                    callable(getattr(self.userResourceHandler, funcName)))):
            return getattr(self.userResourceHandler, funcName)

# ------------------------------------------------------------------------------
# ResourceHandler callbacks
# ------------------------------------------------------------------------------

cdef public cpp_bool ResourceHandler_ProcessRequest(
        int resourceHandlerId,
        CefRefPtr[CefRequest] cefRequest,
        CefRefPtr[CefCallback] cefCallback
        ) except * with gil:
    cdef PyResourceHandler pyResourceHandler
    cdef object userCallback
    cdef py_bool returnValue
    cdef PyRequest pyRequest
    cdef PyCallback pyCallback
    try:
        assert IsThread(TID_IO), "Must be called on the IO thread"
        pyResourceHandler = GetPyResourceHandler(resourceHandlerId)
        pyRequest = CreatePyRequest(cefRequest)
        pyCallback = CreatePyCallback(cefCallback)
        if pyResourceHandler:
            userCallback = pyResourceHandler.GetCallback("ProcessRequest")
            if userCallback:
                returnValue = userCallback(
                        request=pyRequest,
                        callback=pyCallback)
                return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void ResourceHandler_GetResponseHeaders(
        int resourceHandlerId,
        CefRefPtr[CefResponse] cefResponse,
        int64_t& cefResponseLength,
        CefString& cefRedirectUrl
        ) except * with gil:
    cdef PyResourceHandler pyResourceHandler
    cdef object userCallback
    cdef py_bool returnValue
    cdef PyResponse pyResponse
    cdef list responseLengthOut
    cdef list redirectUrlOut
    try:
        assert IsThread(TID_IO), "Must be called on the IO thread"
        pyResourceHandler = GetPyResourceHandler(resourceHandlerId)
        pyResponse = CreatePyResponse(cefResponse)
        responseLengthOut = [cefResponseLength]
        redirectUrlOut = [CefToPyString(cefRedirectUrl)]
        if pyResourceHandler:
            userCallback = pyResourceHandler.GetCallback("GetResponseHeaders")
            if userCallback:
                returnValue = userCallback(pyResponse, responseLengthOut,
                        redirectUrlOut)
                (&cefResponseLength)[0] = <int64_t>responseLengthOut[0]
                if redirectUrlOut[0]:
                    PyToCefString(redirectUrlOut[0], cefRedirectUrl)
                return
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool ResourceHandler_ReadResponse(
        int resourceHandlerId,
        void* cefDataOut,
        int bytesToRead,
        int& cefBytesRead,
        CefRefPtr[CefCallback] cefCallback
        ) except * with gil:
    cdef PyResourceHandler pyResourceHandler
    cdef object userCallback
    cdef py_bool returnValue
    cdef list dataOut
    cdef list bytesReadOut
    cdef PyCallback pyCallback
    cdef char* tempData
    cdef int tempDataLength
    cdef int pyBytesRead
    try:
        assert IsThread(TID_IO), "Must be called on the IO thread"
        pyResourceHandler = GetPyResourceHandler(resourceHandlerId)
        dataOut = [""]
        bytesReadOut = [0]
        pyCallback = CreatePyCallback(cefCallback)
        if pyResourceHandler:
            userCallback = pyResourceHandler.GetCallback("ReadResponse")
            if userCallback:
                returnValue = userCallback(
                        data_out=dataOut,
                        bytes_to_read=bytesToRead,
                        bytes_read_out=bytesReadOut,
                        callback=pyCallback)
                pyBytesRead = int(bytesReadOut[0])
                if dataOut[0] and IsString(dataOut[0]):
                    # The tempData pointer is tied to the lifetime 
                    # of dataOut[0] string.
                    tempData = dataOut[0]
                    memcpy(cefDataOut, tempData, len(dataOut[0]))
                    assert pyBytesRead >= 0, "bytesReadOut < 0"
                    (&cefBytesRead)[0] = pyBytesRead
                    # True should be returned now.
                else:
                    (&cefBytesRead)[0] = 0
                    # Either:
                    # 1. True should be returned and callback.Continue()
                    #    called at a later time.
                    # 2. False returned to indicate response completion.
                return bool(returnValue)
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void ResourceHandler_Cancel(
        int resourceHandlerId
        ) except * with gil:
    cdef PyResourceHandler pyResourceHandler
    cdef object userCallback
    try:
        assert IsThread(TID_IO), "Must be called on the IO thread"
        pyResourceHandler = GetPyResourceHandler(resourceHandlerId)
        if pyResourceHandler:
            userCallback = pyResourceHandler.GetCallback("Cancel")
            if userCallback:
                userCallback()
                return
        return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)