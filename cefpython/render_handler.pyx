# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# cef_paint_element_type_t, PaintElementType
PET_VIEW = cef_types.PET_VIEW
PET_POPUP = cef_types.PET_POPUP

cdef public cpp_bool RenderHandler_GetViewRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    try:
        print("GetViewRect()")
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_GetScreenRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    try:
        print("GetScreenRect()")
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_GetScreenPoint(
        CefRefPtr[CefBrowser] cefBrowser,
        int viewX, int viewY,
        int& screenX, int& screenY
        ) except * with gil:
    try:
        print("GetScreenPoint()")
        return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupShow(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool show
        ) except * with gil:
    try:
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupSize(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) except * with gil:
    try:
        pass
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
            callback(pyBrowser, paintElementType, pyDirtyRects,
                     paintBuffer)
        else:
            return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_OnCursorChange(
        CefRefPtr[CefBrowser] cefBrowser,
        CefCursorHandle cursor
        ) except * with gil:
    try:
        print("OnCursorChange()")
        pass
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
