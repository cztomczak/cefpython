// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

// NOTE: clienthandler code is running only in the BROWSER PROCESS.
//       cefpythonapp code is running in both BROWSER PROCESS and subprocess
//       (see the subprocess/ directory).

#include "client_handler.h"
#include "cefpython_public_api.h"
#include "DebugLog.h"
#include "LOG_DEBUG.h"

#if defined(OS_WIN)
#include <Shellapi.h>
#pragma comment(lib, "Shell32.lib")
#include "dpi_aware.h"
#elif defined(OS_LINUX)
#include <unistd.h>
#include <stdlib.h>
#endif

// ----------------------------------------------------------------------------
// Linux equivalent of ShellExecute
// ----------------------------------------------------------------------------

#if defined(OS_LINUX)
void OpenInExternalBrowser(const std::string& url)
{
    if (url.empty()) {
        DebugLog("Browser: OpenInExternalBrowser() FAILED: url is empty");
        return;
    }
    std::string msg = "Browser: OpenInExternalBrowser(): url=";
    msg.append(url.c_str());
    DebugLog(msg.c_str());

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

// ----------------------------------------------------------------------------
// CefClient
// ----------------------------------------------------------------------------

bool ClientHandler::OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message) {
    if (source_process != PID_RENDERER) {
        return false;
    }
    std::string messageName = message->GetName().ToString();
    std::string logMessage = "Browser: OnProcessMessageReceived(): ";
    logMessage.append(messageName.c_str());
    DebugLog(logMessage.c_str());
    if (messageName == "OnContextCreated") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 1 && arguments->GetType(0) == VTYPE_INT) {
            int64 frameId = arguments->GetInt(0);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8ContextHandler_OnContextCreated(browser, frame);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments" \
                    ", messageName = OnContextCreated");
            return false;
        }
    } else if (messageName == "OnContextReleased") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 2 \
                && arguments->GetType(0) == VTYPE_INT \
                && arguments->GetType(1) == VTYPE_INT) {
            int browserId = arguments->GetInt(0);
            int64 frameId = arguments->GetInt(1);
            V8ContextHandler_OnContextReleased(browserId, frameId);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments" \
                    ", messageName = OnContextReleased");
            return false;
        }
    } else if (messageName == "V8FunctionHandler::Execute") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 3
                && arguments->GetType(0) == VTYPE_INT // frameId
                && arguments->GetType(1) == VTYPE_STRING // functionName
                && arguments->GetType(2) == VTYPE_LIST) { // functionArguments
            int64 frameId = arguments->GetInt(0);
            CefString functionName = arguments->GetString(1);
            CefRefPtr<CefListValue> functionArguments = arguments->GetList(2);
            CefRefPtr<CefFrame> frame = browser->GetFrame(frameId);
            V8FunctionHandler_Execute(browser, frame, functionName, functionArguments);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments" \
                    ", messageName = V8FunctionHandler::Execute");
            return false;
        }
    } else if (messageName == "ExecutePythonCallback") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 2
                && arguments->GetType(0) == VTYPE_INT // callbackId
                && arguments->GetType(1) == VTYPE_LIST) { // functionArguments
            int callbackId = arguments->GetInt(0);
            CefRefPtr<CefListValue> functionArguments = arguments->GetList(1);
            ExecutePythonCallback(browser, callbackId, functionArguments);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments" \
                    ", messageName = ExecutePythonCallback");
            return false;
        }
    } else if (messageName == "RemovePythonCallbacksForFrame") {
        CefRefPtr<CefListValue> arguments = message->GetArgumentList();
        if (arguments->GetSize() == 1 && arguments->GetType(0) == VTYPE_INT) {
            int frameId = arguments->GetInt(0);
            RemovePythonCallbacksForFrame(frameId);
            return true;
        } else {
            DebugLog("Browser: OnProcessMessageReceived(): invalid arguments" \
                    ", messageName = ExecutePythonCallback");
            return false;
        }
    }
    return false;
}

// ----------------------------------------------------------------------------
// CefLifeSpanHandler
// ----------------------------------------------------------------------------

