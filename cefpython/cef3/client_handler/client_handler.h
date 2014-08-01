// Copyright (c) 2012-2013 The CEF Python authors. All rights reserved.
// License: New BSD License.
// Website: http://code.google.com/p/cefpython/

// ClientHandler code is running in the Browser process only.

#pragma once

#if defined(_WIN32)
#include "../windows/stdint.h"
#endif

#include "cefpython_public_api.h"

class ClientHandler : 
		public CefClient,
        public CefLifeSpanHandler,
        public CefDisplayHandler,
        public CefKeyboardHandler,
        public CefRequestHandler,
        public CefLoadHandler,
        public CefRenderHandler,
        public CefJSDialogHandler,
        public CefDownloadHandler,
        public CefContextMenuHandler
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
    return this;
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
    return this;
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
    return this;
  }

  ///
  // Return the handler for keyboard events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() OVERRIDE {
    return this;
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
    return this;
  }

  ///
  // Return the handler for off-screen rendering events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRenderHandler> GetRenderHandler() OVERRIDE {
    return this;
  }

  ///
  // Return the handler for browser request events.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
    return this;
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

  // --------------------------------------------------------------------------
  // CefKeyboardHandler
  // --------------------------------------------------------------------------

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
  virtual bool OnPreKeyEvent(CefRefPtr<CefBrowser> browser,
                             const CefKeyEvent& event,
                             CefEventHandle os_event,
                             bool* is_keyboard_shortcut) OVERRIDE;

  ///
  // Called after the renderer and JavaScript in the page has had a chance to
  // handle the event. |event| contains information about the keyboard event.
  // |os_event| is the operating system event message, if any. Return true if
  // the keyboard event was handled or false otherwise.
  ///
  /*--cef()--*/
  virtual bool OnKeyEvent(CefRefPtr<CefBrowser> browser,
                          const CefKeyEvent& event,
                          CefEventHandle os_event) OVERRIDE;

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
  virtual bool OnBeforeBrowse(CefRefPtr<CefBrowser> browser,
                              CefRefPtr<CefFrame> frame,
                              CefRefPtr<CefRequest> request,
                              bool is_redirect) OVERRIDE;

  ///
  // Called on the IO thread before a resource request is loaded. The |request|
  // object may be modified. To cancel the request return true otherwise return
  // false.
  ///
  /*--cef()--*/
  virtual bool OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefRequest> request) OVERRIDE;

  ///
  // Called on the IO thread before a resource is loaded. To allow the resource
  // to load normally return NULL. To specify a handler for the resource return
  // a CefResourceHandler object. The |request| object should not be modified in
  // this callback.
  ///
  /*--cef()--*/
  virtual CefRefPtr<CefResourceHandler> GetResourceHandler(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefRefPtr<CefRequest> request) OVERRIDE;

  ///
  // Called on the IO thread when a resource load is redirected. The |old_url|
  // parameter will contain the old URL. The |new_url| parameter will contain
  // the new URL and can be changed if desired.
  ///
  /*--cef()--*/
  virtual void OnResourceRedirect(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  const CefString& old_url,
                                  CefString& new_url) OVERRIDE;

  ///
  // Called on the IO thread when the browser needs credentials from the user.
  // |isProxy| indicates whether the host is a proxy server. |host| contains the
  // hostname and |port| contains the port number. Return true to continue the
  // request and call CefAuthCallback::Continue() when the authentication
  // information is available. Return false to cancel the request.
  ///
  /*--cef(optional_param=realm)--*/
  virtual bool GetAuthCredentials(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  bool isProxy,
                                  const CefString& host,
                                  int port,
                                  const CefString& realm,
                                  const CefString& scheme,
                                  CefRefPtr<CefAuthCallback> callback) 
                                  OVERRIDE;

  ///
  // Called on the IO thread when JavaScript requests a specific storage quota
  // size via the webkitStorageInfo.requestQuota function. |origin_url| is the
  // origin of the page making the request. |new_size| is the requested quota
  // size in bytes. Return true and call CefQuotaCallback::Continue() either in
  // this method or at a later time to grant or deny the request. Return false
  // to cancel the request.
  ///
  /*--cef(optional_param=realm)--*/
  virtual bool OnQuotaRequest(CefRefPtr<CefBrowser> browser,
                              const CefString& origin_url,
                              int64 new_size,
                              CefRefPtr<CefQuotaCallback> callback) OVERRIDE;

  ///
  // Called on the UI thread to handle requests for URLs with an unknown
  // protocol component. Set |allow_os_execution| to true to attempt execution
  // via the registered OS protocol handler, if any.
  // SECURITY WARNING: YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED
  // ON SCHEME, HOST OR OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
  ///
  /*--cef()--*/
  virtual void OnProtocolExecution(CefRefPtr<CefBrowser> browser,
                                   const CefString& url,
                                   bool& allow_os_execution) OVERRIDE;

  ///
  // Called on the browser process IO thread before a plugin is loaded. Return
  // true to block loading of the plugin.
  ///
  /*--cef(optional_param=url,optional_param=policy_url)--*/
  virtual bool OnBeforePluginLoad(CefRefPtr<CefBrowser> browser,
                                  const CefString& url,
                                  const CefString& policy_url,
                                  CefRefPtr<CefWebPluginInfo> info) OVERRIDE;

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
  virtual bool OnCertificateError(
      cef_errorcode_t cert_error,
      const CefString& request_url,
      CefRefPtr<CefAllowCertificateErrorCallback> callback) OVERRIDE;

  ///
  // Called when the render process terminates unexpectedly. |status| indicates
  // how the process terminated.
  ///
  /*--cef()--*/
  virtual void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser,
                                         cef_termination_status_t status) 
                                         OVERRIDE;

  ///
  // Called when a plugin has crashed. |plugin_path| is the path of the plugin
  // that crashed.
  ///
  /*--cef()--*/
  virtual void OnPluginCrashed(CefRefPtr<CefBrowser> browser,
                               const CefString& plugin_path) OVERRIDE;

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
  virtual void OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                                    bool isLoading,
                                    bool canGoBack,
                                    bool canGoForward) OVERRIDE;

  ///
  // Called when the browser begins loading a frame. The |frame| value will
  // never be empty -- call the IsMain() method to check if this frame is the
  // main frame. Multiple frames may be loading at the same time. Sub-frames may
  // start or continue loading after the main frame load has ended. This method
  // may not be called for a particular frame if the load request for that frame
  // fails.
  ///
  /*--cef()--*/
  virtual void OnLoadStart(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefFrame> frame) OVERRIDE;

  ///
  // Called when the browser is done loading a frame. The |frame| value will
  // never be empty -- call the IsMain() method to check if this frame is the
  // main frame. Multiple frames may be loading at the same time. Sub-frames may
  // start or continue loading after the main frame load has ended. This method
  // will always be called for all frames irrespective of whether the request
  // completes successfully.
  ///
  /*--cef()--*/
  virtual void OnLoadEnd(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefFrame> frame,
                         int httpStatusCode) OVERRIDE;

  ///
  // Called when the browser fails to load a resource. |errorCode| is the error
  // code number, |errorText| is the error text and and |failedUrl| is the URL
  // that failed to load. See net\base\net_error_list.h for complete
  // descriptions of the error codes.
  ///
  /*--cef(optional_param=errorText)--*/
  virtual void OnLoadError(CefRefPtr<CefBrowser> browser,
                           CefRefPtr<CefFrame> frame,
                           cef_errorcode_t errorCode,
                           const CefString& errorText,
                           const CefString& failedUrl) OVERRIDE;

  // --------------------------------------------------------------------------
  // CefRenderHandler
  // --------------------------------------------------------------------------

  ///
  // Implement this interface to handle events when window rendering is disabled.
  // The methods of this class will be called on the UI thread.
  ///

  ///
  // Called to retrieve the root window rectangle in screen coordinates. Return
  // true if the rectangle was provided.
  ///
  /*--cef()--*/
  virtual bool GetRootScreenRect(CefRefPtr<CefBrowser> browser,
                                 CefRect& rect) OVERRIDE;

  ///
  // Called to retrieve the view rectangle which is relative to screen
  // coordinates. Return true if the rectangle was provided.
  ///
  /*--cef()--*/
  virtual bool GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect)
      OVERRIDE;

  ///
  // Called to retrieve the translation from view coordinates to actual screen
  // coordinates. Return true if the screen coordinates were provided.
  ///
  /*--cef()--*/
  virtual bool GetScreenPoint(CefRefPtr<CefBrowser> browser,
                              int viewX,
                              int viewY,
                              int& screenX,
                              int& screenY) OVERRIDE;

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
  virtual bool GetScreenInfo(CefRefPtr<CefBrowser> browser,
                             CefScreenInfo& screen_info) OVERRIDE;

  ///
  // Called when the browser wants to show or hide the popup widget. The popup
  // should be shown if |show| is true and hidden if |show| is false.
  ///
  /*--cef()--*/
  virtual void OnPopupShow(CefRefPtr<CefBrowser> browser,
                           bool show) OVERRIDE;

  ///
  // Called when the browser wants to move or resize the popup widget. |rect|
  // contains the new location and size.
  ///
  /*--cef()--*/
  virtual void OnPopupSize(CefRefPtr<CefBrowser> browser,
                           const CefRect& rect) OVERRIDE;

  ///
  // Called when an element should be painted. |type| indicates whether the
  // element is the view or the popup widget. |buffer| contains the pixel data
  // for the whole image. |dirtyRects| contains the set of rectangles that need
  // to be repainted. On Windows |buffer| will be |width|*|height|*4 bytes
  // in size and represents a BGRA image with an upper-left origin.
  ///
  /*--cef()--*/
  virtual void OnPaint(CefRefPtr<CefBrowser> browser,
                       PaintElementType type,
                       const RectList& dirtyRects,
                       const void* buffer,
                       int width, int height) OVERRIDE;

  ///
  // Called when the browser window's cursor has changed.
  ///
  /*--cef()--*/
  virtual void OnCursorChange(CefRefPtr<CefBrowser> browser,
                              CefCursorHandle cursor) OVERRIDE;

  ///
  // Called when the scroll offset has changed.
  ///
  /*--cef()--*/
  virtual void OnScrollOffsetChanged(CefRefPtr<CefBrowser> browser) OVERRIDE;

  // --------------------------------------------------------------------------
  // CefJSDialogHandler
  // --------------------------------------------------------------------------
  typedef cef_jsdialog_type_t JSDialogType;

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
  virtual bool OnJSDialog(CefRefPtr<CefBrowser> browser,
                          const CefString& origin_url,
                          const CefString& accept_lang,
                          JSDialogType dialog_type,
                          const CefString& message_text,
                          const CefString& default_prompt_text,
                          CefRefPtr<CefJSDialogCallback> callback,
                          bool& suppress_message) OVERRIDE;

  ///
  // Called to run a dialog asking the user if they want to leave a page. Return
  // false to use the default dialog implementation. Return true if the
  // application will use a custom dialog or if the callback has been executed
  // immediately. Custom dialogs may be either modal or modeless. If a custom
  // dialog is used the application must execute |callback| once the custom
  // dialog is dismissed.
  ///
  /*--cef(optional_param=message_text)--*/
  virtual bool OnBeforeUnloadDialog(CefRefPtr<CefBrowser> browser,
                                    const CefString& message_text,
                                    bool is_reload,
                                    CefRefPtr<CefJSDialogCallback> callback)
                                    OVERRIDE;

  ///
  // Called to cancel any pending dialogs and reset any saved dialog state. Will
  // be called due to events like page navigation irregardless of whether any
  // dialogs are currently pending.
  ///
  /*--cef()--*/
  virtual void OnResetDialogState(CefRefPtr<CefBrowser> browser) OVERRIDE;

  ///
  // Called when the default implementation dialog is closed.
  ///
  /*--cef()--*/
  virtual void OnDialogClosed(CefRefPtr<CefBrowser> browser) OVERRIDE;

  // --------------------------------------------------------------------------
  // CefDownloadHandler
  // --------------------------------------------------------------------------

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
  virtual void OnBeforeDownload(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefDownloadItem> download_item,
      const CefString& suggested_name,
      CefRefPtr<CefBeforeDownloadCallback> callback) OVERRIDE;

  ///
  // Called when a download's status or progress information has been updated.
  // This may be called multiple times before and after OnBeforeDownload().
  // Execute |callback| either asynchronously or in this method to cancel the
  // download if desired. Do not keep a reference to |download_item| outside of
  // this method.
  ///
  /*--cef()--*/
  virtual void OnDownloadUpdated(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefDownloadItem> download_item,
      CefRefPtr<CefDownloadItemCallback> callback) OVERRIDE;

  // --------------------------------------------------------------------------
  // CefDownloadHandler
  // --------------------------------------------------------------------------
  
  ///
  // Implement this interface to handle context menu events. The methods of this
  // class will be called on the UI thread.
  ///

  typedef cef_event_flags_t EventFlags;

  ///
  // Called before a context menu is displayed. |params| provides information
  // about the context menu state. |model| initially contains the default
  // context menu. The |model| can be cleared to show no context menu or
  // modified to show a custom menu. Do not keep references to |params| or
  // |model| outside of this callback.
  ///
  /*--cef()--*/
  virtual void OnBeforeContextMenu(CefRefPtr<CefBrowser> browser,
                                   CefRefPtr<CefFrame> frame,
                                   CefRefPtr<CefContextMenuParams> params,
                                   CefRefPtr<CefMenuModel> model) OVERRIDE;

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
  virtual bool OnContextMenuCommand(CefRefPtr<CefBrowser> browser,
                                    CefRefPtr<CefFrame> frame,
                                    CefRefPtr<CefContextMenuParams> params,
                                    int command_id,
                                    EventFlags event_flags) OVERRIDE;

  ///
  // Called when the context menu is dismissed irregardless of whether the menu
  // was empty or a command was selected.
  ///
  /*--cef()--*/
  virtual void OnContextMenuDismissed(CefRefPtr<CefBrowser> browser,
                                      CefRefPtr<CefFrame> frame) OVERRIDE;


private:
   
  // Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ClientHandler);
  
  // Include the default locking implementation.
  // IMPLEMENT_LOCKING(ClientHandler);

};
