# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# TODO: fix CefContentFilter memory corruption and restore weakrefs
# for PyContentFilter object. Right now getting memory corruption
# when CefRefPtr[CefWebURLRequest] is released after the request
# is completed. The memory corruption manifests itself with the
# "Segmentation Fault" error message or the strange "C function 
# name could not be determined in the current C stack frame".
# See this topic on cython-users group:
# https://groups.google.com/d/topic/cython-users/FJZwHhqaCSI/discussion
# After CefWebURLRequest memory corruption is fixed restore weakrefs:
# 1. cdef object g_pyWebRequests = weakref.WeakValueDictionary()
# 2. Add property "cdef object __weakref__" in PyContentFilter
# When using normal dictionary for g_pyWebRequest then the memory
# corruption doesn't occur, but the PyContentFilter and CefContentFilter
# objects are never released, thus you have memory leaks, for now 
# there is no other solution. See this topic on the CEF Forum:
# http://www.magpcss.org/ceforum/viewtopic.php?f=6&t=10711
cdef object g_contentFilters = {}
cdef int g_contentFilterMaxId = 0

# ------------------------------------------------------------------------------
# PyContentFilter
# ------------------------------------------------------------------------------

cdef PyContentFilter GetPyContentFilter(int contentFilterId):
    global g_contentFilters
    if contentFilterId in g_contentFilters:
        return g_contentFilters[contentFilterId]
    return None

cdef class PyContentFilter:
    # cdef object __weakref__ # see g_contentFilters
    cdef int contentFilterId
    cdef CefRefPtr[CefContentFilter] cefContentFilter
    cdef object handler

    def __init__(self):
        global g_contentFilterMaxId
        global g_contentFilters
        g_contentFilterMaxId += 1
        self.contentFilterId = g_contentFilterMaxId
        g_contentFilters[self.contentFilterId] = self
        self.cefContentFilter = (
                <CefRefPtr[CefContentFilter]?>new ContentFilterHandler(
                        self.contentFilterId))

    def SetHandler(self, handler):
        assert handler, "ContentFilterHandler is empty"
        has_OnData = hasattr(handler, "OnData") and (
                callable(getattr(handler, "OnData")))
        has_OnDrain = hasattr(handler, "OnDrain") and (
                callable(getattr(handler, "OnDrain")))
        assert has_OnData, "ContentFilterHandler is missing OnData() method"
        assert has_OnDrain, "ContentFilterHandler is missing OnDrain() method"
        self.handler = handler

    def HasHandler(self):
        return bool(self.handler)

    cdef object GetCallback(self, str funcName):
        if not self.handler:
            return None
        if hasattr(self.handler, funcName) and (
                callable(getattr(self.handler, funcName))):
            return getattr(self.handler, funcName)

    cdef CefRefPtr[CefContentFilter] GetCefContentFilter(self) except *:
        return self.cefContentFilter

# ------------------------------------------------------------------------------
# C++ ContentFilterHandler
# ------------------------------------------------------------------------------

cdef public void ContentFilterHandler_ProcessData(
        int contentFilterId,
        const void* data, 
        int data_size,
        CefRefPtr[CefStreamReader]& substitute_data
        ) except * with gil:
    cdef PyContentFilter contentFilter
    cdef object callback
    cdef PyStreamReader pyStreamReader
    try:
        contentFilter = GetPyContentFilter(contentFilterId)
        if contentFilter:
            callback = contentFilter.GetCallback("OnData")
            if callback:
                pyStreamReader = PyStreamReader()
                callback(VoidPtrToString(data, data_size), pyStreamReader)
                if pyStreamReader.HasCefStreamReader():
                    substitute_data.swap(pyStreamReader.GetCefStreamReader())
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void ContentFilterHandler_Drain(
        int contentFilterId,
        CefRefPtr[CefStreamReader]& remainder
        ) except * with gil:
    cdef PyContentFilter contentFilter
    cdef object callback
    cdef PyStreamReader pyStreamReader
    try:
        contentFilter = GetPyContentFilter(contentFilterId)
        if contentFilter:
            callback = contentFilter.GetCallback("OnDrain")
            if callback:
                pyStreamReader = PyStreamReader()
                callback(pyStreamReader)
                if pyStreamReader.HasCefStreamReader():
                    remainder.swap(pyStreamReader.GetCefStreamReader())
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
