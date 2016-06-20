[API categories](API-categories.md) | [API index](API-index.md)


# PaintBuffer (object)

This object is related to: [Browser](Browser.md).GetImage() and [RenderHandler](RenderHandler.md).OnPaint().


Table of contents:
* [Methods](#methods)
  * [GetIntPointer](#getintpointer)
  * [GetString](#getstring)


## Methods


### GetIntPointer

| | |
| --- | --- |
| __Return__ | long |

Get int pointer to the `void*` buffer.


### GetString

| Parameter | Type |
| --- | --- |
| mode="bgra" | string |
| origin="top-left" | string |
| __Return__ | object |

Converts the `void*` buffer to string. In Py2 returns 'str' type, in Py3 returns 'bytes' type.

`origin` may be one of: "top-left", "bottom-left".

`mode` may be one of: "bgra", "rgba".