bool ClientHandler::OnBeforePopup(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefFrame> frame,
                         const CefString& target_url,
                         const CefString& target_frame_name,
                         WindowOpenDisposition target_disposition,
                         bool user_gesture,
                         const CefPopupFeatures& popupFeatures,
                         CefWindowInfo& windowInfo,
                         CefRefPtr<CefClient>& client,
                         CefBrowserSettings& settings,
                         bool* no_javascript_access) {
    REQUIRE_IO_THREAD();
    // Note: passing popupFeatures is not yet supported.
    const int popupFeaturesNotImpl = 0;
    return LifespanHandler_OnBeforePopup(browser, frame, target_url,
            target_frame_name, target_disposition, user_gesture,
            popupFeaturesNotImpl, windowInfo, client, settings,
            no_javascript_access);
}

void ClientHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
#if defined(OS_WIN)
    // High DPI support.
    CefString auto_zooming = ApplicationSettings_GetString("auto_zooming");
    if (!auto_zooming.empty()) {
        LOG_DEBUG << "Browser: OnAfterCreated(): auto_zooming = "
                << auto_zooming.ToString();
        SetBrowserDpiSettings(browser, auto_zooming);
    }
#endif
    LifespanHandler_OnAfterCreated(browser);
}

bool ClientHandler::DoClose(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return LifespanHandler_DoClose(browser);
}

void ClientHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    LifespanHandler_OnBeforeClose(browser);
}

// --------------------------------------------------------------------------
// CefDisplayHandler
// --------------------------------------------------------------------------

void ClientHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefFrame> frame,
                           const CefString& url) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnAddressChange(browser, frame, url);
}

void ClientHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                         const CefString& title) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnTitleChange(browser, title);
}

bool ClientHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                     CefString& text) {
    REQUIRE_UI_THREAD();
    return DisplayHandler_OnTooltip(browser, text);
    // return false;
}

void ClientHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                           const CefString& value) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnStatusMessage(browser, value);
}

bool ClientHandler::OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                            const CefString& message,
                            const CefString& source,
                            int line) {
    REQUIRE_UI_THREAD();
    return DisplayHandler_OnConsoleMessage(browser, message, source, line);
    // return false;
}

// ----------------------------------------------------------------------------
// CefKeyboardHandler
// ----------------------------------------------------------------------------

bool ClientHandler::OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                         const CefKeyEvent& event,
                         CefEventHandle os_event,
                         bool* is_keyboard_shortcut) {
    REQUIRE_UI_THREAD();
    return KeyboardHandler_OnPreKeyEvent(browser, event, os_event,
            is_keyboard_shortcut);
    // Default: return false;
}

bool ClientHandler::OnKeyEvent(CefRefPtr<CefBrowser> browser,
                      const CefKeyEvent& event,
                      CefEventHandle os_event) {
    REQUIRE_UI_THREAD();
    return KeyboardHandler_OnKeyEvent(browser, event, os_event);
    // Default: return false;
}

// --------------------------------------------------------------------------
// CefRequestHandler
// --------------------------------------------------------------------------

bool ClientHandler::OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                          CefRefPtr<CefFrame> frame,
                          CefRefPtr<CefRequest> request,
                          bool is_redirect) {
    REQUIRE_UI_THREAD();
    return RequestHandler_OnBeforeBrowse(browser, frame, request, is_redirect);
}

ReturnValue ClientHandler::OnBeforeResourceLoad(
                                CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefRequest> request,
                                CefRefPtr<CefRequestCallback> callback) {
    REQUIRE_IO_THREAD();
    bool retval = RequestHandler_OnBeforeResourceLoad(browser, frame, request);
    if (retval) {
        return RV_CANCEL;
    } else {
        return RV_CONTINUE;
    }
    // Default: return RV_CONTINUE;
}

CefRefPtr<CefResourceHandler> ClientHandler::GetResourceHandler(
                                            CefRefPtr<CefBrowser> browser,
                                            CefRefPtr<CefFrame> frame,
                                            CefRefPtr<CefRequest> request) {
    REQUIRE_IO_THREAD();
    return RequestHandler_GetResourceHandler(browser, frame, request);
}

void ClientHandler::OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              CefRefPtr<CefRequest> request,
                              CefString& new_url) {
    REQUIRE_IO_THREAD();
    RequestHandler_OnResourceRedirect(browser, frame, request->GetURL(),
                                      new_url, request);
}

bool ClientHandler::GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              bool isProxy,
                              const CefString& host,
                              int port,
                              const CefString& realm,
                              const CefString& scheme,
                              CefRefPtr<CefAuthCallback> callback) {
    REQUIRE_IO_THREAD();
    return RequestHandler_GetAuthCredentials(browser, frame, isProxy, host,
            port, realm, scheme, callback);
    // Default: return false;
}

