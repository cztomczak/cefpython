[API categories](API-categories.md) | [API index](API-index.md)


# Browser (object)

The methods of this object may be called on any thread unless otherwise
indicated in the comments.

Remember to free all browser references when closing app
for the browser to shut down cleanly.
Otherwise data such as cookies or other storage might not be flushed to disk
when closing app, and other issues might occur as well. To free a reference
just assign a None value to a browser variable.

To compare browser objects always use [GetIdentifier()](#getidentifier)
method. Do not compare two Browser objects variables directly.


Table of contents:
* [Notes](#notes)
* [Methods](#methods)
  * [AddWordToDictionary](#addwordtodictionary)
  * [CanGoBack](#cangoback)
  * [CanGoForward](#cangoforward)
  * [CloseBrowser](#closebrowser)
  * [CloseDevTools](#closedevtools)
  * [DragTargetDragEnter](#dragtargetdragenter)
  * [DragTargetDragOver](#dragtargetdragover)
  * [DragTargetDragLeave](#dragtargetdragleave)
  * [DragTargetDrop](#dragtargetdrop)
  * [DragSourceEndedAt](#dragsourceendedat)
  * [DragSourceSystemDragEnded](#dragsourcesystemdragended)
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
  * [GetImage](#getimage)
  * [GetJavascriptBindings](#getjavascriptbindings)
  * [GetMainFrame](#getmainframe)
  * [GetNSTextInputContext](#getnstextinputcontext)
  * [GetOpenerWindowHandle](#getopenerwindowhandle)
  * [GetOuterWindowHandle](#getouterwindowhandle)
  * [GetSetting](#getsetting)
  * [GetUrl](#geturl)
  * [GetUserData](#getuserdata)
  * [GetWindowHandle](#getwindowhandle)
  * [GetIdentifier](#getidentifier)
  * [GetZoomLevel](#getzoomlevel)
  * [GoBack](#goback)
  * [GoForward](#goforward)
  * [HandleKeyEventAfterTextInputClient](#handlekeyeventaftertextinputclient)
  * [HandleKeyEventBeforeTextInputClient](#handlekeyeventbeforetextinputclient)
  * [HasDevTools](#hasdevtools)
  * [HasDocument](#hasdocument)
  * [Invalidate](#invalidate)
  * [IsFullscreen](#isfullscreen)
  * [IsLoading](#isloading)
  * [IsPopup](#ispopup)
  * [IsWindowRenderingDisabled](#iswindowrenderingdisabled)
  * [LoadUrl](#loadurl)
  * [Navigate](#navigate)
  * [NotifyMoveOrResizeStarted](#notifymoveorresizestarted)
  * [NotifyScreenInfoChanged](#notifyscreeninfochanged)
  * [ParentWindowWillClose](#parentwindowwillclose)
  * [Print](#print)
  * [Reload](#reload)
  * [ReloadIgnoreCache](#reloadignorecache)
  * [ReplaceMisspelling](#replacemisspelling)
  * [SetAutoResizeEnabled](#setautoresizeenabled)
  * [SetBounds](#setbounds)
  * [SendKeyEvent](#sendkeyevent)
  * [SendMouseClickEvent](#sendmouseclickevent)
  * [SendMouseMoveEvent](#sendmousemoveevent)
  * [SendMouseWheelEvent](#sendmousewheelevent)
  * [SendCaptureLostEvent](#sendcapturelostevent)
  * [SetAccessibilityState](#setaccessibilitystate)
  * [SetClientCallback](#setclientcallback)
  * [SetClientHandler](#setclienthandler)
  * [SetFocus](#setfocus)
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

Methods available in upstream CEF which were not yet exposed in CEF Python
(see src/include/cef_browser.h):

* ImeSetComposition
* ImeCommitText
* ImeFinishComposingText
* ImeCancelComposition

There are some edge cases when after the OnBeforeClose event browser objects
are no more globally referenced thus a new instance is created that
wraps upstream CefBrowser object. Browser objects that were globally
unreferenced do not have properties of the original Browser object,
for example they do not have client callbacks, javascript bindings
or user data set.

## Methods


### AddWordToDictionary

| Parameter | Type |
| --- | --- |
| word | string |
| __Return__ | void |

Add the specified |word| to the spelling dictionary.


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


### DragTargetDragEnter

| Parameter | Type |
| --- | --- |
| drag_data | [DragData](DragData.md) |
| x | int |
| y | int |
| allowed_ops | int |
| __Return__ | void |

Description from upstream CEF:
> Call this method when the user drags the mouse into the web view (before
> calling DragTargetDragOver/DragTargetLeave/DragTargetDrop).
> |drag_data| should not contain file contents as this type of data is not
> allowed to be dragged into the web view. File contents can be removed using
> CefDragData::ResetFileContents (for example, if |drag_data| comes from
> CefRenderHandler::StartDragging).
> This method is only used when window rendering is disabled.


### DragTargetDragOver

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| allowed_ops | int |
| __Return__ | void |

Description from upstream CEF:
> Call this method each time the mouse is moved across the web view during
> a drag operation (after calling DragTargetDragEnter and before calling
> DragTargetDragLeave/DragTargetDrop).
> This method is only used when window rendering is disabled.


### DragTargetDragLeave

| | |
| --- | --- |
| __Return__ | void |

Description from upstream CEF:
> Call this method when the user drags the mouse out of the web view (after
> calling DragTargetDragEnter).
> This method is only used when window rendering is disabled.


### DragTargetDrop

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| __Return__ | void |

Description from upstream CEF:
> Call this method when the user completes the drag operation by dropping
> the object onto the web view (after calling DragTargetDragEnter).
> The object being dropped is |drag_data|, given as an argument to
> the previous DragTargetDragEnter call.
> This method is only used when window rendering is disabled.


### DragSourceEndedAt

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| operation | int |
| __Return__ | void |

Description from upstream CEF:
> Call this method when the drag operation started by a
> CefRenderHandler::StartDragging call has ended either in a drop or
> by being cancelled. |x| and |y| are mouse coordinates relative to the
> upper-left corner of the view. If the web view is both the drag source
> and the drag target then all DragTarget* methods should be called before
> DragSource* mthods.
> This method is only used when window rendering is disabled.

Operation enum from upstream CEF - these constants are declared in the
`cefpython` module:
> DRAG_OPERATION_NONE    = 0,
> DRAG_OPERATION_COPY    = 1,
> DRAG_OPERATION_LINK    = 2,
> DRAG_OPERATION_GENERIC = 4,
> DRAG_OPERATION_PRIVATE = 8,
> DRAG_OPERATION_MOVE    = 16,
> DRAG_OPERATION_DELETE  = 32,
> DRAG_OPERATION_EVERY   = UINT_MAX


### DragSourceSystemDragEnded

| | |
| --- | --- |
| __Return__ | void |

Description from upstream CEF:
> Call this method when the drag operation started by a
> CefRenderHandler::StartDragging call has completed. This method may be
> called immediately without first calling DragSourceEndedAt to cancel a
> drag operation. If the web view is both the drag source and the drag
> target then all DragTarget* methods should be called before DragSource*
> mthods.
> This method is only used when window rendering is disabled.


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
| scriptUrl="" | string |
| startLine=1 | int |
| __Return__ | void |

Execute a string of JavaScript code in this frame. The `scriptURL` parameter is the URL where the script in question can be found, if any. The renderer may request this URL to show the developer the source of the error.  The `startLine` parameter is the base line number to use for error reporting.

This function executes asynchronously so there is no way to get the returned value.

Calling javascript from native code synchronously is not possible in CEF 3. It is also not possible doing it synchronously the other way around ie. js->native.


### Find

| Parameter | Type |
| --- | --- |
| searchId | int |
| searchText | string |
| forward | bool |
| matchCase | bool |
| findNext | bool |
| __Return__ | void |

Description from upstream CEF:

> Search for |searchText|. |identifier| must be a unique ID and these IDs
> must strictly increase so that newer requests always have greater IDs than
> older requests. If |identifier| is zero or less than the previous ID value
> then it will be automatically assigned a new valid ID. |forward| indicates
> whether to search forward or backward within the page. |matchCase|
> indicates whether the search should be case-sensitive. |findNext| indicates
> whether this is the first request or a follow-up. The CefFindHandler
> instance, if any, returned via CefClient::GetFindHandler will be called to
> report find results.

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


### GetImage

| | |
| --- | --- |
| __Return__ | tuple(bytes buffer, int width, int height) |

Currently available only on Linux (Issue [#427](../../../issues/427)).

Get browser contents as image. Only screen visible contents are returned.

Returns an RGB buffer which can be converted to an image
using PIL library with such code:

```py
from PIL import Image, ImageFile
buffer_len = (width * 3 + 3) & -4
image = Image.frombytes("RGB", (width, height), data,
                         "raw", "RGB", buffer_len, 1)
ImageFile.MAXBLOCK = width * height
image.save("image.png", "PNG")
```


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


### GetSetting

| Parameter | Type |
| --- | --- |
| key | str |
| __Return__ | mixed |

Get a browser setting. You can set browser settings by passing
`settings` parameter to `cef.CreateBrowserSync`.


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

Returns the globally unique identifier for this browser. This value is also
used as the tabId for extension APIs.


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


### HasDevTools

| | |
| --- | --- |
| __Return__ | bool |

Description from upstream CEF:
> Returns true if this browser currently has an associated DevTools browser.
> Must be called on the browser process UI thread.


### HasDocument

| | |
| --- | --- |
| __Return__ | bool |

Returns true if a document has been loaded in the browser.


### Invalidate

| | |
| --- | --- |
| element_type | PaintElementType |
| __Return__ | void |

Description from upstream CEF:
> Invalidate the view. The browser will call CefRenderHandler::OnPaint
> asynchronously. This method is only used when window rendering is
> disabled.

`PaintElementType` enum values defined in cefpython module:
* PET_VIEW
* PET_POPUP


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

If the url is a local path it needs to start with the `file://` prefix.
If the url contains special characters it may need proper handling.
Starting with v66.1+ it is required for the app code to encode the url
properly. You can use the `pathlib.PurePath.as_uri` in Python 3
or `urllib.pathname2url` in Python 2 (`urllib.request.pathname2url`
in Python 3) depending on your case.


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

Notify the browser of move or resize events so that popup widgets
(e.g. `<select>`) are displayed in the correct location and dismissed
when the window moves. Also so that drag&drop areas are updated
accordingly. In upstream cefclient this method is being called
only on Linux and Windows.


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


### Print

| | |
| --- | --- |
| __Return__ | void |

Print the current browser contents.


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


### ReplaceMisspelling

| Parameter | Type |
| --- | --- |
| word | string |
| __Return__ | void |

If a misspelled word is currently selected in an editable node calling
this method will replace it with the specified |word|.


### SetAutoResizeEnabled

| Parameter | Type |
| --- | --- |
| enabled | bool |
| min_size | list[width, height] |
| max_size | list[width, heifght] |
| __Return__ | void |

Description from upstream CEF:
> Enable notifications of auto resize via CefDisplayHandler::OnAutoResize.
> Notifications are disabled by default. |min_size| and |max_size| define the
> range of allowed sizes.


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
| modifiers | int |
| __Return__ | void |

Send a mouse click event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view.

`mouseButtonType` may be one of:

cefpython.`MOUSEBUTTON_LEFT`
cefpython.`MOUSEBUTTON_MIDDLE`
cefpython.`MOUSEBUTTON_RIGHT`

`modifiers` flags:

* EVENTFLAG_NONE
* EVENTFLAG_CAPS_LOCK_ON
* EVENTFLAG_SHIFT_DOWN
* EVENTFLAG_CONTROL_DOWN
* EVENTFLAG_ALT_DOWN
* EVENTFLAG_LEFT_MOUSE_BUTTON
* EVENTFLAG_MIDDLE_MOUSE_BUTTON
* EVENTFLAG_RIGHT_MOUSE_BUTTON
* EVENTFLAG_COMMAND_DOWN (Mac)
* EVENTFLAG_NUM_LOCK_ON (Mac)
* EVENTFLAG_IS_KEY_PAD (Mac)
* EVENTFLAG_IS_LEFT (Mac)
* EVENTFLAG_IS_RIGHT (Mac)


### SendMouseMoveEvent

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| mouseLeave | bool |
| modifiers | int |
| __Return__ | void |

Send a mouse move event to the browser. The |x| and |y| coordinates are
relative to the upper-left corner of the view. For a list of modifiers
flags see SendMouseClickEvent().


### SendMouseWheelEvent

| Parameter | Type |
| --- | --- |
| x | int |
| y | int |
| deltaX | int |
| deltaY | int |
| modifiers | int |
| __Return__ | void |

Send a mouse wheel event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view. The |deltaX| and |deltaY| values represent the movement delta in the X and Y directions respectively. In order to scroll inside select popups with window rendering disabled [RenderHandler](RenderHandler.md).GetScreenPoint() should be implemented properly. For a list of modifiers flags see SendMouseClickEvent().


### SendCaptureLostEvent

| | |
| --- | --- |
| __Return__ | void |

Send a capture lost event to the browser.


### SetAccessibilityState

| | |
| --- | --- |
| state | cef_state_t |
| __Return__ | void |

cef_state_t enum values defined in cefpython module:
- STATE_DEFAULT
- STATE_ENABLED
- STATE_DISABLED

Description from upstream CEF:
> Set accessibility state for all frames. |accessibility_state| may be
> default, enabled or disabled. If |accessibility_state| is STATE_DEFAULT
> then accessibility will be disabled by default and the state may be further
> controlled with the "force-renderer-accessibility" and
> "disable-renderer-accessibility" command-line switches. If
> |accessibility_state| is STATE_ENABLED then accessibility will be enabled.
> If |accessibility_state| is STATE_DISABLED then accessibility will be
> completely disabled.
>
> For windowed browsers accessibility will be enabled in Complete mode (which
> corresponds to kAccessibilityModeComplete in Chromium). In this mode all
> platform accessibility objects will be created and managed by Chromium's
> internal implementation. The client needs only to detect the screen reader
> and call this method appropriately. For example, on macOS the client can
> handle the @"AXEnhancedUserInterface" accessibility attribute to detect
> VoiceOver state changes and on Windows the client can handle WM_GETOBJECT
> with OBJID_CLIENT to detect accessibility readers.
>
> For windowless browsers accessibility will be enabled in TreeOnly mode
> (which corresponds to kAccessibilityModeWebContentsOnly in Chromium). In
> this mode renderer accessibility is enabled, the full tree is computed, and
> events are passed to CefAccessibiltyHandler, but platform accessibility
> objects are not created. The client may implement platform accessibility
> objects using CefAccessibiltyHandler callbacks if desired.

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

Set client handler object (class instance), its members will be inspected.
Private methods that are not meant to be callbacks should have their names
prepended with an underscore.

You can call this method multiple times with to set many handlers. For
example you can create in your code several objects named LoadHandler,
LifespanHandler etc.


### SetFocus

| Parameter | Type |
| --- | --- |
| focus | bool |
| __Return__ | void |

Set whether the browser is focused.


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
