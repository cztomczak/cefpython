[API categories](API-categories.md) | [API index](API-index.md)


# WindowInfo (class)

This class is passed to functions eg.
[cefpython](cefpython.md).CreateBrowserSync(),
[LifespanHandler](LifespanHandler.md).OnBeforePopup().

To instantiate this class call: [cefpython](cefpython.md).WindowInfo().


Table of contents:
* [Methods](#methods)
  * [SetAsChild](#setaschild)
  * [SetAsPopup](#setaspopup)
  * [SetAsOffscreen](#setasoffscreen)

## Methods


### SetAsChild

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| windowRect (optional) | list |
| __Return__ | void |

Create the browser as a child window/view.

`windowRect` example value: [left, top, right, bottom].


### SetAsPopup

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| windowName | string |
| __Return__ | void |

Available only on Windows.


### SetAsOffscreen

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| __Return__ | void |

Description from upstream CEF:
> Create the browser using windowless (off-screen) rendering. No window
will be created for the browser and all rendering will occur via the
CefRenderHandler interface. The |parent| value will be used to identify
monitor info and to act as the parent window for dialogs, context menus,
etc. If |parent| is not provided then the main screen monitor will be used
and some functionality that requires a parent window may not function
correctly. In order to create windowless browsers the
CefSettings.windowless_rendering_enabled value must be set to true.
Transparent painting is enabled by default but can be disabled by setting
CefBrowserSettings.background_color to an opaque value.

Call this method to disable windowed rendering and to use
[RenderHandler](RenderHandler.md). See the pysdl2, screenshot, panda3d
and kivy examples.

In order to create windowless browsers the
ApplicationSettings.[windowless_rendering_enabled](ApplicationSettings.md#windowless_rendering_enabled)
value must be set to true.

You can pass 0 as `parentWindowHandle`, but then some things like
context menus and plugins may not display correctly.

