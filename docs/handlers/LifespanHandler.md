# LifespanHandler callbacks #

Implement this interface to handle events related to browser life span. The methods of this class will be called on the UI thread.

For an example of how to implement a handler see [cefpython](cefpython).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).

## CEF 3 ##

bool **OnBeforePopup**([Browser](Browser) browser, [Frame](Frame) frame, string targetUrl, string targetFrameName, dict popupFeatures, list out windowInfo, object client, list out browserSettings, list out noJavascriptAccess)

> Called on the IO thread before a new popup window is created. The |browser|
> and |frame| parameters represent the source of the popup request. The
> |targetUrl| and |targetFrameName| values may be empty if none were
> specified with the request. The |popupFeatures| structure contains
> information about the requested popup window. To allow creation of the
> popup window optionally modify |windowInfo`[0]`| (see WindowInfo), |client|, |browserSettings`[0]`| (see BrowserSettings) and
> |noJavascriptAccess`[0]`| and return false. To cancel creation of the popup
> window return true. The |client| and |settings| values will default to the
> source browser's values. The |`noJavascriptAccess[0]`| value indicates whether
> the new browser window should be scriptable and in the same process as the
> source browser.

> Note that if you return True and create the popup window yourself, then the popup window and parent window will not be able to script each other. There will be no "window.opener" property available in the popup window.

> Arguments not yet ported (None value): popupFeatures, windowInfo, client, browserSettings.

void **`_`OnAfterCreated**([Browser](Browser) browser)

> Called after a new browser is created.

> This callback will be executed during browser creation, thus you must call [cefpython](cefpython).`SetGlobalClientCallback()` to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.

bool **RunModal**([Browser](Browser) browser)

> Called when a modal window is about to display and the modal loop should
> begin running. Return false to use the default modal loop implementation or
> true to use a custom implementation.

bool **DoClose**([Browser](Browser) browser)

> Called when a browser has recieved a request to close. This may result
> directly from a call to [Browser](Browser).`CloseBrowser` or indirectly if the
> browser is a top-level OS window created by CEF and the user attempts to
> close the window. This method will be called after the Javascript
> 'onunload' event has been fired. It will not be called for browsers after
> the associated OS window has been destroyed (for those browsers it is no
> longer possible to cancel the close).

> See complete description of this callback in [cef\_life\_span\_handler.h](../blob/master/cefpython/cef3/include/cef_life_span_handler.h).

void **OnBeforeClose**([Browser](Browser) browser)

> Called just before a browser is destroyed. Release all references to the
> browser object and do not attempt to execute any methods on the browser
> object after this callback returns. If this is a modal window and a custom
> modal loop implementation was provided in `RunModal()` this callback should
> be used to exit the custom modal loop. See `DoClose()` documentation for
> additional usage information.


## CEF 1 ##

bool **DoClose**([Browser](Browser) `browser`)

> Called when a window has recieved a request to close. Return false to proceed with the window close or true to cancel the window close. If this is a modal window and a custom modal loop implementation was provided in RunModal() this callback should be used to restore the opener window to a usable state.

void **OnAfterCreated**([Browser](Browser) `browser`)

> Called after a new window is created.

void **OnBeforeClose**([Browser](Browser) `browser`)

> Called just before a window is closed. If this is a modal window and a custom modal loop implementation was provided in RunModal() this callback should be used to exit the custom modal loop.

bool **OnBeforePopup**([Browser](Browser) `parentBrowser`, CefPopupFeatures& `popupFeatures`, CefWindowInfo &`windowInfo`, string &`url`, [BrowserSettings](BrowserSettings) &`settings`)

> Not yet implemented. Called before a new popup window is created. The |parentBrowser| parameter will point to the parent browser window. The |popupFeatures| parameter will contain information about the style of popup window requested. Return false to have the framework create the new popup window based on the parameters in |windowInfo|. Return true to cancel creation of the popup window. By default, a newly created popup window will have the same client and settings as the parent window. To change the client for the new window modify the object that |client| points to. To change the settings for the new window modify the |settings| structure.

bool **RunModal**([Browser](Browser) `browser`)

> Called when a modal window is about to display and the modal loop should begin running. Return false to use the default modal loop implementation or true to use a custom implementation.