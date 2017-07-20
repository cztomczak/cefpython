// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_drag_handler.h"


class DragHandler : public CefDragHandler
{
public:
    DragHandler(){}
    virtual ~DragHandler(){}

    bool OnDragEnter(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefDragData> dragData,
                     cef_drag_operations_mask_t mask) override;



private:
    IMPLEMENT_REFCOUNTING(DragHandler);
};
