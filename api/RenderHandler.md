[API categories](API-categories.md) | [API index](API-index.md)


# RenderHandler (interface)

Implement this interface to handle events when window rendering is disabled
(off-screen rendering). The methods of this class will be called on
the UI thread. In order to create windowless browsers the
[windowless_rendering_enabled](ApplicationSettings.md#windowless_rendering_enabled)
setting must be set to true.

Table of contents:
* [Examples](#examples)
* [Notes](#notes)
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
  * [OnTextSelectionChanged](#ontextselectionchanged)
  * [StartDragging](#startdragging)
  * [UpdateDragCursor](#updatedragcursor)


## Examples

Off-screen rendering examples:
* [Kivy](https://github.com/cztomczak/cefpython/wiki/Kivy)
* [Panda3D](https://github.com/cztomczak/cefpython/wiki/Panda3D)
  \- tested with v31
* [pygame + PyOpenGL](https://gist.github.com/AnishN/aa3bb27fc9d69319955ed9a8973cd40f)
  \- tested with v31, more info on this example on the Forum in
  [this post](https://groups.google.com/d/topic/cefpython/mwSa7He90xA/discussion) 
* [cefpython_offscreen_no_UI_framework.py](https://gist.github.com/stefanbacon/7b1571d57aee54aa9f8e9021b4848d06)
  \- most basic usage of OSR to take a screenshot of a page

## Notes

Callbacks available in upstream CEF, but not yet exposed in CEF Python
(see src/include/cef_render_handler.h):
* GetScreenInfo
* OnImeCompositionRangeChanged


## Callbacks


### GetRootScreenRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| rect_out | list[x,y,width,height] |
| __Return__ | bool |

Called to retrieve the root window rectangle in screen coordinates.
Return true if the rectangle was provided.


### GetViewRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| rect_out | list[x,y,width,height] |
| __Return__ | bool |

Called to retrieve the view rectangle which is relative to screen
coordinates. Return true if the rectangle was provided.


### GetScreenRect

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| rect_out | list[x,y,width,height] |
| __Return__ | bool |

Called to retrieve the simulated screen rectangle. Return true
if the rectangle was provided.


### GetScreenPoint

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| view_x | int |
| view_y | int |
| screen_coordinates_out | list[x,y] |
| __Return__ | bool |

Called to retrieve the translation from view coordinates to actual
screen coordinates. Return true if the screen coordinates were provided.


### OnPopupShow

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| show | bool |
| __Return__ | void |

Called when the browser wants to show or hide the popup widget.
The popup should be shown if |show| is true and hidden if|show|
is false.


### OnPopupSize

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| rect_out | list[x,y,width,height] |
| __Return__ | void |

Called when the browser wants to move or resize the popup widget.
|rect_out| contains the new location and size.


### OnPaint

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| element_type | PaintElementType |
| dirty_rects | list[[x,y,width,height],[..]] |
| paint_buffer | [PaintBuffer](PaintBuffer.md) |
| width | int |
| height | int |
| __Return__ | void |

Called when an element should be painted. Pixel values passed to this
method are scaled relative to view coordinates based on the value of
CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
indicates whether the element is the view or the popup widget. |buffer|
contains the pixel data for the whole image. |dirty_rects| contains the set
of rectangles in pixel coordinates that need to be repainted. |buffer| will
be |width|*|height|*4 bytes in size and represents a BGRA image with an
upper-left origin.

**Important:** Do not keep reference to |paint_buffer| after this
method returns.

`PaintElementType` enum:
* cef.PET_VIEW
* cef.PET_POPUP


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


### OnTextSelectionChanged

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| selected_text | str |
| selected_range | list[x, y] |
| __Return__ | void |

Description from upstream CEF:
> Called when text selection has changed for the specified |browser|.
> |selected_text| is the currently selected text and |selected_range| is
> the character range.

NOTE: this callback seems to be called only when selecting text
with a mouse. When selecting text programmatically using javascript
code it doesn't get called.


### StartDragging

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| drag_data | [DragData](DragData.md) |
| allowed_ops | int |
| x | int |
| y | int |
| __Return__ | void |

Description from upstream CEF:
> Called when the user starts dragging content in the web view. Contextual
> information about the dragged content is supplied by |drag_data|.
> (|x|, |y|) is the drag start location in screen coordinates.
> OS APIs that run a system message loop may be used within the
> StartDragging call.
>
> Return false to abort the drag operation. Don't call any of
> CefBrowserHost::DragSource*Ended* methods after returning false.
>
> Return true to handle the drag operation. Call
> CefBrowserHost::DragSourceEndedAt and DragSourceSystemDragEnded either
> synchronously or asynchronously to inform the web view that the drag
> operation has ended.


### UpdateDragCursor

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| operation | int |
| __Return__ | void |

Description from upstream CEF:
> Called when the web view wants to update the mouse cursor during a
> drag & drop operation. |operation| describes the allowed operation
> (none, move, copy, link).

See Browser.[DragSourceEndedAt](Browser.md#dragsourceendedat) for a list
of values for the operation enum.

