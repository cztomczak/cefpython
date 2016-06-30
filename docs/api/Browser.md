[API categories](API-categories.md) | [API index](API-index.md)


# Browser (object)


Table of contents:
* [Notes](#notes)
* [Methods](#methods)
  * [CanGoBack](#cangoback)
  * [CanGoForward](#cangoforward)
  * [CloseBrowser](#closebrowser)
  * [CloseDevTools](#closedevtools)
  * [ExecuteFunction](#executefunction)
  * [ExecuteJavascript](#executejavascript)
  * [Find](#find)
  * [GetClientCallback](#getclientcallback)
  * [GetClientCallbacksDict](#getclientcallbacksdict)
  * [GetFocusedFrame](#getfocusedframe)
  * [GetFrame](#getframe)
  * [GetFrameByIdentifier](#getframebyidentifier)
  * [GetFrames](#getframes)
  * [GetFrameCount](#getframecount)
  * [GetFrameIdentifiers](#getframeidentifiers)
  * [GetFrameNames](#getframenames)
  * [GetJavascriptBindings](#getjavascriptbindings)
  * [GetMainFrame](#getmainframe)
  * [GetNSTextInputContext](#getnstextinputcontext)
  * [GetOpenerWindowHandle](#getopenerwindowhandle)
  * [GetOuterWindowHandle](#getouterwindowhandle)
  * [GetUrl](#geturl)
  * [GetUserData](#getuserdata)
  * [GetWindowHandle](#getwindowhandle)
  * [GetIdentifier](#getidentifier)
  * [GetZoomLevel](#getzoomlevel)
  * [GoBack](#goback)
  * [GoForward](#goforward)
  * [HandleKeyEventAfterTextInputClient](#handlekeyeventaftertextinputclient)
  * [HandleKeyEventBeforeTextInputClient](#handlekeyeventbeforetextinputclient)
  * [HasDocument](#hasdocument)
  * [IsFullscreen](#isfullscreen)
  * [IsLoading](#isloading)
  * [IsMouseCursorChangeDisabled](#ismousecursorchangedisabled)
  * [IsPopup](#ispopup)
  * [IsWindowRenderingDisabled](#iswindowrenderingdisabled)
  * [LoadUrl](#loadurl)
  * [Navigate](#navigate)
  * [NotifyMoveOrResizeStarted](#notifymoveorresizestarted)
  * [NotifyScreenInfoChanged](#notifyscreeninfochanged)
  * [ParentWindowWillClose](#parentwindowwillclose)
  * [Reload](#reload)
  * [ReloadIgnoreCache](#reloadignorecache)
  * [SetBounds](#setbounds)
  * [SendKeyEvent](#sendkeyevent)
  * [SendMouseClickEvent](#sendmouseclickevent)
  * [SendMouseMoveEvent](#sendmousemoveevent)
  * [SendMouseWheelEvent](#sendmousewheelevent)
  * [SendFocusEvent](#sendfocusevent)
  * [SendCaptureLostEvent](#sendcapturelostevent)
  * [SetClientCallback](#setclientcallback)
  * [SetClientHandler](#setclienthandler)
  * [SetFocus](#setfocus)
  * [SetMouseCursorChangeDisabled](#setmousecursorchangedisabled)
  * [SetJavascriptBindings](#setjavascriptbindings)
  * [SetUserData](#setuserdata)
  * [SetZoomLevel](#setzoomlevel)
  * [ShowDevTools](#showdevtools)
  * [StartDownload](#startdownload)
  * [StopLoad](#stopload)
  * [StopFinding](#stopfinding)
  * [ToggleFullscreen](#togglefullscreen)
  * [TryCloseBrowser](#tryclosebrowser)
  * [WasResized](#wasresized)
  * [WasHidden](#washidden)


## Notes

**Closing browser cleanly**

Remember to delete all browser references for the browser to shut down cleanly. See the wxpython.py example > MainFrame.OnClose() for how to
do it.


## Methods


### CanGoBack

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the browser can navigate backwards.


### CanGoForward

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the browser can navigate forwards.


### CloseBrowser

| Parameter | Type |
| --- | --- |
| forceClose | bool |
| __Return__ | void |

Closes the browser. If the window was created explicitily by you (not a popup) you still need to post WM_DESTROY message to the window.

Request that the browser close. The Javascript 'onbeforeunload' event will
be fired. If |force_close| is false the event handler, if any, will be
allowed to prompt the user and the user can optionally cancel the close.
If |force_close| is true the prompt will not be displayed and the close
will proceed. Results in a call to LifespanHandler::DoClose() if the
event handler allows the close or if |force_close| is true. See
LifespanHandler::DoClose() documentation for additional usage
information.


### CloseDevTools

| | |
| --- | --- |
| __Return__ | bool |

Explicitly close the associated DevTools browser, if any.


### ExecuteFunction

| Parameter | Type |
| --- | --- |
| funcName | string |
| [params..] | mixed |
| __Return__ | void |

Call javascript function asynchronously. This can also call object's methods, just pass "object.method" as `funcName`. Any valid javascript syntax is allowed as `funcName`, you could even pass an anonymous function here.

For a list of allowed types for `mixed` see [JavascriptBindings](JavascriptBindings.md).IsValueAllowed() (except function, method and instance).

Passing a python function here is not allowed, it is only possible through [JavascriptCallback](JavascriptCallback.md) object.


### ExecuteJavascript

| Parameter | Type |
| --- | --- |
| jsCode | string |
| scriptURL=None | string |
| startLine=None | int |
| __Return__ | void |

Execute a string of JavaScript code in this frame. The `sciptURL` parameter is the URL where the script in question can be found, if any. The renderer may request this URL to show the developer the source of the error.  The `startLine` parameter is the base line number to use for error reporting.

This function executes asynchronously so there is no way to get the returned value.

Calling javascript from native code synchronously is not possible in CEF 3. It is also not possible doing it synchronously the other way around ie. js->native.


### Find

| Parameter | Type |
| --- | --- |
| searchID | int |
| searchText | string |
| forward | bool |
| matchCase | bool |
| findNext | bool |
| __Return__ | void |

Search for |searchText|. |searchID| can be custom, it is so that you can  have multiple searches running simultaneously. |forward| indicates whether to search forward or backward within the page. |matchCase| indicates whether the search should be case-sensitive. |findNext| indicates whether this is the first request or a follow-up. The CefFindHandler instance, if any, returned via CefClient::GetFindHandler will be called to report find results.


### GetClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | func |

Get client callback by name.


### GetClientCallbacksDict

| | |
| --- | --- |
| __Return__ | dict |

Get client callbacks as a dictionary.


### GetFocusedFrame

| | |
| --- | --- |
| __Return__ | Frame |

Returns the focused [Frame](Frame.md) for the browser window.


### GetFrame

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | Frame |

Returns the [Frame](Frame.md) with the specified name, or NULL if not found. 


### GetFrameByIdentifier

| Parameter | Type |
| --- | --- |
| identifier | long |
| __Return__ | Frame |

Available only in CEF 3. Returns the [Frame](Frame.md) with the specified identifier, or None if not found.


### GetFrames

| | |
| --- | --- |
| __Return__ | list |

Get all frames. This is an internal CEF Python implementation that uses GetFrameNames() and GetFrame() methods to list through all frames. The main frame is not included in that list.


### GetFrameCount

| | |
| --- | --- |
| __Return__ | int |

Available only in CEF 3. Not yet implemented.

Returns the number of frames that currently exist.


### GetFrameIdentifiers

| | |
| --- | --- |
| __Return__ | void |

Available only in CEF 3. Not yet implemented.

Returns the identifiers of all existing frames.


### GetFrameNames

| | |
| --- | --- |
| __Return__ | string[] |

Returns the names of all existing frames. This list does not include the main frame.


### GetJavascriptBindings

| | |
| --- | --- |
| __Return__ | [JavascriptBindings](JavascriptBindings.md) |

Returns the [JavascriptBindings](JavascriptBindings.md) object that was passed to [cefpython](cefpython.md).CreateBrowserSync().


### GetMainFrame

| | |
| --- | --- |
| __Return__ | Frame |

Returns the main (top-level) [Frame](Frame.md) for the browser window.


### GetNSTextInputContext

| | |
| --- | --- |
| __Return__ | TextInputContext |

Not yet ported. Available only in CEF 3.

Get the NSTextInputContext implementation for enabling IME on Mac when
window rendering is disabled.


### GetOpenerWindowHandle

| | |
| --- | --- |
| __Return__ | windowHandle |

Retrieve the CEF-internal (inner or outer) window handle of the browser that opened this browser. Will return None for non-popup windows. See GetWindowHandle() for an explanation of inner/outer window handles.


### GetOuterWindowHandle

| | |
| --- | --- |
| __Return__ | windowHandle |

Get the most outer window handle.


### GetUrl

| | |
| --- | --- |
| __Return__ | string |

Get url of the main frame.


### GetUserData

| Parameter | Type |
| --- | --- |
| key | mixed |
| __Return__ | mixed |

Get user data. See also SetUserData().


### GetWindowHandle

| | |
| --- | --- |
| __Return__ | windowHandle |

Returns an inner or outer window handle for the browser. If the browser was created using CreateBrowserSync() then this will return an inner CEF-internal window handle. If this is a popup browser created from javascript using `window.open()` and its [WindowInfo](WindowInfo.md) has not been set in LifespanHandler.OnAfterCreated(), then it returns CEF-internal window handle which is the most outer window handle in this case.


### GetIdentifier

| | |
| --- | --- |
| __Return__ | int |

Returns the globally unique identifier for this browser.


### GetZoomLevel

| | |
| --- | --- |
| __Return__ | float |

Get the current zoom level. The default zoom level is 0.0.


### GoBack

| | |
| --- | --- |
| __Return__ | void |

Navigate backwards.


### GoForward

| | |
| --- | --- |
| __Return__ | void |

Navigate forwards.


### HandleKeyEventAfterTextInputClient

| Parameter | Type |
| --- | --- |
| keyEvent | eventHandle |
| __Return__ | void |

Available only in CEF 3. Not yet implemented.

Performs any additional actions after NSTextInputClient handles the event.


### HandleKeyEventBeforeTextInputClient

| | |
| --- | --- |
| __Return__ | void |

Available only in CEF 3. Not yet implemented.

Handles a keyDown event prior to passing it through the NSTextInputClient
machinery.


### HasDocument

| | |
| --- | --- |
| __Return__ | bool |

Returns true if a document has been loaded in the browser.


### IsFullscreen

| | |
| --- | --- |
| __Return__ | void |

Whether in fullscreen mode, see ToggleFullscreen().

This function is Windows-only.


### IsLoading

| | |
| --- | --- |
| __Return__ | bool |

Available only in CEF 3. Not yet implemented.

Returns true if the browser is currently loading.


### IsMouseCursorChangeDisabled

| | |
| --- | --- |
| __Return__ | bool |

Available only in CEF 3.

Returns true if mouse cursor change is disabled.


### IsPopup

| | |
| --- | --- |
| __Return__ | bool |

Returns true if the window is a popup window.


### IsWindowRenderingDisabled

| | |
| --- | --- |
| __Return__ | bool |

Returns true if window rendering is disabled.


### LoadUrl

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

Load url in the main frame.


### Navigate

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

This is an alias for the `LoadUrl` method.


### NotifyMoveOrResizeStarted

| | |
| --- | --- |
| __Return__ | void |

Notify the browser of move or resize events so that popup windows are
displayed in the correct location and dismissed when the window moves.
Also so that drag&drop areas are updated accordingly. In upstream
cefclient this method is being called only on Linux and Windows.


### NotifyScreenInfoChanged

| | |
| --- | --- |
| __Return__ | void |

Send a notification to the browser that the screen info has changed. The
browser will then call [RenderHandler](RenderHandler.md).GetScreenInfo() to update the
screen information with the new values. This simulates moving the webview
window from one display to another, or changing the properties of the
current display. This method is only used when window rendering is
disabled.


### ParentWindowWillClose

| | |
| --- | --- |
| __Return__ | void |

This method does nothing. Kept for BC.


### Reload

| | |
| --- | --- |
| __Return__ | void |

Reload the current page.


### ReloadIgnoreCache

| | |
| --- | --- |
| __Return__ | void |

Reload the current page ignoring any cached data.


### SetBounds

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| width | int |
| height | int |
| __Return__ | void |

Linux-only. Set window bounds.


### SendKeyEvent

| Parameter | Type |
| --- | --- |
| event | KeyEvent |
| __Return__ | void |

`KeyEvent` is a dictionary, see [KeyboardHandler](KeyboardHandler.md).OnPreKeyEvent()
for a description of the available keys.


### SendMouseClickEvent

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| mouseButtonType | int |
| mouseUp | bool |
| clickCount | int |
| __Return__ | void |

Send a mouse click event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view.

`mouseButtonType` may be one of:

cefpython.`MOUSEBUTTON_LEFT`
cefpython.`MOUSEBUTTON_MIDDLE`
cefpython.`MOUSEBUTTON_RIGHT`

TODO: allow to pass modifiers which represents bit flags
describing any pressed modifier keys. Modifiers can also
be passed to SendMouseMoveEvent(), SendMouseWheelEvent().
See cef_event_flags_t enum for modifiers values:

```
enum cef_event_flags_t {
        EVENTFLAG_NONE                = 0,
        EVENTFLAG_CAPS_LOCK_ON        = 1 << 0,
        EVENTFLAG_SHIFT_DOWN          = 1 << 1,
        EVENTFLAG_CONTROL_DOWN        = 1 << 2,
        EVENTFLAG_ALT_DOWN            = 1 << 3,
        EVENTFLAG_LEFT_MOUSE_BUTTON   = 1 << 4,
        EVENTFLAG_MIDDLE_MOUSE_BUTTON = 1 << 5,
        EVENTFLAG_RIGHT_MOUSE_BUTTON  = 1 << 6,
        // Mac OS-X command key.
        EVENTFLAG_COMMAND_DOWN        = 1 << 7,
        EVENTFLAG_NUM_LOCK_ON         = 1 << 8,
        EVENTFLAG_IS_KEY_PAD          = 1 << 9,
        EVENTFLAG_IS_LEFT             = 1 << 10,
        EVENTFLAG_IS_RIGHT            = 1 << 11,
```


### SendMouseMoveEvent

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| mouseLeave | bool |
| __Return__ | void |

Send a mouse move event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view.


### SendMouseWheelEvent

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| deltaX | int |
| deltaY | int |
| __Return__ | void |

Send a mouse wheel event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view. The |deltaX| and |deltaY| values represent the movement delta in the X and Y directions respectively. In order to scroll inside select popups with window rendering disabled [RenderHandler](RenderHandler.md).GetScreenPoint() should be implemented properly.


### SendFocusEvent

| Parameter | Type |
| --- | --- |
| setFocus | bool |
| __Return__ | void |

Send a focus event to the browser.


### SendCaptureLostEvent

| | |
| --- | --- |
| __Return__ | void |

Send a capture lost event to the browser.


### SetClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| callback | function |
| __Return__ | void |

Set client callback.


### SetClientHandler

| Parameter | Type |
| --- | --- |
| clientHandler | object |
| __Return__ | void |

Set client handler object (class instance), its members will be inspected. Private methods that are not meant to be callbacks should have their names prepended with an underscore.


### SetFocus

| Parameter | Type |
| --- | --- |
| focus | bool |
| __Return__ | void |

Set whether the browser is focused.


### SetMouseCursorChangeDisabled

| Parameter | Type |
| --- | --- |
| disabled | bool |
| __Return__ | void |

Set whether mouse cursor change is disabled.


### SetJavascriptBindings

| Parameter | Type |
| --- | --- |
| bindings | [JavascriptBindings](JavascriptBindings.md) |
| __Return__ | void |

Set javascript bindings.


### SetUserData

| Parameter | Type |
| --- | --- |
| key | mixed |
| value | mixed |
| __Return__ | void |

Set user data. Use this function to keep data associated with this browser. See also GetUserData().


### SetZoomLevel

| Parameter | Type |
| --- | --- |
| zoomLevel | float |
| __Return__ | void |

Change the zoom level to the specified value. Specify 0.0 to reset the zoom level. If called on the UI thread the change will be applied immediately. Otherwise, the change will be applied asynchronously on the UI thread.


### ShowDevTools

| | |
| --- | --- |
| __Return__ | void |

Open developer tools (DevTools) in its own browser. The DevTools browser
will remain associated with this browser. If the DevTools browser is
already open then it will be focused, in which case the |windowInfo|,
|client| and |settings| parameters will be ignored. If |inspect_element_at|
is non-empty then the element at the specified (x,y) location will be
inspected. The |windowInfo| parameter will be ignored if this browser is
wrapped in a CefBrowserView.


### StartDownload

| Parameter | Type |
| --- | --- |
| url | string |
| __Return__ | void |

Download the file at |url| using [DownloadHandler](DownloadHandler.md).


### StopLoad

| | |
| --- | --- |
| __Return__ | void |

Stop loading the page.


### StopFinding

| Parameter | Type |
| --- | --- |
| clearSelection | bool |
| __Return__ | void |

Cancel all searches that are currently going on.


### ToggleFullscreen

| | |
| --- | --- |
| __Return__ | bool |

Switch between fullscreen mode / windowed mode. To check whether in fullscreen mode call IsFullscreen().

This function is Windows-only.


### TryCloseBrowser

Helper for closing a browser. Call this method from the top-level window
close handler. Internally this calls CloseBrowser(false) if the close has
not yet been initiated. This method returns false while the close is
pending and true after the close has completed. See CloseBrowser() and
CefLifeSpanHandler::DoClose() documentation for additional usage
information. This method must be called on the browser process UI thread.


### WasResized

| | |
| --- | --- |
| __Return__ | void |

Notify the browser that the widget has been resized. The browser will
first call [RenderHandler](RenderHandler.md)::`GetViewRect` to get the new size and then
call [RenderHandler](RenderHandler.md)::`OnPaint` asynchronously with the updated regions.
This method is only used when window rendering is disabled.


### WasHidden

| Parameter | Type |
| --- | --- |
| hidden | bool |
| __Return__ | void |

Notify the browser that it has been hidden or shown. Layouting and
[RenderHandler](RenderHandler.md)::`OnPaint` notification will stop
when the browser is hidden. This method is only used when window
rendering is disabled.
