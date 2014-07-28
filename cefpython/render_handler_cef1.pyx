# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# cef_paint_element_type_t, PaintElementType
PET_VIEW = cef_types.PET_VIEW
PET_POPUP = cef_types.PET_POPUP

cdef public cpp_bool RenderHandler_GetViewRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("GetViewRect")
        if callback:
            ret = callback(pyBrowser, pyRect)
            if ret:
                assert (pyRect and len(pyRect) == 4), "rectangle not provided"
                cefRect.x = pyRect[0]
                cefRect.y = pyRect[1]
                cefRect.width = pyRect[2]
                cefRect.height = pyRect[3]
                return True
            else:
                return False
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_GetScreenRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("GetScreenRect")
        if callback:
            ret = callback(pyBrowser, pyRect)
            if ret:
                assert (pyRect and len(pyRect) == 4), (
                        "rectangle not provided or invalid")
                cefRect.x = pyRect[0]
                cefRect.y = pyRect[1]
                cefRect.width = pyRect[2]
                cefRect.height = pyRect[3]
                return True
            else:
                return False
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_GetScreenPoint(
        CefRefPtr[CefBrowser] cefBrowser,
        int viewX, int viewY,
        int& screenX, int& screenY
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list screenCoordinates = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("GetScreenPoint")
        if callback:
            ret = callback(pyBrowser, viewX, viewY, screenCoordinates)
            if ret:
                assert (screenCoordinates and len(screenCoordinates) == 2), (
                        "screenCoordinates not provided or invalid")
                (&screenX)[0] = int(screenCoordinates[0])
                (&screenY)[0] = int(screenCoordinates[1])
                return True
            else:
                return False
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupShow(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool show
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnPopupShow")
        if callback:
            callback(pyBrowser, show)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupSize(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnPopupSize")
        if callback:
            pyRect = [cefRect.x, cefRect.y, cefRect.width, cefRect.height]
            callback(pyBrowser, pyRect)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPaint(
        CefRefPtr[CefBrowser] cefBrowser,
        cef_types.cef_paint_element_type_t paintElementType,
        cpp_vector[CefRect]& cefDirtyRects,
        void* cefBuffer
        ) except * with gil:
    cdef PyBrowser pyBrowser
    cdef list pyDirtyRects = []
    cdef list pyRect
    cdef cpp_vector[CefRect].iterator iterator
    cdef CefRect cefRect
    cdef PaintBuffer paintBuffer
    cdef int width
    cdef int height
    try:
        pyBrowser = GetPyBrowser(cefBrowser)

        iterator = cefDirtyRects.begin()
        while iterator != cefDirtyRects.end():
            cefRect = deref(iterator)
            pyRect = [cefRect.x, cefRect.y, cefRect.width, cefRect.height]
            pyDirtyRects.append(pyRect)
            preinc(iterator)

        (width, height) = pyBrowser.GetSize(paintElementType)
        paintBuffer = CreatePaintBuffer(cefBuffer, width, height)

        callback = pyBrowser.GetClientCallback("OnPaint")
        if callback:
            callback(pyBrowser, paintElementType, pyDirtyRects, paintBuffer)
        else:
            return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnCursorChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefCursorHandle cursor
        ) except * with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser)
        callback = pyBrowser.GetClientCallback("OnCursorChange")
        if callback:
            callback(pyBrowser, <int>cursor)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
