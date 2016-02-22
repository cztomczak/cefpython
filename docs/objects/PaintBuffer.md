# PaintBuffer object #

This object is related to: [Browser](Browser).GetImage() and [RenderHandler](RenderHandler).OnPaint().

long **GetIntPointer**()

> Get int pointer to the `void*` buffer.

object **GetString**(string `mode`="bgra", string `origin`="top-left")

> Converts the `void*` buffer to string. In Py2 returns 'str' type, in Py3 returns 'bytes' type.

> `origin` may be one of: "top-left", "bottom-left".

> `mode` may be one of: "bgra", "rgba".