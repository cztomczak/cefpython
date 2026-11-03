# Copyright (c) 2013 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

include "../cefpython.pyx"
include "../browser.pyx"
include "../string_utils.pyx"

cimport cef_types
from libc.stdint cimport uint32_t
from cef_types cimport CefRange

# cef_paint_element_type_t, PaintElementType
PET_VIEW = cef_types.PET_VIEW
PET_POPUP = cef_types.PET_POPUP

# cef_drag_operations_mask_t, DragOperation, DragOperationsMask
DRAG_OPERATION_NONE    = cef_types.DRAG_OPERATION_NONE
DRAG_OPERATION_COPY    = cef_types.DRAG_OPERATION_COPY
DRAG_OPERATION_LINK    = cef_types.DRAG_OPERATION_LINK
DRAG_OPERATION_GENERIC = cef_types.DRAG_OPERATION_GENERIC
DRAG_OPERATION_PRIVATE = cef_types.DRAG_OPERATION_PRIVATE
DRAG_OPERATION_MOVE    = cef_types.DRAG_OPERATION_MOVE
DRAG_OPERATION_DELETE  = cef_types.DRAG_OPERATION_DELETE
DRAG_OPERATION_EVERY   = cef_types.DRAG_OPERATION_EVERY


cdef public cpp_bool RenderHandler_GetRootScreenRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "GetRootScreenRect")
        callback = pyBrowser.GetClientCallback("GetRootScreenRect")
        if callback:
            ret = callback(browser=pyBrowser, rect_out=pyRect)
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

cdef public cpp_bool RenderHandler_GetViewRect(
        CefRefPtr[CefBrowser] cefBrowser,
        CefRect& cefRect
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "GetViewRect")
        callback = pyBrowser.GetClientCallback("GetViewRect")
        if callback:
            ret = callback(browser=pyBrowser, rect_out=pyRect)
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
            # without a default cefRect, pysdl2 example will fail
            # the value is inspired by https://github.com/obsproject/obs-browser/blob/master/browser-client.cpp#L280
            cefRect.x = 0
            cefRect.y = 0
            cefRect.width = 16
            cefRect.height = 16
            return True
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_GetScreenPoint(
        CefRefPtr[CefBrowser] cefBrowser,
        int viewX, int viewY,
        int& screenX, int& screenY
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef list screenCoordinates = []
    cdef py_bool ret
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "GetScreenPoint")
        callback = pyBrowser.GetClientCallback("GetScreenPoint")
        if callback:
            ret = callback(browser=pyBrowser,
                           view_x=viewX,
                           view_y=viewY,
                           screen_coordinates_out=screenCoordinates)
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

