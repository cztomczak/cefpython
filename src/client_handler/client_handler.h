// Copyright (c) 2012 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

// ClientHandler code is running only in the Browser process.

#pragma once

#if defined(_WIN32)
#include <stdint.h>
#endif

#include "context_menu_handler.h"
#include "dialog_handler.h"
#include "display_handler.h"
#include "download_handler.h"
#include "focus_handler.h"
#include "js_dialog_handler.h"
#include "keyboard_handler.h"
#include "lifespan_handler.h"
#include "load_handler.h"
#include "render_handler.h"
#include "request_handler.h"


class ClientHandler : public CefClient,
                      public ContextMenuHandler,
                      public DialogHandler,
                      public DisplayHandler,
                      public DownloadHandler,
                      public FocusHandler,
                      public JSDialogHandler,
                      public KeyboardHandler,
                      public LifespanHandler,
                      public LoadHandler,
                      public RenderHandler,
                      public RequestHandler
{
public:
    ClientHandler(){}
    virtual ~ClientHandler(){}

    CefRefPtr<CefContextMenuHandler> GetContextMenuHandler() override {
        return this;
    }

#if defined(OS_LINUX)
    CefRefPtr<CefDialogHandler> GetDialogHandler() override {
        return this;
    }
#endif

    CefRefPtr<CefDisplayHandler> GetDisplayHandler() override {
        return this;
    }

    CefRefPtr<CefDownloadHandler> GetDownloadHandler() override {
        return this;
    }

    CefRefPtr<CefFocusHandler> GetFocusHandler() override {
        return this;
    }

    CefRefPtr<CefJSDialogHandler> GetJSDialogHandler() override {
        return this;
    }

    CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() override {
        return this;
    }

    CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() override {
        return this;
    }

    CefRefPtr<CefLoadHandler> GetLoadHandler() override {
        return this;
    }

    CefRefPtr<CefRenderHandler> GetRenderHandler() override {
        return this;
    }

    CefRefPtr<CefRequestHandler> GetRequestHandler() override {
        return this;
    }

    bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  CefProcessId source_process,
                                  CefRefPtr<CefProcessMessage> message
                                  ) override;

private:
  IMPLEMENT_REFCOUNTING(ClientHandler);
};
