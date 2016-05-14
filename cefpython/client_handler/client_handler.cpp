// Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

// ClientHandler code is running in the Browser process only.

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

///
// Called on the IO thread before a new popup window is created. The |browser|
// and |frame| parameters represent the source of the popup request. The
// |target_url| and |target_frame_name| values may be empty if none were
// specified with the request. The |popupFeatures| structure contains
// information about the requested popup window. To allow creation of the
// popup window optionally modify |windowInfo|, |client|, |settings| and
// |no_javascript_access| and return false. To cancel creation of the popup
// window return true. The |client| and |settings| values will default to the
// source browser's values. The |no_javascript_access| value indicates whether
// the new browser window should be scriptable and in the same process as the
// source browser.
/*--cef(optional_param=target_url,optional_param=target_frame_name)--*/
bool ClientHandler::OnBeforePopup(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefFrame> frame,
                         const CefString& target_url,
                         const CefString& target_frame_name,
                         const CefPopupFeatures& popupFeatures,
                         CefWindowInfo& windowInfo,
                         CefRefPtr<CefClient>& client,
                         CefBrowserSettings& settings,
                         bool* no_javascript_access) {
    REQUIRE_IO_THREAD();
    // Note: passing popupFeatures is not yet supported.
    return LifespanHandler_OnBeforePopup(browser, frame, target_url,
            target_frame_name, 0, windowInfo, client, settings,
            no_javascript_access);
}

///
// Called after a new browser is created.
///
/*--cef()--*/
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

///
// Called when a modal window is about to display and the modal loop should
// begin running. Return false to use the default modal loop implementation or
// true to use a custom implementation.
///
/*--cef()--*/
bool ClientHandler::RunModal(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return LifespanHandler_RunModal(browser);
}

///
// Called when a browser has recieved a request to close. This may result
// directly from a call to CefBrowserHost::CloseBrowser() or indirectly if the
// browser is a top-level OS window created by CEF and the user attempts to
// close the window. This method will be called after the JavaScript
// 'onunload' event has been fired. It will not be called for browsers after
// the associated OS window has been destroyed (for those browsers it is no
// longer possible to cancel the close).
//
// If CEF created an OS window for the browser returning false will send an OS
// close notification to the browser window's top-level owner (e.g. WM_CLOSE
// on Windows, performClose: on OS-X and "delete_event" on Linux). If no OS
// window exists (window rendering disabled) returning false will cause the
// browser object to be destroyed immediately. Return true if the browser is
// parented to another window and that other window needs to receive close
// notification via some non-standard technique.
//
// If an application provides its own top-level window it should handle OS
// close notifications by calling CefBrowserHost::CloseBrowser(false) instead
// of immediately closing (see the example below). This gives CEF an
// opportunity to process the 'onbeforeunload' event and optionally cancel the
// close before DoClose() is called.
//
// The CefLifeSpanHandler::OnBeforeClose() method will be called immediately
// before the browser object is destroyed. The application should only exit
// after OnBeforeClose() has been called for all existing browsers.
//
// If the browser represents a modal window and a custom modal loop
// implementation was provided in CefLifeSpanHandler::RunModal() this callback
// should be used to restore the opener window to a usable state.
//
// By way of example consider what should happen during window close when the
// browser is parented to an application-provided top-level OS window.
// 1.  User clicks the window close button which sends an OS close
//     notification (e.g. WM_CLOSE on Windows, performClose: on OS-X and
//     "delete_event" on Linux).
// 2.  Application's top-level window receives the close notification and:
//     A. Calls CefBrowserHost::CloseBrowser(false).
//     B. Cancels the window close.
// 3.  JavaScript 'onbeforeunload' handler executes and shows the close
//     confirmation dialog (which can be overridden via
//     CefJSDialogHandler::OnBeforeUnloadDialog()).
// 4.  User approves the close.
// 5.  JavaScript 'onunload' handler executes.
// 6.  Application's DoClose() handler is called. Application will:
//     A. Call CefBrowserHost::ParentWindowWillClose() to notify CEF that the
//        parent window will be closing.
//     B. Set a flag to indicate that the next close attempt will be allowed.
//     C. Return false.
// 7.  CEF sends an OS close notification.
// 8.  Application's top-level window receives the OS close notification and
//     allows the window to close based on the flag from #6B.
// 9.  Browser OS window is destroyed.
// 10. Application's CefLifeSpanHandler::OnBeforeClose() handler is called and
//     the browser object is destroyed.
// 11. Application exits by calling CefQuitMessageLoop() if no other browsers
//     exist.
///
/*--cef()--*/
bool ClientHandler::DoClose(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return LifespanHandler_DoClose(browser);
}

