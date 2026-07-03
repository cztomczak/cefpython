// Copyright (c) 2016 CEF Python, see the Authors file.
// All rights reserved. Licensed under BSD 3-clause license.
// Project website: https://github.com/cztomczak/cefpython

#include "context_menu_handler.h"
#include "include/base/cef_logging.h"

#define _MENU_ID_DEVTOOLS                         MENU_ID_USER_FIRST + 1
#define _MENU_ID_RELOAD_PAGE                      MENU_ID_USER_FIRST + 2
#define _MENU_ID_OPEN_PAGE_IN_EXTERNAL_BROWSER    MENU_ID_USER_FIRST + 3
#define _MENU_ID_OPEN_FRAME_IN_EXTERNAL_BROWSER   MENU_ID_USER_FIRST + 4

// Forward declarations
void OpenInExternalBrowser(const std::string& url);


void ContextMenuHandler::OnBeforeContextMenu(
                                        CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefContextMenuParams> params,
                                        CefRefPtr<CefMenuModel> model)
{
    bool enabled = ApplicationSettings_GetBoolFromDict(
            "context_menu", "enabled");
    bool navigation = ApplicationSettings_GetBoolFromDict(
            "context_menu", "navigation");
    bool print = ApplicationSettings_GetBoolFromDict(
            "context_menu", "print");
    bool view_source = ApplicationSettings_GetBoolFromDict(
            "context_menu", "view_source");
    bool external_browser = ApplicationSettings_GetBoolFromDict(
            "context_menu", "external_browser");
    bool devtools = ApplicationSettings_GetBoolFromDict(
            "context_menu", "devtools");

    if (!enabled) {
        model->Clear();
        return;
    }
    if (!navigation && model->IsVisible(MENU_ID_BACK)
                    && model->IsVisible(MENU_ID_FORWARD)) {
        model->Remove(MENU_ID_BACK);
        model->Remove(MENU_ID_FORWARD);
        // Remove separator
        if (model->GetTypeAt(0) == MENUITEMTYPE_SEPARATOR) {
            model->RemoveAt(0);
        }
    }
    if (!print) {
        model->Remove(MENU_ID_PRINT);
    }
    if (!view_source) {
        model->Remove(MENU_ID_VIEW_SOURCE);
    }
    if (!params->IsEditable() && params->GetSelectionText().empty()
                && (params->GetPageUrl().length()
                    || params->GetFrameUrl().length())) {
        if (external_browser) {
            model->AddItem(_MENU_ID_OPEN_PAGE_IN_EXTERNAL_BROWSER,
                           "Open in external browser");
            if (params->GetFrameUrl().length()
                        && params->GetPageUrl() != params->GetFrameUrl()) {
                model->AddItem(_MENU_ID_OPEN_FRAME_IN_EXTERNAL_BROWSER,
                               "Open frame in external browser");
            }
        }
        if (navigation) {
            model->InsertItemAt(2, _MENU_ID_RELOAD_PAGE, "Reload");
        }
        if (devtools) {
            model->AddSeparator();
            model->AddItem(_MENU_ID_DEVTOOLS, "Developer Tools");
        }
    }
}


bool ContextMenuHandler::OnContextMenuCommand(
                                        CefRefPtr<CefBrowser> browser,
                                        CefRefPtr<CefFrame> frame,
                                        CefRefPtr<CefContextMenuParams> params,
                                        int command_id,
                                        EventFlags event_flags)
{
    if (command_id == _MENU_ID_OPEN_PAGE_IN_EXTERNAL_BROWSER) {
        #if defined(OS_WIN)
        ShellExecuteA(0, "open", params->GetPageUrl().ToString().c_str(),
                      0, 0, SW_SHOWNORMAL);
        #elif defined(OS_LINUX)
        OpenInExternalBrowser(params->GetPageUrl().ToString());
        #endif // OS_WIN
        return true;
    } else if (command_id == _MENU_ID_OPEN_FRAME_IN_EXTERNAL_BROWSER) {
        #if defined(OS_WIN)
        ShellExecuteA(0, "open", params->GetFrameUrl().ToString().c_str(),
                      0, 0, SW_SHOWNORMAL);
        #elif defined(OS_LINUX)
        OpenInExternalBrowser(params->GetFrameUrl().ToString());
        #endif // OS_WIN
        return true;
    } else if (command_id == _MENU_ID_RELOAD_PAGE) {
        browser->ReloadIgnoreCache();
        return true;
    } else if (command_id == _MENU_ID_DEVTOOLS) {
        PyBrowser_ShowDevTools(browser);
        return true;
    }
    return false;
}


void ContextMenuHandler::OnContextMenuDismissed(CefRefPtr<CefBrowser> browser,
                                                CefRefPtr<CefFrame> frame)
{
    // PASS
}


// ----------------------------------------------------------------------------
// Context menu utility functions
// ----------------------------------------------------------------------------


#if defined(OS_LINUX)
void OpenInExternalBrowser(const std::string& url)
{
    // Linux equivalent of ShellExecute

    if (url.empty()) {
        LOG(ERROR) << "[Browser process] OpenInExternalBrowser():"
                      " url is empty";
        return;
    }
    std::string msg = "[Browser process] OpenInExternalBrowser(): url=";
    msg.append(url.c_str());
    LOG(INFO) << msg.c_str();

    // xdg-open is a desktop-independent tool for running
    // default applications. Installed by default on Ubuntu.
    // xdg-open process is running in the backround until
    // cefpython app closes.
    std::string prog = "xdg-open";

    // Using system() opens up for bugs and exploits, not
    // recommended.

    // Fork yourself and run in parallel, do not block the
    // current proces.
    char *args[3];
    args[0] = (char*) prog.c_str();
    args[1] = (char*) url.c_str();
    args[2] = 0;
    pid_t pid = fork();
    if (!pid) {
        execvp(prog.c_str(), args);
    }
}
#endif
