[API categories](API-categories.md) | [API index](API-index.md)


# WindowUtils (class)

All methods of this class are static. Many of the Windows-only functions here are utilized in the PyWin32 example.


Table of contents:
* [Methods](#methods)
  * [OnSetFocus (Win)](#onsetfocus-win)
  * [OnSize (Win)](#onsize-win)
  * [OnEraseBackground (Win)](#onerasebackground-win)
  * [SetTitle (Win)](#settitle-win)
  * [SetIcon (Win)](#seticon-win)
  * [UpdateBrowserSize (Win)](#updatebrowsersize-win)
  * [GetParentHandle](#getparenthandle)
  * [IsWindowHandle](#iswindowhandle)
  * [gtk_plug_new (Linux)](#gtk_plug_new-linux)
  * [gtk_widget_show (Linux)](#gtk_widget_show-linux)
  * [InstallX11ErrorHandlers (Linux)](#installx11errorhandlers-linux)


## Methods


### OnSetFocus (Win)

| Parameter | Type |
| --- | --- |
| windowHandle | int |
| msg | long |
| wparam | long |
| lparam | long |
| __Return__ | void |

Windows-only. This method processes WM_SETFOCUS message which is sent to a window after it has gained the keyboard focus.


### OnSize (Win)

| Parameter | Type |
| --- | --- |
| windowHandle | int |
| msg | long |
| wparam | long |
| lparam | long |
| __Return__ | void |

Windows-only. This method processes WM_SIZE message which is sent to a window after its size has changed.

Do not call this function unless you know what you're doing, as it
can sometimes cause app hanging during window resize. You should
call instead the `UpdateBrowserSize` method with the help of
`cef.PostTask`.


### OnEraseBackground (Win)

| Parameter | Type |
| --- | --- |
| windowHandle | int |
| msg | long |
| wparam | long |
| lparam | long |
| __Return__ | void |

Windows-only. This method processes WM_ERASEBKGND message which is sent when the window background must be erased (for example, when a window is resized).


### SetTitle (Win)

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| title | str |
| __Return__ | void |

Windows-only. Set the title for the main window or popup window. The default implementation of [DisplayHandler](DisplayHandler.md).OnTitleChange() calls this method to set the title for a window.


### SetIcon (Win)

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| icon="inherit" | string |
| __Return__ | void |

Windows-only. Set the icon for the popup window. The default implementation of [DisplayHandler](DisplayHandler.md).OnTitleChange() calls this method to set the icon for a window that wasn't created explicitily (for example a popup window), the icon is inherited from the parent window. Icon parameter accepts only "inherit", you cannot pass here a path to an icon (currently not implemented).


### UpdateBrowserSize (Win)

| Parameter | Type |
| --- | --- |
| parent_window_handle | int |
| browser | [Browser](Browser.md) |
| redraw=True (optional) | bool |
| __Return__ | void |

Windows-only. This function will resize browser using client coordinates
from the parent window in which browser is embedded. You should
call this function during a size event of your app window.


### GetParentHandle

| Parameter | Type |
| --- | --- |
| windowHandle | int |
| __Return__ | void |

Get a parent handle.

On Linux and Mac this method always returns 0. @TODO.


### IsWindowHandle

| Parameter | Type |
| --- | --- |
| windowHandle | int |
| __Return__ | void |

Check whether this is a valid window handle.

On Linux and Mac this method always returns True. @TODO.


### gtk_plug_new (Linux)

| Parameter | Type |
| --- | --- |
| long GdkNativeWindow | long |
| __Return__ | void |

Linux-only.


### gtk_widget_show (Linux)

| Parameter | Type |
| --- | --- |
| long GtkWidget* | long |
| __Return__ | void |

Linux-only.


### InstallX11ErrorHandlers (Linux)

| | |
| --- | --- |
| __Return__ | void |

Linux-only. Install xlib error handlers so that the application
won't be terminated on non-fatal errors. Must be done after
initializing GTK.

CEF Python calls this function automatically during a call to
Initialize, so there is no more need to call it manually in
most cases.