///
// Called just before a browser is destroyed. Release all references to the
// browser object and do not attempt to execute any methods on the browser
// object after this callback returns. If this is a modal window and a custom
// modal loop implementation was provided in RunModal() this callback should
// be used to exit the custom modal loop. See DoClose() documentation for
// additional usage information.
///
/*--cef()--*/
void ClientHandler::OnBeforeClose(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    LifespanHandler_OnBeforeClose(browser);
}

// --------------------------------------------------------------------------
// CefDisplayHandler
// --------------------------------------------------------------------------

///
// Implement this interface to handle events related to browser display state.
// The methods of this class will be called on the UI thread.
///

///
// Called when a frame's address has changed.
///
/*--cef()--*/
void ClientHandler::OnAddressChange(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefFrame> frame,
                           const CefString& url) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnAddressChange(browser, frame, url);
}

///
// Called when the page title changes.
///
/*--cef(optional_param=title)--*/
void ClientHandler::OnTitleChange(CefRefPtr<CefBrowser> browser,
                         const CefString& title) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnTitleChange(browser, title);
}

///
// Called when the browser is about to display a tooltip. |text| contains the
// text that will be displayed in the tooltip. To handle the display of the
// tooltip yourself return true. Otherwise, you can optionally modify |text|
// and then return false to allow the browser to display the tooltip.
// When window rendering is disabled the application is responsible for
// drawing tooltips and the return value is ignored.
///
/*--cef(optional_param=text)--*/
bool ClientHandler::OnTooltip(CefRefPtr<CefBrowser> browser,
                     CefString& text) {
    REQUIRE_UI_THREAD();
    return DisplayHandler_OnTooltip(browser, text);
    // return false;
}

///
// Called when the browser receives a status message. |text| contains the text
// that will be displayed in the status message and |type| indicates the
// status message type.
///
/*--cef(optional_param=value)--*/
void ClientHandler::OnStatusMessage(CefRefPtr<CefBrowser> browser,
                           const CefString& value) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnStatusMessage(browser, value);
}

///
// Called to display a console message. Return true to stop the message from
// being output to the console.
///
/*--cef(optional_param=message,optional_param=source)--*/
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

///
// Implement this interface to handle events related to keyboard input. The
// methods of this class will be called on the UI thread.
///

// Called before a keyboard event is sent to the renderer. |event| contains
// information about the keyboard event. |os_event| is the operating system
// event message, if any. Return true if the event was handled or false
// otherwise. If the event will be handled in OnKeyEvent() as a keyboard
// shortcut set |is_keyboard_shortcut| to true and return false.
/*--cef()--*/
bool ClientHandler::OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                         const CefKeyEvent& event,
                         CefEventHandle os_event,
                         bool* is_keyboard_shortcut) {
    REQUIRE_UI_THREAD();
    return KeyboardHandler_OnPreKeyEvent(browser, event, os_event,
            is_keyboard_shortcut);
    // Default: return false;
}

///
// Called after the renderer and JavaScript in the page has had a chance to
// handle the event. |event| contains information about the keyboard event.
// |os_event| is the operating system event message, if any. Return true if
// the keyboard event was handled or false otherwise.
///
/*--cef()--*/
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

