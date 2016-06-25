[API categories](API-categories.md) | [API index](API-index.md)


# LifespanHandler (interface)

Implement this interface to handle events related to browser life span. The methods of this class will be called on the UI thread.

For an example of how to implement a handler see [cefpython](cefpython.md).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).


Table of contents:
* [Callbacks](#callbacks)
  * [OnBeforePopup](#onbeforepopup)
  * [_OnAfterCreated](#_onaftercreated)
  * [RunModal](#runmodal)
  * [DoClose](#doclose)
  * [OnBeforeClose](#onbeforeclose)


## Callbacks


### OnBeforePopup

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| targetUrl | string |
| targetFrameName | string |
| targetDisposition | WindowOpenDisposition |
| userGesture | bool |
| popupFeatures | None |
| out windowInfo[0] | [WindowInfo](WindowInfo.md) |
| client | None |
| out browserSettings[0] | [BrowserSettings](BrowserSettings.md) |
| out noJavascriptAccess[0] | bool |
| __Return__ | bool |

Called on the IO thread before a new popup browser is created. The
|browser| and |frame| values represent the source of the popup request. The
|target_url| and |target_frame_name| values indicate where the popup
browser should navigate and may be empty if not specified with the request.
The |target_disposition| value indicates where the user intended to open
the popup (e.g. current tab, new tab, etc). The |user_gesture| value will
be true if the popup was opened via explicit user gesture (e.g. clicking a
link) or false if the popup opened automatically (e.g. via the
DomContentLoaded event). The |popupFeatures| structure contains additional
information about the requested popup window. To allow creation of the
popup browser optionally modify |windowInfo|, |client|, |browserSettings| and
|noJavascriptAccess| and return false. To cancel creation of the popup
browser return true. The |client| and |settings| values will default to the
source browser's values. If the |no_javascript_access| value is set to
false the new browser will not be scriptable and may not be hosted in the
same renderer process as the source browser.

Note that if you return True and create the popup window yourself, then
the popup window and parent window will not be able to script each other.
There will be no "window.opener" property available in the popup window.

`WindowOpenDisposition` constants in the cefpython module:
* WOD_UNKNOWN,
* WOD_SUPPRESS_OPEN,
* WOD_CURRENT_TAB,
* WOD_SINGLETON_TAB,
* WOD_NEW_FOREGROUND_TAB,
* WOD_NEW_BACKGROUND_TAB,
* WOD_NEW_POPUP,
* WOD_NEW_WINDOW,
* WOD_SAVE_TO_DISK,
* WOD_OFF_THE_RECORD,
* WOD_IGNORE_ACTION


### _OnAfterCreated

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called after a new browser is created.

This callback will be executed during browser creation, thus you must call [cefpython](cefpython.md).SetGlobalClientCallback() to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.


### RunModal

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | bool |

Called when a modal window is about to display and the modal loop should
begin running. Return false to use the default modal loop implementation or
true to use a custom implementation.


### DoClose

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | bool |

Called when a browser has recieved a request to close. This may result
directly from a call to [Browser](Browser.md).`CloseBrowser` or indirectly
if the
browser is a top-level OS window created by CEF and the user attempts to
close the window. This method will be called after the Javascript
'onunload' event has been fired. It will not be called for browsers after
the associated OS window has been destroyed (for those browsers it is no
longer possible to cancel the close).

See complete description of this callback in [cef_life_span_handler.h]
(..|src|include|cef_life_span_handler.h).


### OnBeforeClose

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called just before a browser is destroyed. Release all references to the
browser object and do not attempt to execute any methods on the browser
object after this callback returns. If this is a modal window and a custom
modal loop implementation was provided in RunModal() this callback should
be used to exit the custom modal loop. See DoClose() documentation for
additional usage information.
