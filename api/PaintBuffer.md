[API categories](API-categories.md) | [API index](API-index.md)


# PaintBuffer (object)

This object used in: [RenderHandler](RenderHandler.md).OnPaint().


Table of contents:
* [Methods](#methods)
  * [GetPointer](#getpointer)
  * [GetBytes](#getbytes)


## Methods


### GetPointer

| | |
| --- | --- |
| __Return__ | int |

Get int pointer to the `void*` buffer.

Description from upstream CEF:
> |buffer| will be |width|*|height|*4 bytes in size and represents a BGRA
> image with an upper-left origin.


### GetBytes

| Parameter | Type |
| --- | --- |
| mode="bgra" | string |
| origin="top-left" | string |
| __Return__ | object |

Converts the `void*` buffer to bytes.

`origin` may be one of: "top-left", "bottom-left".

`mode` may be one of: "bgra", "rgba".