///
// Implement this interface to handle events related to browser requests. The
// methods of this class will be called on the thread indicated.
///

///
// Called on the UI thread before browser navigation. Return true to cancel
// the navigation or false to allow the navigation to proceed. The |request|
// object cannot be modified in this callback.
// CefLoadHandler::OnLoadingStateChange will be called twice in all cases.
// If the navigation is allowed CefLoadHandler::OnLoadStart and
// CefLoadHandler::OnLoadEnd will be called. If the navigation is canceled
// CefLoadHandler::OnLoadError will be called with an |errorCode| value of
// ERR_ABORTED.
///
/*--cef()--*/
bool ClientHandler::OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                          CefRefPtr<CefFrame> frame,
                          CefRefPtr<CefRequest> request,
                          bool is_redirect) {
    REQUIRE_UI_THREAD();
    return RequestHandler_OnBeforeBrowse(browser, frame, request, is_redirect);
}

///
// Called on the IO thread before a resource request is loaded. The |request|
// object may be modified. To cancel the request return true otherwise return
// false.
///
/*--cef()--*/
bool ClientHandler::OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser,
                                CefRefPtr<CefFrame> frame,
                                CefRefPtr<CefRequest> request) {
    REQUIRE_IO_THREAD();
    return RequestHandler_OnBeforeResourceLoad(browser, frame, request);
    // Default: return false;
}

///
// Called on the IO thread before a resource is loaded. To allow the resource
// to load normally return NULL. To specify a handler for the resource return
// a CefResourceHandler object. The |request| object should not be modified in
// this callback.
///
/*--cef()--*/
CefRefPtr<CefResourceHandler> ClientHandler::GetResourceHandler(
                                            CefRefPtr<CefBrowser> browser,
                                            CefRefPtr<CefFrame> frame,
                                            CefRefPtr<CefRequest> request) {
    REQUIRE_IO_THREAD();
    return RequestHandler_GetResourceHandler(browser, frame, request);
}

///
// Called on the IO thread when a resource load is redirected. The |old_url|
// parameter will contain the old URL. The |new_url| parameter will contain
// the new URL and can be changed if desired.
///
/*--cef()--*/
void ClientHandler::OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              const CefString& old_url,
                              CefString& new_url) {
    REQUIRE_IO_THREAD();
    RequestHandler_OnResourceRedirect(browser, frame, old_url, new_url);
}

///
// Called on the IO thread when the browser needs credentials from the user.
// |isProxy| indicates whether the host is a proxy server. |host| contains the
// hostname and |port| contains the port number. Return true to continue the
// request and call CefAuthCallback::Continue() when the authentication
// information is available. Return false to cancel the request.
///
/*--cef(optional_param=realm)--*/
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

///
// Called on the IO thread when JavaScript requests a specific storage quota
// size via the webkitStorageInfo.requestQuota function. |origin_url| is the
// origin of the page making the request. |new_size| is the requested quota
// size in bytes. Return true and call CefQuotaCallback::Continue() either in
// this method or at a later time to grant or deny the request. Return false
// to cancel the request.
///
/*--cef(optional_param=realm)--*/
bool ClientHandler::OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                          const CefString& origin_url,
                          int64 new_size,
                          CefRefPtr<CefQuotaCallback> callback) {
    REQUIRE_IO_THREAD();
    return RequestHandler_OnQuotaRequest(browser, origin_url, new_size,
            callback);
    // Default: return false;
}

///
// Called on the UI thread to handle requests for URLs with an unknown
// protocol component. Set |allow_os_execution| to true to attempt execution
// via the registered OS protocol handler, if any.
// SECURITY WARNING: YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED
// ON SCHEME, HOST OR OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
///
/*--cef()--*/
void ClientHandler::OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                               const CefString& url,
                               bool& allow_os_execution) {
    REQUIRE_UI_THREAD();
    RequestHandler_OnProtocolExecution(browser, url, allow_os_execution);
}