cdef public cpp_bool RenderHandler_GetScreenInfo(
        CefRefPtr[CefBrowser] cefBrowser,
        CefScreenInfo& cefScreenInfo
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef dict pyScreenInfo = {}
    cdef py_bool ret
    cdef list pyRect
    cdef double deviceScaleFactor
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "GetScreenInfo")
        callback = pyBrowser.GetClientCallback("GetScreenInfo")
        if not callback:
            return False
        ret = callback(browser=pyBrowser, screen_info_out=pyScreenInfo)
        if not ret:
            return False
        # device_scale_factor is the ratio between physical and logical
        # pixels. On HiDPI displays this is typically 2.0 (1.25/1.5/1.75
        # for fractional scaling). It MUST be > 0 -- a value of 0 will
        # divide-by-zero inside Chromium's compositor. Setting this also
        # scales the OnPaint buffer: a 800x600 view rect with
        # device_scale_factor=2.0 yields a 1600x1200 BGRA buffer.
        if "device_scale_factor" in pyScreenInfo:
            deviceScaleFactor = float(pyScreenInfo["device_scale_factor"])
            assert deviceScaleFactor > 0.0, (
                    "device_scale_factor must be > 0")
            cefScreenInfo.device_scale_factor = <float>deviceScaleFactor
        else:
            cefScreenInfo.device_scale_factor = 1.0
        cefScreenInfo.depth = int(pyScreenInfo.get("depth", 24))
        cefScreenInfo.depth_per_component = int(
                pyScreenInfo.get("depth_per_component", 8))
        cefScreenInfo.is_monochrome = <cpp_bool>bool(
                pyScreenInfo.get("is_monochrome", False))
        # rect/available_rect are in DIP (logical pixels). Leaving them
        # zero-initialized tells CEF to fall back to GetViewRect (see
        # cef_render_handler.h:107).
        if "rect" in pyScreenInfo:
            pyRect = list(pyScreenInfo["rect"])
            assert len(pyRect) == 4, "rect must be [x, y, width, height]"
            cefScreenInfo.rect.x = int(pyRect[0])
            cefScreenInfo.rect.y = int(pyRect[1])
            cefScreenInfo.rect.width = int(pyRect[2])
            cefScreenInfo.rect.height = int(pyRect[3])
        if "available_rect" in pyScreenInfo:
            pyRect = list(pyScreenInfo["available_rect"])
            assert len(pyRect) == 4, (
                    "available_rect must be [x, y, width, height]")
            cefScreenInfo.available_rect.x = int(pyRect[0])
            cefScreenInfo.available_rect.y = int(pyRect[1])
            cefScreenInfo.available_rect.width = int(pyRect[2])
            cefScreenInfo.available_rect.height = int(pyRect[3])
        elif "rect" in pyScreenInfo:
            # Mirror rect into available_rect so popups place correctly
            # when the caller only supplied one.
            cefScreenInfo.available_rect.x = cefScreenInfo.rect.x
            cefScreenInfo.available_rect.y = cefScreenInfo.rect.y
            cefScreenInfo.available_rect.width = cefScreenInfo.rect.width
            cefScreenInfo.available_rect.height = cefScreenInfo.rect.height
        return True
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupShow(
        CefRefPtr[CefBrowser] cefBrowser,
        cpp_bool show
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnPopupShow")
        callback = pyBrowser.GetClientCallback("OnPopupShow")
        if callback:
            callback(browser=pyBrowser, show=show)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPopupSize(
        CefRefPtr[CefBrowser] cefBrowser,
        const CefRect& cefRect
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef list pyRect
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnPopupSize")
        callback = pyBrowser.GetClientCallback("OnPopupSize")
        if callback:
            pyRect = [cefRect.x, cefRect.y, cefRect.width, cefRect.height]
            callback(browser=pyBrowser, rect_out=pyRect)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnPaint(
        CefRefPtr[CefBrowser] cefBrowser,
        cef_types.cef_paint_element_type_t paintElementType,
        cpp_vector[CefRect]& cefDirtyRects,
        const void* cefBuffer,
        int width,
        int height
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    cdef list pyDirtyRects = []
    cdef list pyRect
    # TODO: cefDirtyRects should be const, but const_iterator is
    #       not yet implemented in libcpp.vector.
    cdef cpp_vector[CefRect].iterator iterator
    cdef CefRect cefRect
    cdef PaintBuffer paintBuffer
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnPaint")
        iterator = cefDirtyRects.begin()
        while iterator != cefDirtyRects.end():
            cefRect = deref(iterator)
            pyRect = [cefRect.x, cefRect.y, cefRect.width, cefRect.height]
            pyDirtyRects.append(pyRect)
            preinc(iterator)

        # In CEF 1 width and height were fetched using GetSize(),
        # but in CEF 3 they are passed as arguments to OnPaint().
        # OFF: | (width, height) = pyBrowser.GetSize(paintElementType)

        paintBuffer = CreatePaintBuffer(cefBuffer, width, height)

        callback = pyBrowser.GetClientCallback("OnPaint")
        if callback:
            callback(
                    browser=pyBrowser,
                    element_type=paintElementType,
                    dirty_rects=pyDirtyRects,
                    paint_buffer=paintBuffer,
                    width=width,
                    height=height)
        else:
            return
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnScrollOffsetChanged(
        CefRefPtr[CefBrowser] cefBrowser,
        double x,
        double y
        ) noexcept with gil:
    cdef PyBrowser pyBrowser
    try:
        pyBrowser = GetPyBrowser(cefBrowser, "OnScrollOffsetChanged")
        callback = pyBrowser.GetClientCallback("OnScrollOffsetChanged")
        if callback:
            callback(browser=pyBrowser, x=x, y=y)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public cpp_bool RenderHandler_StartDragging(
        CefRefPtr[CefBrowser] cef_browser,
        CefRefPtr[CefDragData] cef_drag_data,
        uint32_t allowed_ops,
        int x, int y
        ) noexcept with gil:
    cdef PyBrowser browser
    cdef DragData drag_data
    cdef py_bool ret
    try:
        browser = GetPyBrowser(cef_browser, "StartDragging")
        drag_data = DragData_Init(cef_drag_data)
        callback = browser.GetClientCallback("StartDragging")
        if callback:
            ret = callback(
                    browser=browser,
                    drag_data=drag_data,
                    allowed_ops=allowed_ops,
                    x=x,
                    y=y)
            if ret:
                return True
            else:
                return False
        else:
            return False
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_UpdateDragCursor(
        CefRefPtr[CefBrowser] cef_browser,
        uint32_t operation,
        ) noexcept with gil:
    cdef PyBrowser browser
    try:
        browser = GetPyBrowser(cef_browser, "UpdateDragCursor")
        callback = browser.GetClientCallback("UpdateDragCursor")
        if callback:
            callback(browser=browser, operation=operation)
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)

cdef public void RenderHandler_OnTextSelectionChanged(
        CefRefPtr[CefBrowser] cef_browser,
        const CefString& selected_text,
        const CefRange& selected_range
        ) noexcept with gil:
    cdef PyBrowser browser
    try:
        browser = GetPyBrowser(cef_browser, "OnTextSelectionChanged")
        callback = browser.GetClientCallback("OnTextSelectionChanged")
        if callback:
            callback(browser=browser,
                     selected_text=CefToPyString(selected_text),
                     selected_range=[selected_range.from_val,
                                     selected_range.to_val])
    except:
        (exc_type, exc_value, exc_trace) = sys.exc_info()
        sys.excepthook(exc_type, exc_value, exc_trace)
