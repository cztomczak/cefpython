[API categories](API-categories.md) | [API index](API-index.md)


# FocusHandler (interface)

Implement this interface to handle events related to focus. The methods of
this class will be called on the UI thread.


Table of contents:
* [Callbacks](#callbacks)
  * [OnTakeFocus](#ontakefocus)
  * [OnSetFocus](#onsetfocus)
  * [OnGotFocus](#ongotfocus)


## Callbacks


### OnTakeFocus

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| next_component | bool |
| __Return__ | void |

Description from upstream CEF:
> Called when the browser component is about to loose focus. For instance, if
> focus was on the last HTML element and the user pressed the TAB key. |next|
> will be true if the browser is giving focus to the next component and false
> if the browser is giving focus to the previous component.


### OnSetFocus

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| source | cef_focus_source_t |
| __Return__ | bool |

Description from upstream CEF:
> Called when the browser component is requesting focus. |source| indicates
> where the focus request is originating from. Return false to allow the
> focus to be set or true to cancel setting the focus.

The `cef_focus_source_t` enum constants in the cefpython module:
* FOCUS_SOURCE_NAVIGATION (The source is explicit navigation
  via the API (LoadURL(), etc))
* FOCUS_SOURCE_SYSTEM (The source is a system-generated focus event)


### OnGotFocus

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Description from upstream CEF:
> Called when the browser component has received focus.