bool ClientHandler::OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                          const CefString& origin_url,
                          int64 new_size,
                          CefRefPtr<CefRequestCallback> callback) {
    REQUIRE_IO_THREAD();
    return RequestHandler_OnQuotaRequest(browser, origin_url, new_size,
            callback);
    // Default: return false;
}

void ClientHandler::OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                               const CefString& url,
                               bool& allow_os_execution) {
    REQUIRE_UI_THREAD();
    RequestHandler_OnProtocolExecution(browser, url, allow_os_execution);
}

bool ClientHandler::OnCertificateError(
                      CefRefPtr<CefBrowser> browser, // not used
                      cef_errorcode_t cert_error,
                      const CefString& request_url,
                      CefRefPtr<CefSSLInfo> ssl_info, // not used
                      CefRefPtr<CefRequestCallback> callback) {
    REQUIRE_UI_THREAD();
    return RequestHandler_OnCertificateError(
            cert_error, request_url, callback);
    // Default: return false;
}

void ClientHandler::OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                     cef_termination_status_t status) {
    REQUIRE_UI_THREAD();
    DebugLog("Browser: OnRenderProcessTerminated()");
    RequestHandler_OnRendererProcessTerminated(browser, status);
}

void ClientHandler::OnPluginCrashed(CefRefPtr<CefBrowser> browser,
                           const CefString& plugin_path) {
    REQUIRE_UI_THREAD();
    RequestHandler_OnPluginCrashed(browser, plugin_path);
}

// --------------------------------------------------------------------------
// CefLoadHandler
// --------------------------------------------------------------------------

void ClientHandler::OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                bool isLoading,
                                bool canGoBack,
                                bool canGoForward) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadingStateChange(browser, isLoading, canGoBack,
            canGoForward);
}

void ClientHandler::OnLoadStart(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                TransitionType transition_type) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadStart(browser, frame);
}

void ClientHandler::OnLoadEnd(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefFrame> frame,
                     int httpStatusCode) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadEnd(browser, frame, httpStatusCode);
}

void ClientHandler::OnLoadError(CefRefPtr<CefBrowser> browser,
                       CefRefPtr<CefFrame> frame,
                       cef_errorcode_t errorCode,
                       const CefString& errorText,
                       const CefString& failedUrl) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadError(browser, frame, errorCode, errorText, failedUrl);
}

// ----------------------------------------------------------------------------
// CefRenderHandler
// ----------------------------------------------------------------------------

bool ClientHandler::GetRootScreenRect(CefRefPtr<CefBrowser> browser,
                             CefRect& rect) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetRootScreenRect(browser, rect);
}

bool ClientHandler::GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetViewRect(browser, rect);
}

bool ClientHandler::GetScreenPoint(CefRefPtr<CefBrowser> browser,
                          int viewX,
                          int viewY,
                          int& screenX,
                          int& screenY) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetScreenPoint(browser, viewX, viewY, screenX,
            screenY);
}

bool ClientHandler::GetScreenInfo(CefRefPtr<CefBrowser> browser,
                         CefScreenInfo& screen_info) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetScreenInfo(browser, screen_info);
}

void ClientHandler::OnPopupShow(CefRefPtr<CefBrowser> browser,
                       bool show) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPopupShow(browser, show);
}

void ClientHandler::OnPopupSize(CefRefPtr<CefBrowser> browser,
                       const CefRect& rect) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPopupSize(browser, rect);
}

void ClientHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                   PaintElementType type,
                   const RectList& dirtyRects,
                   const void* buffer,
                   int width, int height) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPaint(browser, type, const_cast<RectList&>(dirtyRects), \
            buffer, width, height);
};

void ClientHandler::OnCursorChange(CefRefPtr<CefBrowser> browser,
                                   CefCursorHandle cursor,
                                   CursorType type,
                                   const CefCursorInfo& custom_cursor_info) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnCursorChange(browser, cursor);
}

void ClientHandler::OnScrollOffsetChanged(CefRefPtr<CefBrowser> browser,
                                          double x,
                                          double y) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnScrollOffsetChanged(browser);
}


// ----------------------------------------------------------------------------
// CefJSDialogHandler
// ----------------------------------------------------------------------------

