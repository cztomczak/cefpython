// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "drag_handler.h"


bool DragHandler::OnDragEnter(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefDragData> dragData,
                     cef_drag_operations_mask_t mask)
{
    REQUIRE_UI_THREAD();
    return DragHandler_OnDragEnter(browser,dragData,mask);
}
