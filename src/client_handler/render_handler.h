// Copyright (c) 2013 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "common/cefpython_public_api.h"
#include "include/cef_render_handler.h"
#include "accessibility_handler.h"


class RenderHandler : public CefRenderHandler,
                      public AccessibilityHandler
{
public:
    RenderHandler(){}
    virtual ~RenderHandler(){}

    CefRefPtr<CefAccessibilityHandler> GetAccessibilityHandler()
                override {
        return this;
    }

    bool GetRootScreenRect(CefRefPtr<CefBrowser> browser,
                           CefRect& rect) override;

    void GetViewRect(CefRefPtr<CefBrowser> browser,
                     CefRect& rect) override;

    bool GetScreenPoint(CefRefPtr<CefBrowser> browser,
                        int viewX,
                        int viewY,
                        int& screenX,
                        int& screenY) override;

    bool GetScreenInfo(CefRefPtr<CefBrowser> browser,
                       CefScreenInfo& screen_info) override;

    void OnPopupShow(CefRefPtr<CefBrowser> browser,
                     bool show) override;

    void OnPopupSize(CefRefPtr<CefBrowser> browser,
                     const CefRect& rect) override;

    void OnPaint(CefRefPtr<CefBrowser> browser,
                 PaintElementType type,
                 const RectList& dirtyRects,
                 const void* buffer,
                 int width, int height) override;

    void OnScrollOffsetChanged(CefRefPtr<CefBrowser> browser,
                               double x,
                               double y) override;

    bool StartDragging(CefRefPtr<CefBrowser> browser,
                       CefRefPtr<CefDragData> drag_data,
                       cef_drag_operations_mask_t allowed_ops,
                       int x, int y) override;

    void UpdateDragCursor(CefRefPtr<CefBrowser> browser,
                          cef_drag_operations_mask_t operation) override;

    void OnTextSelectionChanged(CefRefPtr<CefBrowser> browser,
                                const CefString& selected_text,
                                const CefRange& selected_range) override;

private:
    IMPLEMENT_REFCOUNTING(RenderHandler);
};
