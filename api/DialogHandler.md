[API categories](API-categories.md) | [API index](API-index.md)


# DialogHandler (interface)

Description from upstream CEF:
> Implement this interface to handle dialog events. The methods of this class will be called on the browser process UI thread.


Table of contents:
* [Callbacks](#callbacks)
  * [OnFileDialog](#onfiledialog)

## Callbacks


### OnFileDialog

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| mode | int |
| title | string |
| default_file_path | string |
| accept_filters | list |
| selected_accept_filter | int |
| file_dialog_callback | [FileDialogCallback](FileDialogCallback.md)|
| __Return__ | bool |

Description from upstream CEF:
>  Called to run a file chooser dialog.
