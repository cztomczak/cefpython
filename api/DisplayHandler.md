[API categories](API-categories.md) | [API index](API-index.md)


# DisplayHandler (interface)

Implement this interface to handle events related to browser display state. The methods of this class will be called on the UI thread.

For an example of how to implement handler see [cefpython](cefpython.md).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).


Table of contents:
* [Callbacks](#callbacks)
  * [OnAddressChange](#onaddresschange)
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
| message | string |
| source | string |
| line | int |
| __Return__ | bool |

Called to display a console message. Return true to stop the message from
being output to the console.
