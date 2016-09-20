[API categories](API-categories.md) | [API index](API-index.md)


# Image (object)


Table of contents:
* [Methods](#methods)
  * [GetAsBitmap](#getasbitmap)
  * [GetAsPng](#getaspng)
  * [GetHeight](#getheight)
  * [GetWidth](#getwidth)


## Methods


### GetAsBitmap

| Parameter | Type |
| --- | --- |
| scale_factor | float |
| color_type | cef_color_type_t |
| alpha_type | cef_alpha_type_t |
| __Return__ | bytes |

`cef_color_type_t` constants in the cefpython module:
* CEF_COLOR_TYPE_RGBA_8888,
* CEF_COLOR_TYPE_BGRA_8888,

`enum cef_alpha_type_t` constants in the cefpython module:
* CEF_ALPHA_TYPE_OPAQUE,
* CEF_ALPHA_TYPE_PREMULTIPLIED,
* CEF_ALPHA_TYPE_POSTMULTIPLIED,


### GetAsPng

| Parameter | Type |
| --- | --- |
| scale_factor | float |
| with_transparency | bool |
| __Return__ | bytes |

Returns image data as bytes.

Description from upstream CEF:
> Returns the PNG representation that most closely matches |scale_factor|. If
> |with_transparency| is true any alpha transparency in the image will be
> represented in the resulting PNG data. |pixel_width| and |pixel_height| are
> the output representation size in pixel coordinates. Returns a
> CefBinaryValue containing the PNG image data on success or NULL on failure.


### GetHeight

| | |
| --- | --- |
| __Return__ | int |

Returns the image heifght in density independent pixel (DIP) units.


### GetWidth

| | |
| --- | --- |
| __Return__ | int |

Returns the image width in density independent pixel (DIP) units.

