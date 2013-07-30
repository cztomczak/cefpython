// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ClientHandler : 
		public CefClient,
        public CefLifeSpanHandler,
        public CefDisplayHandler
{
public:
  ClientHandler(){}
  virtual ~ClientHandler(){}

  ///
  // Return the handler for context menus. If no handler is provided the default
  // implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefContextMenuHandler> GetContextMenuHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for dialogs. If no handler is provided the default
  // implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDialogHandler> GetDialogHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser display state events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
    return this;
  }

  ///
  // Return the handler for download events. If no handler is returned downloads
  // will not be allowed.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDownloadHandler> GetDownloadHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for drag events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefDragHandler> GetDragHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for focus events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefFocusHandler> GetFocusHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for geolocation permissions requests. If no handler is
  // provided geolocation access will be denied by default.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefGeolocationHandler> GetGeolocationHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for JavaScript dialogs. If no handler is provided the
  // default implementation will be used.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefJSDialogHandler> GetJSDialogHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for keyboard events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser life span events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
    return this;
  }

  ///
  // Return the handler for browser load status events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefLoadHandler> GetLoadHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for off-screen rendering events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Return the handler for browser request events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
    return NULL;
  }

  ///
  // Called when a new message is received from a different process. Return true
  // if the message was handled or false otherwise. Do not keep a reference to
  // or attempt to access the message outside of this callback.
  ///
  /*--cef()--*/
  virtual bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                        CefProcessId source_process,
                                        CefRefPtr<CefProcessMessage> message)
                                        OVERRIDE;

  // --------------------------------------------------------------------------
  // CefLifeSpanHandler
  // --------------------------------------------------------------------------

  ///
  // Implement this interface to handle events related to browser life span. The
  // methods of this class will be called on the UI thread unless otherwise
  // indicated.
  ///

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
  virtual bool OnBeforePopup(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefFrame> frame,
                             const CefString& target_url,
                             const CefString& target_frame_name,
                             const CefPopupFeatures& popupFeatures,
                             CefWindowInfo& windowInfo,
                             CefRefPtr<CefClient>& client,
                             CefBrowserSettings& settings,
                             bool* no_javascript_access) OVERRIDE;

  ///
  // Called after a new browser is created.
  ///
  /*--cef()--*/
  virtual void OnAfterCreated(CefRefPtr<CefBrowser> browser) OVERRIDE;

  ///
  // Called when a modal window is about to display and the modal loop should
  // begin running. Return false to use the default modal loop implementation or
  // true to use a custom implementation.
  ///
  /*--cef()--*/
  virtual bool RunModal(CefRefPtr<CefBrowser> browser) OVERRIDE;

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
  virtual bool DoClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

  ///
  // Called just before a browser is destroyed. Release all references to the
  // browser object and do not attempt to execute any methods on the browser
  // object after this callback returns. If this is a modal window and a custom
  // modal loop implementation was provided in RunModal() this callback should
  // be used to exit the custom modal loop. See DoClose() documentation for
  // additional usage information.
  ///
  /*--cef()--*/
  virtual void OnBeforeClose(CefRefPtr<CefBrowser> browser) OVERRIDE;

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
  virtual void OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                    bool isLoading,
                                    bool canGoBack,
                                    bool canGoForward) OVERRIDE;

  ///
  // Called when a frame's address has changed.
  ///
  /*--cef()--*/
  virtual void OnAddressChange(CefRefPtr<CefBrowser> browser,
                               CefRefPtr<CefFrame> frame,
                               const CefString& url) OVERRIDE;

  ///
  // Called when the page title changes.
  ///
  /*--cef(optional_param=title)--*/
  virtual void OnTitleChange(CefRefPtr<CefBrowser> browser,
                             const CefString& title) OVERRIDE;

  ///
  // Called when the browser is about to display a tooltip. |text| contains the
  // text that will be displayed in the tooltip. To handle the display of the
  // tooltip yourself return true. Otherwise, you can optionally modify |text|
  // and then return false to allow the browser to display the tooltip.
  // When window rendering is disabled the application is responsible for
  // drawing tooltips and the return value is ignored.
  ///
  /*--cef(optional_param=text)--*/
  virtual bool OnTooltip(CefRefPtr<CefBrowser> browser,
                         CefString& text) OVERRIDE;

  ///
  // Called when the browser receives a status message. |text| contains the text
  // that will be displayed in the status message and |type| indicates the
  // status message type.
  ///
  /*--cef(optional_param=value)--*/
  virtual void OnStatusMessage(CefRefPtr<CefBrowser> browser,
                               const CefString& value) OVERRIDE;

  ///
  // Called to display a console message. Return true to stop the message from
  // being output to the console.
  ///
  /*--cef(optional_param=message,optional_param=source)--*/
  virtual bool OnConsoleMessage(CefRefPtr<CefBrowser> browser,
                                const CefString& message,
                                const CefString& source,
                                int line) OVERRIDE;

private:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  // IMPLEMENT_LOCKING(ClientHandler);

};
