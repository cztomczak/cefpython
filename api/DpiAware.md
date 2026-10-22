[API categories](API-categories.md) | [API index](API-index.md)


# DpiAware (class)

Available only on Windows. All methods of this class are static, access them
through [cefpython](cefpython.md).`DpiAware`.

Example usage of High DPI support is in the wxpython.py example.


Table of contents:
* [Introduction](#introduction)
* [Static methods](#static-methods)
  * [CalculateWindowSize](#calculatewindowsize)
  * [GetSystemDpi](#getsystemdpi)
  * [IsProcessDpiAware](#isprocessdpiaware)
  * [SetProcessDpiAware](#setprocessdpiaware)
  * [Scale](#scale)



## Introduction

By default, if DPI awareness is not enabled in an application, Windows
performs display scaling and text may look blurry. Enable DPI awareness by
embedding a DPI awareness XML manifest in both the main executable and the
subprocess executable. See [Issue #112](../../../issues/112), comment 2.

## Static methods


### CalculateWindowSize

| Parameter | Type |
| --- | --- |
| width | int |
| height | int |
| __Return__ | tuple |

Deprecated. Use `Scale()` method instead which can handle
non standard DPI settings such as '132%' on Windows 10.

This utility function will adjust width/height using
OS DPI settings. For 800/600 with Win7 DPI settings
being set to "Larger 150%" will return 1200/900.


### GetSystemDpi

| | |
| --- | --- |
| __Return__ | tuple |:

Returns tuple(int dpix, int dpiy).

Returns Windows DPI settings ("Custom scaling" on Win10).

Win7 DPI (Control Panel > Appearance and Personalization > Display):

  * text size Larger 150% => dpix/dpiy 144
  * text size Medium 125% => dpix/dpiy 120
  * text size Smaller 100% => dpix/dpiy 96

Example zoom levels based on DPI. For use with the
ApplicationSettings.`auto_zooming` option.

  * dpix=96 zoomlevel=0.0
  * dpix=120 zoomlevel=1.0
  * dpix=144 zoomlevel=2.0
  * dpix=72 zoomlevel=-1.0

If DPI awareness wasn't yet enabled, then `GetSystemDpi` will always
return a default 96 DPI.

DPI settings should not be cached. Before DPI awareness is enabled, Windows
returns 96 DPI even when another value is configured. After DPI awareness is
enabled, it returns the configured value.


### IsProcessDpiAware

| | |
| --- | --- |
| __Return__ | bool |

Checks whether OS display scaling on high-DPI settings is disabled. DPI
awareness may be enabled with an executable manifest or manually in the
executable properties under Compatibility.

On Win8 this will return True if DPI awareness is set to either "System DPI aware" or "Per monitor DPI aware".


### SetProcessDpiAware

| | |
| --- | --- |
| __Return__ | void |

Deprecated; do not use this method. Embed a DPI awareness manifest in both
the main executable and the subprocess executable instead. See
[Issue #358](../../../issues/358) for background.


### Scale

| Parameter | Type |
| --- | --- |
| size | int/tuple/list |
| __Return__ | tuple |

Scale units for high DPI devices.