bool ClientHandler::OnJSDialog(CefRefPtr<CefBrowser> browser,
                  const CefString& origin_url,
                  JSDialogType dialog_type,
                  const CefString& message_text,
                  const CefString& default_prompt_text,
                  CefRefPtr<CefJSDialogCallback> callback,
                  bool& suppress_message) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnJavascriptDialog(browser, origin_url,
            dialog_type, message_text, default_prompt_text,
            callback, suppress_message);
}

bool ClientHandler::OnBeforeUnloadDialog(CefRefPtr<CefBrowser> browser,
                            const CefString& message_text,
                            bool is_reload,
                            CefRefPtr<CefJSDialogCallback> callback) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnBeforeUnloadJavascriptDialog(browser,
            message_text, is_reload, callback);
}

void ClientHandler::OnResetDialogState(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnResetJavascriptDialogState(browser);
}

void ClientHandler::OnDialogClosed(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnJavascriptDialogClosed(browser);
}

// ----------------------------------------------------------------------------
// CefDownloadHandler
// ----------------------------------------------------------------------------

void ClientHandler::OnBeforeDownload(CefRefPtr<CefBrowser> browser,
                        CefRefPtr<CefDownloadItem> download_item,
                        const CefString& suggested_name,
                        CefRefPtr<CefBeforeDownloadCallback> callback) {
    REQUIRE_UI_THREAD();
    bool downloads_enabled = ApplicationSettings_GetBool("downloads_enabled");
    if (downloads_enabled) {
        std::string msg = "Browser: About to download file: ";
        msg.append(suggested_name.ToString().c_str());
        DebugLog(msg.c_str());
        callback->Continue(suggested_name, true);
    } else {
        DebugLog("Browser: Tried to download file, but downloads are disabled");
    }
}

void ClientHandler::OnDownloadUpdated(
        CefRefPtr<CefBrowser> browser,
        CefRefPtr<CefDownloadItem> download_item,
        CefRefPtr<CefDownloadItemCallback> callback) {
    REQUIRE_UI_THREAD();
    if (download_item->IsComplete()) {
        std::string msg = "Browser: Download completed, saved to: ";
        msg.append(download_item->GetFullPath().ToString().c_str());
        DebugLog(msg.c_str());
    } else if (download_item->IsCanceled()) {
        DebugLog("Browser: Download was cancelled");
    }
}

// ----------------------------------------------------------------------------
// CefContextMenuHandler
// ----------------------------------------------------------------------------

#define _MENU_ID_DEVTOOLS                         MENU_ID_USER_FIRST + 1
#define _MENU_ID_RELOAD_PAGE                      MENU_ID_USER_FIRST + 2
#define _MENU_ID_OPEN_PAGE_IN_EXTERNAL_BROWSER    MENU_ID_USER_FIRST + 3
#define _MENU_ID_OPEN_FRAME_IN_EXTERNAL_BROWSER   MENU_ID_USER_FIRST + 4

void ClientHandler::OnBeforeContextMenu(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefContextMenuParams> params,
                                CefRefPtr<CefMenuModel> model) {
    bool enabled = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "enabled");
    bool navigation = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "navigation");
    bool print = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "print");
    bool view_source = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "view_source");
    bool external_browser = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "external_browser");
    bool devtools = ApplicationSettings_GetBoolFromDict(\
            "context_menu", "devtools");

    if (!enabled) {
        model->Clear();
        return;
    }
    if (!navigation) {
        model->Remove(MENU_ID_BACK);
        model->Remove(MENU_ID_FORWARD);
        // Remove separator
        model->RemoveAt(0);
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

bool ClientHandler::OnContextMenuCommand(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefContextMenuParams> params,
                                int command_id,
                                EventFlags event_flags) {
    if (command_id == _MENU_ID_OPEN_PAGE_IN_EXTERNAL_BROWSER) {
#if defined(OS_WIN)
        ShellExecuteA(0, "open", params->GetPageUrl().ToString().c_str(),
                0, 0, SW_SHOWNORMAL);
#elif defined(OS_LINUX)
        OpenInExternalBrowser(params->GetPageUrl().ToString());
#endif
        return true;
    } else if (command_id == _MENU_ID_OPEN_FRAME_IN_EXTERNAL_BROWSER) {
#if defined(OS_WIN)
        ShellExecuteA(0, "open", params->GetFrameUrl().ToString().c_str(),
                0, 0, SW_SHOWNORMAL);
#elif defined(OS_LINUX)
        OpenInExternalBrowser(params->GetFrameUrl().ToString());
#endif
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

void ClientHandler::OnContextMenuDismissed(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame) {
}

