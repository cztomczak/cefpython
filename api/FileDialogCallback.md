[API categories](API-categories.md) | [API index](API-index.md)


# FileDialogCallback (object)

Description from upstream CEF:
> Callback interface for asynchronous continuation of file dialog requests.


Table of contents:
* [Methods](#methods)
  * [Cancel](#cancel)
  * [Continue](#continue)


## Methods


### Cancel

| Parameter | Type |
| --- | --- |
| __Return__ | void |

Description from upstream CEF:
> Cancel the file selection.


### Continue

| Parameter | Type |
| --- | --- |
| selected_accept_filter | int |
| file_paths | list |
| __Return__ | void |

Description from upstream CEF:
> Continue the file selection. |selected_accept_filter| should be the 0-based index of the value selected from the accept filters array passed to CefDialogHandler::OnFileDialog. |file_paths| should be a single value or a list of values depending on the dialog mode. An empty |file_paths| value is treated the same as calling Cancel().