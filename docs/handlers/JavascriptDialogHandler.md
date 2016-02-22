# Javascript Dialog handler #

Implement this interface to handle events related to Javascript dialogs. The methods of this class will be called on the UI thread.

## JavascriptDialogCallback ##

Callback interface used for asynchronous continuation of Javascript dialog
requests.

void **Continue**(bool allow, str userInput)

> Continue the javascript dialog request. Set |allow| to true if the OK button was
> pressed. The |userInput| value should be specified for prompt dialogs.


## Callbacks ##

bool **OnJavascriptDialog**([Browser](Browser) browser, str origin\_url, str accept\_lang, int dialog\_type, str message\_text, str default\_prompt\_text, `JavascriptDialogCallback` callback, bool& suppress\_message`[0]`)

> Called to run a Javascript dialog. The |default\_prompt\_text| value will be
> specified for prompt dialogs only. Set |suppress\_message| to true and
> return false to suppress the message (suppressing messages is preferable
> to immediately executing the callback as this is used to detect presumably
> malicious behavior like spamming alert messages in onbeforeunload). Set
> |suppress\_message| to false and return false to use the default
> implementation (the default implementation will show one modal dialog at a
> time and suppress any additional dialog requests until the displayed dialog
> is dismissed). Return true if the application will use a custom dialog or
> if the callback has been executed immediately. Custom dialogs may be either
> modal or modeless. If a custom dialog is used the application must execute
> |callback| once the custom dialog is dismissed.

> The `dialog_type` param may be one of:
```
cefpython.JSDIALOGTYPE_ALERT
cefpython.JSDIALOGTYPE_CONFIRM
cefpython.JSDIALOGTYPE_PROMPT
```


bool **OnBeforeUnloadJavascriptDialog**([Browser](Browser) browser, str message\_text, bool is\_reload, `JavascriptDialogCallback` callback)

> Called to run a dialog asking the user if they want to leave a page. Return
> false to use the default dialog implementation. Return true if the
> application will use a custom dialog or if the callback has been executed
> immediately. Custom dialogs may be either modal or modeless. If a custom
> dialog is used the application must execute |callback| once the custom
> dialog is dismissed.


void **OnResetJavascriptDialogState**([Browser](Browser) browser)

> Called to cancel any pending dialogs and reset any saved dialog state. Will
> be called due to events like page navigation irregardless of whether any
> dialogs are currently pending.


void **OnJavascriptDialogClosed**([Browser](Browser) browser)

> Called when the default implementation dialog is closed.