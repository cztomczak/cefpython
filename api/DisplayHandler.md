[API categories](API-categories.md) | [API index](API-index.md)


# DisplayHandler (interface)

Implement this interface to handle events related to browser display state. The methods of this class will be called on the UI thread.

For an example of how to implement handler see [cefpython](cefpython.md).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).


Table of contents:
* [Callbacks](#callbacks)
  * [OnAddressChange](#onaddresschange)
  * [OnAutoResize](#onautoresize)
  * [OnTitleChange](#ontitlechange)
  * [OnTooltip](#ontooltip)
  * [OnStatusMessage](#onstatusmessage)
  * [OnConsoleMessage](#onconsolemessage)


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


### OnStatusMessage

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| value | string |
| __Return__ | void |

Called when the browser receives a status message.


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

