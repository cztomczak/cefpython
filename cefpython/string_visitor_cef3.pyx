# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# -----------------------------------------------------------------------------
# PyStringVisitor
# -----------------------------------------------------------------------------

cdef object g_userStringVisitors = weakref.WeakValueDictionary()
cdef int g_userStringVisitorMaxId = 0

cdef int StoreUserStringVisitor(object userStringVisitor) except *:
    global g_userStringVisitorMaxId
    global g_userStringVisitors
    g_userStringVisitorMaxId += 1
    g_userStringVisitors[g_userStringVisitorMaxId] = userStringVisitor
    return g_userStringVisitorMaxId

cdef PyStringVisitor GetUserStringVisitor(int stringVisitorId):
    global g_userStringVisitors
    cdef object userStringVisitor
    cdef PyStringVisitor pyStringVisitor
    if stringVisitorId in g_userStringVisitors:
        userStringVisitor = g_userStringVisitors[stringVisitorId]
        pyStringVisitor = PyStringVisitor(userStringVisitor)
        return pyStringVisitor

cdef class PyStringVisitor:
    cdef object userStringVisitor

    def __init__(self, object userStringVisitor):
        self.userStringVisitor = userStringVisitor

    cdef object GetCallback(self, str funcName):
        if self.userStringVisitor and (
                hasattr(self.userStringVisitor, funcName) and (
                callable(getattr(self.userStringVisitor, funcName)))):
            return getattr(self.userStringVisitor, funcName)

# -----------------------------------------------------------------------------
# C++ StringVisitor
# -----------------------------------------------------------------------------

cdef CefRefPtr[CefStringVisitor] CreateStringVisitor(
        object userStringVisitor) except *:
    if not userStringVisitor:
        raise Exception("userStringVisitor object missing")
    if not hasattr(userStringVisitor, "Visit"):
        raise Exception("userStringVisitor object is missing Visit() method")
    cdef int stringVisitorId = StoreUserStringVisitor(userStringVisitor)
    cdef CefRefPtr[CefStringVisitor] cefStringVisitor = (
            <CefRefPtr[CefStringVisitor]?>new StringVisitor(stringVisitorId))
    return cefStringVisitor

cdef public void StringVisitor_Visit(
        int stringVisitorId,
        const CefString& string
        ) except * with gil:
    cdef str pyString
    cdef PyStringVisitor userStringVisitor
    cdef object callback
    try:
        pyString = CefToPyString(string)
        userStringVisitor = GetUserStringVisitor(stringVisitorId)
        if userStringVisitor:
            callback = userStringVisitor.GetCallback("Visit")
            if callback:
                callback(pyString)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
