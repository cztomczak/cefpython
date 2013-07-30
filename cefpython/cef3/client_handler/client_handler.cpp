// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#include "client_handler.h"
#include "cefpython_public_api.h"
#include "DebugLog.h"

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
    return false;
}

///
// Called after a new browser is created.
///
/*--cef()--*/
void ClientHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
}

///
// Called when a modal window is about to display and the modal loop should
// begin running. Return false to use the default modal loop implementation or
// true to use a custom implementation.
///
/*--cef()--*/
bool ClientHandler::RunModal(CefRefPtr<CefBrowser> browser) { 
    return false; 
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
    return false; 
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
// Called when the loading state has changed.
///
/*--cef()--*/
void ClientHandler::OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                bool isLoading,
                                bool canGoBack,
                                bool canGoForward) {
    REQUIRE_UI_THREAD();
    DisplayHandler_OnLoadingStateChange(browser, isLoading, canGoBack,
            canGoForward);
}

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
