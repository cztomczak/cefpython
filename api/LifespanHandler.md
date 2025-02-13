[API categories](API-categories.md) | [API index](API-index.md)


# LifespanHandler (interface)

Implement this interface to handle events related to browser life span.
The methods of this class will be called on the UI thread.

Related code snippets:
- [onbeforeclose.py](../examples/snippets/onbeforeclose.py)


Table of contents:
* [Callbacks](#callbacks)
  * [DoClose](#doclose)
  * [_OnAfterCreated](#_onaftercreated)
  * [OnBeforeClose](#onbeforeclose)
  * [OnBeforePopup](#onbeforepopup)


## Callbacks


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


### _OnAfterCreated

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called after a new browser is created. This callback will be the first
notification that references |browser|.

This callback will be executed during browser creation, thus you must call [cefpython](cefpython.md).SetGlobalClientCallback() to use it. The callback name was prefixed with "`_`" to distinguish this special behavior.


### OnBeforeClose

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called just before a browser is destroyed. Release all references to the
browser object and do not attempt to execute any methods on the browser
object after this callback returns. This callback will be the last
notification that references |browser|. See DoClose() documentation for
additional usage information.


### OnBeforePopup

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| target_url | string |
| target_frame_name | string |
| target_disposition | WindowOpenDisposition |
| user_gesture | bool |
| popup_features | None |
| window_info_out | list[[WindowInfo](WindowInfo.md)] |
| client | None |
| browser_settings_out | list[[BrowserSettings](BrowserSettings.md)] |
| extra_info_out | dict |
| no_javascript_access_out | list[bool] |
| __Return__ | bool |

Description from upstream CEF:
> Called on the UI thread before a new popup browser is created. The
> |browser| and |frame| values represent the source of the popup request.
> The |target_url| and |target_frame_name| values indicate where the popup
> browser should navigate and may be empty if not specified with the
> request. The |target_disposition| value indicates where the user intended
> to open the popup (e.g. current tab, new tab, etc). The |user_gesture|
> value will be true if the popup was opened via explicit user gesture (e.g.
> clicking a link) or false if the popup opened automatically (e.g. via the
> DomContentLoaded event). The |popupFeatures| structure contains additional
> information about the requested popup window. To allow creation of the
> popup browser optionally modify |windowInfo|, |client|, |settings| and
> |no_javascript_access| and return false. To cancel creation of the popup
> browser return true. The |client| and |settings| values will default to
> the source browser's values. If the |no_javascript_access| value is set to
> false the new browser will not be scriptable and may not be hosted in the
> same renderer process as the source browser. Any modifications to
> |windowInfo| will be ignored if the parent browser is wrapped in a
> CefBrowserView. Popup browser creation will be canceled if the parent
> browser is destroyed before the popup browser creation completes
> (indicated by a call to OnAfterCreated for the popup browser). The
> |extra_info| parameter provides an opportunity to specify extra
> information specific to the created popup browser that will be passed to
> CefRenderProcessHandler::OnBrowserCreated() in the render process.

`WindowOpenDisposition` constants in the cefpython module:
* CEF_WOD_UNKNOWN,
* CEF_WOD_CURRENT_TAB,
* CEF_WOD_SINGLETON_TAB,
* CEF_WOD_NEW_FOREGROUND_TAB,
* CEF_WOD_NEW_BACKGROUND_TAB,
* CEF_WOD_NEW_POPUP,
* CEF_WOD_NEW_WINDOW,
* CEF_WOD_SAVE_TO_DISK,
* CEF_WOD_OFF_THE_RECORD,
* CEF_WOD_IGNORE_ACTION,
* CEF_WOD_SWITCH_TO_TAB,
* CEF_WOD_NEW_PICTURE_IN_PICTURE

Note that if you return True and create the popup window yourself, then
the popup window and parent window will not be able to script each other.
There will be no "window.opener" property available in the popup window.
To avoid this issue create a hidden window when your application starts.
Parent the new popup browser to the hidden window in OnBeforePopup. After
the browser exists (OnAfterCreated) create the desired target window
and re-parent the browser to that target window.
