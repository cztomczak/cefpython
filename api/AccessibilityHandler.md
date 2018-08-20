[API categories](API-categories.md) | [API index](API-index.md)


# AccessibilityHandler (interface)

This handler is for use only with off-screen rendering enabled.
See [RenderHandler](RenderHandler.md) for details.

Implement this interface to receive accessibility notification when
accessibility events have been registered. The methods of this class will
be called on the UI thread.

Callbacks in this interface are not associated with any specific browser,
thus you must call
`cefpython`.[SetGlobalClientHandler](cefpython.md#setglobalclienthandler)
or [SetGlobalClientCallback](cefpython.md#setglobalclientcallback)
to use them. The callbacks names were prefixed
with "`_`" to distinguish this special behavior.


Table of contents:
* [Callbacks](#callbacks)
  * [_OnAccessibilityTreeChange](#_onaccessibilitytreechange)
  * [_OnAccessibilityLocationChange](#_onaccessibilitylocationchange)


## Callbacks


### _OnAccessibilityTreeChange

| Parameter | Type |
| --- | --- |
| value | list |
| __Return__ | void |

Called after renderer process sends accessibility tree changes to the
browser process.


### _OnAccessibilityLocationChange

| Parameter | Type |
| --- | --- |
| value | list |
| __Return__ | void |

Called after renderer process sends accessibility location changes to the
browser process.

