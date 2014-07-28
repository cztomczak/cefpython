# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

class Drag:
    Operation = {
        "None": DRAG_OPERATION_NONE,
        "Copy": DRAG_OPERATION_COPY,
        "Link": DRAG_OPERATION_LINK,
        "Generic": DRAG_OPERATION_GENERIC,
        "Private": DRAG_OPERATION_PRIVATE,
        "Move" : DRAG_OPERATION_MOVE,
        "Delete": DRAG_OPERATION_DELETE,
        "Every": DRAG_OPERATION_EVERY,
    }

cdef public cpp_bool DragHandler_OnDragStart(
        CefRefPtr[CefBrowser] browser,
        CefRefPtr[CefDragData] dragData,
        cef_drag_operations_mask_t mask
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyDragData pyDragData
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(browser)
        pyDragData = CreatePyDragData(dragData)
        callback = pyBrowser.GetClientCallback("OnDragStart")
        if callback:
            # The max value for mask is UINT_MAX.
            ret = callback(pyBrowser, pyDragData, <long>mask)
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool DragHandler_OnDragEnter(
        CefRefPtr[CefBrowser] browser,
        CefRefPtr[CefDragData] dragData,
        cef_drag_operations_mask_t mask
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef PyDragData pyDragData
    cdef object callback
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(browser)
        pyDragData = CreatePyDragData(dragData)
        callback = pyBrowser.GetClientCallback("OnDragEnter")
        if callback:
            # The max value for mask is UINT_MAX.
            ret = callback(pyBrowser, pyDragData, <long>mask)
            return bool(ret)
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
