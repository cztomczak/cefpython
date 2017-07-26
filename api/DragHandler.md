[API categories](API-categories.md) | [API index](API-index.md)


# DragHandler (interface)

Implement this interface to handle events related to dragging. The methods of this class will be called on the UI thread.


Table of contents:
* [Callbacks](#callbacks)
  * [OnDragEnter](#ondragenter)

## Callbacks


### OnDragEnter

| Parameter | Type |
| --- | --- |
| browser | [Browser](Browser.md) |
| dragData | [DragData](DragData.md) |
| mask | int |
| __Return__ | bool |

 Called when an external drag event enters the browser window.

