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
  * [GetParentHandle](#getparenthandle)
  * [IsWindowHandle](#iswindowhandle)
  * [gtk_plug_new (Linux)](#gtk_plug_new-linux)
  * [gtk_widget_show (Linux)](#gtk_widget_show-linux)
  * [InstallX11ErrorHandlers (Linux)](#installx11errorhandlers-linux)
  * [GetX11DefaultVisualId (Linux)](#getx11defaultvisualid-linux)
  * [SetX11DefaultVisualForGtkWidget (Linux)](#setx11defaultvisualforgtkwidget-linux)


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


### GetX11DefaultVisualId (Linux)

| Parameter | Type |
| --- | --- |
| screen_number | int |
| __Return__ | int |

Linux-only. Returns the ID of the X server's default visual for the
given X screen, or 0 on failure. Must be called on the UI thread after
[cefpython](cefpython.md).Initialize().

With GTK 3 the browser may stay blank unless the window it is embedded
into uses this visual (Issue #701, CEF issue
[#3564](https://github.com/chromiumembedded/cef/issues/3564)). Set it
before the window is realized, as the gtk3.py example does:

```python
screen = window.get_screen()
window.set_visual(GdkX11.X11Screen.lookup_visual(
        screen, cef.WindowUtils.GetX11DefaultVisualId(
                screen.get_screen_number())))
```

For toolkits that have no API to set the visual, see
SetX11DefaultVisualForGtkWidget().


### SetX11DefaultVisualForGtkWidget (Linux)

| Parameter | Type |
| --- | --- |
| gtkWidgetPtr | int |
| __Return__ | bool |

Linux-only. Puts a GTK 3 widget on the X server's default visual, see
GetX11DefaultVisualId(). Returns False on failure. Call it on the UI
thread after [cefpython](cefpython.md).Initialize() and before the widget
is realized. It is meant for toolkits that have no API to set the visual,
e.g. the wxpython.py example passes `int(frame.GetGtkWidget())`.
