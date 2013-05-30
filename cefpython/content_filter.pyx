# Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# TODO: temporarily removed weakref.WeakValueDictionary()
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
    #cdef object __weakref__ # see g_contentFilters
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
                callback(VoidPtrToStr(data, data_size), pyStreamReader)
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