///
// Called on the browser process IO thread before a plugin is loaded. Return
// true to block loading of the plugin.
///
/*--cef(optional_param=url,optional_param=policy_url)--*/
bool ClientHandler::OnBeforePluginLoad(CefRefPtr<CefBrowser> browser,
                              const CefString& url,
                              const CefString& policy_url,
                              CefRefPtr<CefWebPluginInfo> info) {
    REQUIRE_IO_THREAD();
    return RequestHandler_OnBeforePluginLoad(browser, url, policy_url, info);
    // Default: return false;
}

///
// Called on the UI thread to handle requests for URLs with an invalid
// SSL certificate. Return true and call CefAllowCertificateErrorCallback::
// Continue() either in this method or at a later time to continue or cancel
// the request. Return false to cancel the request immediately. If |callback|
// is empty the error cannot be recovered from and the request will be
// canceled automatically. If CefSettings.ignore_certificate_errors is set
// all invalid certificates will be accepted without calling this method.
///
/*--cef()--*/
bool ClientHandler::OnCertificateError(
                      cef_errorcode_t cert_error,
                      const CefString& request_url,
                      CefRefPtr<CefAllowCertificateErrorCallback> callback) {
    REQUIRE_UI_THREAD();
    return RequestHandler_OnCertificateError(
            cert_error, request_url, callback);
    // Default: return false;
}

///
// Called when the render process terminates unexpectedly. |status| indicates
// how the process terminated.
///
/*--cef()--*/
void ClientHandler::OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                     cef_termination_status_t status) {
    REQUIRE_UI_THREAD();
    DebugLog("Browser: OnRenderProcessTerminated()");
    RequestHandler_OnRendererProcessTerminated(browser, status);
}

///
// Called when a plugin has crashed. |plugin_path| is the path of the plugin
// that crashed.
///
/*--cef()--*/
void ClientHandler::OnPluginCrashed(CefRefPtr<CefBrowser> browser,
                           const CefString& plugin_path) {
    REQUIRE_UI_THREAD();
    RequestHandler_OnPluginCrashed(browser, plugin_path);
}

// --------------------------------------------------------------------------
// CefLoadHandler
// --------------------------------------------------------------------------

///
// Implement this interface to handle events related to browser load status.
// The methods of this class will be called on the UI thread.
///

///
// Called when the loading state has changed.
///
/*--cef()--*/
void ClientHandler::OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                bool isLoading,
                                bool canGoBack,
                                bool canGoForward) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadingStateChange(browser, isLoading, canGoBack,
            canGoForward);
}

///
// Called when the browser begins loading a frame. The |frame| value will
// never be empty -- call the IsMain() method to check if this frame is the
// main frame. Multiple frames may be loading at the same time. Sub-frames may
// start or continue loading after the main frame load has ended. This method
// may not be called for a particular frame if the load request for that frame
// fails.
///
/*--cef()--*/
void ClientHandler::OnLoadStart(CefRefPtr<CefBrowser> browser,
                       CefRefPtr<CefFrame> frame) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadStart(browser, frame);
}

///
// Called when the browser is done loading a frame. The |frame| value will
// never be empty -- call the IsMain() method to check if this frame is the
// main frame. Multiple frames may be loading at the same time. Sub-frames may
// start or continue loading after the main frame load has ended. This method
// will always be called for all frames irrespective of whether the request
// completes successfully.
///
/*--cef()--*/
void ClientHandler::OnLoadEnd(CefRefPtr<CefBrowser> browser,
                     CefRefPtr<CefFrame> frame,
                     int httpStatusCode) {
    REQUIRE_UI_THREAD();
    LoadHandler_OnLoadEnd(browser, frame, httpStatusCode);
}

