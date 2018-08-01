[API categories](API-categories.md) | [API index](API-index.md)


# PaintBuffer (object)

This object used in: [RenderHandler](RenderHandler.md).OnPaint().


Table of contents:
* [Methods](#methods)
  * [GetIntPointer](#getintpointer)
  * [GetBytes](#getbytes)


## Methods


### GetIntPointer

| | |
| --- | --- |
| __Return__ | long |

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

Converts the `void*` buffer to string. In Py2 returns 'str' type, in Py3 returns 'bytes' type.

`origin` may be one of: "top-left", "bottom-left".

`mode` may be one of: "bgra", "rgba".
