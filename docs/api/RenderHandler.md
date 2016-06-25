[API categories](API-categories.md) | [API index](API-index.md)


# RenderHandler (interface)

Implement this interface to handle events when window rendering is disabled
(off-screen rendering). The methods of this class will be called on the UI thread.

In order to create windowless browsers the
ApplicationSettings.[windowless_rendering_enabled](ApplicationSettings.md#windowless_rendering_enabled)
value must be set to true.

Callbacks not implemented yet:
* GetScreenInfo()

Off-screen rendering examples:
* [Kivy](https://github.com/cztomczak/cefpython/wiki/Kivy)
* [Panda3D](https://github.com/cztomczak/cefpython/wiki/Panda3D)
* [cefpython_offscreen_no_UI_framework.py](https://gist.github.com/stefanbacon/7b1571d57aee54aa9f8e9021b4848d06) -
  most basic usage of OSR to take screenshot of a page


Table of contents:
* [Callbacks](#callbacks)
  * [GetRootScreenRect](#getrootscreenrect)
  * [GetViewRect](#getviewrect)
  * [GetScreenRect](#getscreenrect)
  * [GetScreenPoint](#getscreenpoint)
  * [OnPopupShow](#onpopupshow)
  * [OnPopupSize](#onpopupsize)
  * [OnPaint](#onpaint)
  * [OnCursorChange](#oncursorchange)
  * [OnScrollOffsetChanged](#onscrolloffsetchanged)


## Callbacks


### GetRootScreenRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| out rect | list |
| __Return__ | bool |

Called to retrieve the root window rectangle in screen coordinates. Return true if the rectangle was provided.


### GetViewRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| out rect | list |
| __Return__ | bool |

Called to retrieve the view rectangle which is relative to screen coordinates. Return true if the rectangle was provided.

The `rect` list should contain 4 elements: [x, y, width, height].


### GetScreenRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| out rect | list |
| __Return__ | bool |

Called to retrieve the simulated screen rectangle. Return true if the rectangle was provided.

The `rect` list should contain 4 elements: [x, y, width, height].


### GetScreenPoint

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| viewX | int |
| viewY | int |
| out screenCoordinates | list |
| __Return__ | bool |

Called to retrieve the translation from view coordinates to actual screen coordinates. Return true if the screen coordinates were provided.

The `screenCoordinates` list should contain 2 elements: [x, y].


### OnPopupShow

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| show | bool |
| __Return__ | void |

Called when the browser wants to show or hide the popup widget. The popup should be shown if |show| is true and hidden if |show| is false.


### OnPopupSize

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| rect | list |
| __Return__ | void |

Called when the browser wants to move or resize the popup widget. |rect| contains the new location and size.

The `rect` list should contain 4 elements: [x, y, width, height].


### OnPaint

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| paintElementType | int |
| out  dirtyRects | list |
| buffer | [PaintBuffer](PaintBuffer.md) |
| width | int |
| height | int |
| __Return__ | void |

Called when an element should be painted. Pixel values passed to this
method are scaled relative to view coordinates based on the value of
CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
indicates whether the element is the view or the popup widget. |buffer|
contains the pixel data for the whole image. |dirtyRects| contains the set
of rectangles in pixel coordinates that need to be repainted. |buffer| will
be |width|*|height|*4 bytes in size and represents a BGRA image with an
upper-left origin.

`paintElementType` constants in the cefpython module:
* PET_VIEW
* PET_POPUP

`dirtyRects` is a list of rects: [[x, y, width, height], [..]]


### OnCursorChange

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| cursor | CursorHandle |
| __Return__ | void |

Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
|custom_cursor_info| will be populated with the custom cursor information.

`CursorHandle` is an int pointer.


### OnScrollOffsetChanged

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| __Return__ | void |

Called when the scroll offset has changed.
