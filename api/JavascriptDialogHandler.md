[API categories](API-categories.md) | [API index](API-index.md)


# JavascriptDialogHandler (interface)

Implement this interface to handle events related to Javascript dialogs. The methods of this class will be called on the UI thread.


Table of contents:
* [JavascriptDialogCallback](#javascriptdialogcallback)
  * [Continue](#continue)
* [Callbacks](#callbacks)
  * [OnJavascriptDialog](#onjavascriptdialog)
  * [OnBeforeUnloadJavascriptDialog](#onbeforeunloadjavascriptdialog)
  * [OnResetJavascriptDialogState](#onresetjavascriptdialogstate)
  * [OnJavascriptDialogClosed](#onjavascriptdialogclosed)


## JavascriptDialogCallback

Callback interface used for asynchronous continuation of Javascript dialog
requests.


### Continue

| Parameter | Type |
| --- | --- |
| allow | bool |
| user_input | str |
| __Return__ | void |

Continue the javascript dialog request. Set |allow| to true if the OK button was
pressed. The |user_input| value should be specified for prompt dialogs.


## Callbacks


### OnJavascriptDialog

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| origin_url | str |
| dialog_type | int |
| message_text | str |
| default_prompt_text | str |
| callback | JavascriptDialogCallback |
| suppress_message_out | list |
| __Return__ | bool |

Called to run a JavaScript dialog. If |origin_url| is non-empty it can be
passed to the CefFormatUrlForSecurityDisplay function to retrieve a secure
and user-friendly display string. The |default_prompt_text| value will be
specified for prompt dialogs only. Set |suppress_message_out[0]| to true and
return false to suppress the message (suppressing messages is preferable to
immediately executing the callback as this is used to detect presumably
malicious behavior like spamming alert messages in onbeforeunload). Set
|suppress_message_out[0]| to false and return false to use the default
implementation (the default implementation will show one modal dialog at a
time and suppress any additional dialog requests until the displayed dialog
is dismissed). Return true if the application will use a custom dialog or
if the callback has been executed immediately. Custom dialogs may be either
modal or modeless. If a custom dialog is used the application must execute
|callback| once the custom dialog is dismissed.

The `dialog_type` constants available in the cefpython module:
* JSDIALOGTYPE_ALERT
* JSDIALOGTYPE_CONFIRM
* JSDIALOGTYPE_PROMPT


### OnBeforeUnloadJavascriptDialog

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| message_text | str |
| is_reload | bool |
| callback | JavascriptDialogCallback |
| __Return__ | bool |

Called to run a dialog asking the user if they want to leave a page. Return
false to use the default dialog implementation. Return true if the
application will use a custom dialog or if the callback has been executed
immediately. Custom dialogs may be either modal or modeless. If a custom
dialog is used the application must execute |callback| once the custom
dialog is dismissed.


### OnResetJavascriptDialogState

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called to cancel any pending dialogs and reset any saved dialog state. Will
be called due to events like page navigation irregardless of whether any
dialogs are currently pending.


### OnJavascriptDialogClosed

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called when the default implementation dialog is closed.