///
// Called when the browser fails to load a resource. |errorCode| is the error
// code number, |errorText| is the error text and and |failedUrl| is the URL
// that failed to load. See net\base\net_error_list.h for complete
// descriptions of the error codes.
///
/*--cef(optional_param=errorText)--*/
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

///
// Implement this interface to handle events when window rendering is disabled.
// The methods of this class will be called on the UI thread.
///

///
// Called to retrieve the root window rectangle in screen coordinates. Return
// true if the rectangle was provided.
///
/*--cef()--*/
bool ClientHandler::GetRootScreenRect(CefRefPtr<CefBrowser> browser,
                             CefRect& rect) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetRootScreenRect(browser, rect);
}

///
// Called to retrieve the view rectangle which is relative to screen
// coordinates. Return true if the rectangle was provided.
///
/*--cef()--*/
bool ClientHandler::GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetViewRect(browser, rect);
}

///
// Called to retrieve the translation from view coordinates to actual screen
// coordinates. Return true if the screen coordinates were provided.
///
/*--cef()--*/
bool ClientHandler::GetScreenPoint(CefRefPtr<CefBrowser> browser,
                          int viewX,
                          int viewY,
                          int& screenX,
                          int& screenY) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetScreenPoint(browser, viewX, viewY, screenX,
            screenY);
}

///
// Called to allow the client to fill in the CefScreenInfo object with
// appropriate values. Return true if the |screen_info| structure has been
// modified.
//
// If the screen info rectangle is left empty the rectangle from GetViewRect
// will be used. If the rectangle is still empty or invalid popups may not be
// drawn correctly.
///
/*--cef()--*/
bool ClientHandler::GetScreenInfo(CefRefPtr<CefBrowser> browser,
                         CefScreenInfo& screen_info) {
    REQUIRE_UI_THREAD();
    return RenderHandler_GetScreenInfo(browser, screen_info);
}

///
// Called when the browser wants to show or hide the popup widget. The popup
// should be shown if |show| is true and hidden if |show| is false.
///
/*--cef()--*/
void ClientHandler::OnPopupShow(CefRefPtr<CefBrowser> browser,
                       bool show) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPopupShow(browser, show);
}

///
// Called when the browser wants to move or resize the popup widget. |rect|
// contains the new location and size.
///
/*--cef()--*/
void ClientHandler::OnPopupSize(CefRefPtr<CefBrowser> browser,
                       const CefRect& rect) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPopupSize(browser, rect);
}

///
// Called when an element should be painted. |type| indicates whether the
// element is the view or the popup widget. |buffer| contains the pixel data
// for the whole image. |dirtyRects| contains the set of rectangles that need
// to be repainted. On Windows |buffer| will be |width|*|height|*4 bytes
// in size and represents a BGRA image with an upper-left origin.
///
/*--cef()--*/
void ClientHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                   PaintElementType type,
                   const RectList& dirtyRects,
                   const void* buffer,
                   int width, int height) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnPaint(browser, type, const_cast<RectList&>(dirtyRects), \
            buffer, width, height);
};

///
// Called when the browser window's cursor has changed.
///
/*--cef()--*/
void ClientHandler::OnCursorChange(CefRefPtr<CefBrowser> browser,
                          CefCursorHandle cursor) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnCursorChange(browser, cursor);
}

///
// Called when the scroll offset has changed.
///
/*--cef()--*/
void ClientHandler::OnScrollOffsetChanged(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    RenderHandler_OnScrollOffsetChanged(browser);
}


