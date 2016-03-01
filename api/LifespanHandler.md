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
| popupFeatures | dict |
| out windowInfo | list |
| client | object |
| out browserSettings | list |
| out noJavascriptAccess | list |
| __Return__ | bool |

Called on the IO thread before a new popup window is created. The |browser|
and |frame| parameters represent the source of the popup request. The
|targetUrl| and |targetFrameName| values may be empty if none were
specified with the request. The |popupFeatures| structure contains
information about the requested popup window. To allow creation of the
popup window optionally modify |windowInfo`[0]`| (see WindowInfo), |client|, |browserSettings`[0]`| (see BrowserSettings) and
|noJavascriptAccess`[0]`| and return false. To cancel creation of the popup
window return true. The |client| and |settings| values will default to the
source browser's values. The |`noJavascriptAccess[0]`| value indicates whether
the new browser window should be scriptable and in the same process as the
source browser.

Note that if you return True and create the popup window yourself, then the popup window and parent window will not be able to script each other. There will be no "window.opener" property available in the popup window.

Arguments not yet ported (None value): popupFeatures, windowInfo, client, browserSettings.


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
directly from a call to [Browser](Browser.md).`CloseBrowser` or indirectly if the
browser is a top-level OS window created by CEF and the user attempts to
close the window. This method will be called after the Javascript
'onunload' event has been fired. It will not be called for browsers after
the associated OS window has been destroyed (for those browsers it is no
longer possible to cancel the close).

See complete description of this callback in [cef_life_span_handler.h](../blob/master/cefpython/cef3/include/cef_life_span_handler.h).


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
