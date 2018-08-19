[API categories](API-categories.md) | [API index](API-index.md)


# DisplayHandler (interface)

Implement this interface to handle events related to browser display
state. The methods of this class will be called on the UI thread.


Table of contents:
* [Callbacks](#callbacks)
  * [OnAddressChange](#onaddresschange)
  * [OnAutoResize](#onautoresize)
  * [OnConsoleMessage](#onconsolemessage)
  * [OnLoadingProgressChange](#onloadingprogresschange)
  * [OnStatusMessage](#onstatusmessage)
  * [OnTitleChange](#ontitlechange)
  * [OnTooltip](#ontooltip)


## Callbacks


### OnAddressChange

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| frame | [Frame](Frame.md) |
| url | string |
| __Return__ | void |

Called when a frame's address has changed.



### OnAutoResize

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| new_size | list[width, height] |
| __Return__ | bool |

Description from upstream CEF:
> Called when auto-resize is enabled via CefBrowserHost::SetAutoResizeEnabled
> and the contents have auto-resized. |new_size| will be the desired size in
> view coordinates. Return true if the resize was handled or false for
> default handling.


### OnConsoleMessage

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| level | int |
| message | string |
| source | string |
| line | int |
| __Return__ | bool |

Called to display a console message. Return true to stop the message from
being output to the console.

|level| can be one of the same values as in ApplicationSettings.[log_severity](ApplicationSettings.md#log_severity).


### OnLoadingProgressChange

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| progress | double |
| __Return__ | void |

Description from upstream CEF:
> Called when the overall page loading progress has changed. |progress|
> ranges from 0.0 to 1.0.


### OnStatusMessage

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| value | string |
| __Return__ | void |

Called when the browser receives a status message.


### OnTitleChange

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| title | string |
| __Return__ | void |

Called when the page title changes.


### OnTooltip

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| text_out | list |
| __Return__ | bool |

Called when the browser is about to display a tooltip. `text_out[0]` contains the
text that will be displayed in the tooltip. To handle the display of the
tooltip yourself return true. Otherwise, you can optionally modify `text_out[0]`
and then return false to allow the browser to display the tooltip.
When window rendering is disabled the application is responsible for
drawing tooltips and the return value is ignored.