// ----------------------------------------------------------------------------
// CefJSDialogHandler
// ----------------------------------------------------------------------------
///
// Called to run a JavaScript dialog. The |default_prompt_text| value will be
// specified for prompt dialogs only. Set |suppress_message| to true and
// return false to suppress the message (suppressing messages is preferable
// to immediately executing the callback as this is used to detect presumably
// malicious behavior like spamming alert messages in onbeforeunload). Set
// |suppress_message| to false and return false to use the default
// implementation (the default implementation will show one modal dialog at a
// time and suppress any additional dialog requests until the displayed dialog
// is dismissed). Return true if the application will use a custom dialog or
// if the callback has been executed immediately. Custom dialogs may be either
// modal or modeless. If a custom dialog is used the application must execute
// |callback| once the custom dialog is dismissed.
///
/*--cef(optional_param=accept_lang,optional_param=message_text,
      optional_param=default_prompt_text)--*/
bool ClientHandler::OnJSDialog(CefRefPtr<CefBrowser> browser,
                  const CefString& origin_url,
                  const CefString& accept_lang,
                  JSDialogType dialog_type,
                  const CefString& message_text,
                  const CefString& default_prompt_text,
                  CefRefPtr<CefJSDialogCallback> callback,
                  bool& suppress_message) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnJavascriptDialog(browser, origin_url,
            accept_lang, dialog_type, message_text, default_prompt_text,
            callback, suppress_message);
}

///
// Called to run a dialog asking the user if they want to leave a page. Return
// false to use the default dialog implementation. Return true if the
// application will use a custom dialog or if the callback has been executed
// immediately. Custom dialogs may be either modal or modeless. If a custom
// dialog is used the application must execute |callback| once the custom
// dialog is dismissed.
///
/*--cef(optional_param=message_text)--*/
bool ClientHandler::OnBeforeUnloadDialog(CefRefPtr<CefBrowser> browser,
                            const CefString& message_text,
                            bool is_reload,
                            CefRefPtr<CefJSDialogCallback> callback) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnBeforeUnloadJavascriptDialog(browser,
            message_text, is_reload, callback);
}

///
// Called to cancel any pending dialogs and reset any saved dialog state. Will
// be called due to events like page navigation irregardless of whether any
// dialogs are currently pending.
///
/*--cef()--*/
void ClientHandler::OnResetDialogState(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnResetJavascriptDialogState(browser);
}

///
// Called when the default implementation dialog is closed.
///
/*--cef()--*/
void ClientHandler::OnDialogClosed(CefRefPtr<CefBrowser> browser) {
    REQUIRE_UI_THREAD();
    return JavascriptDialogHandler_OnJavascriptDialogClosed(browser);
}

// ----------------------------------------------------------------------------
// CefDownloadHandler
// ----------------------------------------------------------------------------

///
// Class used to handle file downloads. The methods of this class will called
// on the browser process UI thread.
///

///
// Called before a download begins. |suggested_name| is the suggested name for
// the download file. By default the download will be canceled. Execute
// |callback| either asynchronously or in this method to continue the download
// if desired. Do not keep a reference to |download_item| outside of this
// method.
///
/*--cef()--*/
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

///
// Called when a download's status or progress information has been updated.
// This may be called multiple times before and after OnBeforeDownload().
// Execute |callback| either asynchronously or in this method to cancel the
// download if desired. Do not keep a reference to |download_item| outside of
// this method.
///
/*--cef()--*/
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

///
// Called before a context menu is displayed. |params| provides information
// about the context menu state. |model| initially contains the default
// context menu. The |model| can be cleared to show no context menu or
// modified to show a custom menu. Do not keep references to |params| or
// |model| outside of this callback.
///
/*--cef()--*/
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

///
// Called to execute a command selected from the context menu. Return true if
// the command was handled or false for the default implementation. See
// cef_menu_id_t for the command ids that have default implementations. All
// user-defined command ids should be between MENU_ID_USER_FIRST and
// MENU_ID_USER_LAST. |params| will have the same values as what was passed to
// OnBeforeContextMenu(). Do not keep a reference to |params| outside of this
// callback.
///
/*--cef()--*/
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

///
// Called when the context menu is dismissed irregardless of whether the menu
// was empty or a command was selected.
///
/*--cef()--*/
void ClientHandler::OnContextMenuDismissed(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame) {
}

