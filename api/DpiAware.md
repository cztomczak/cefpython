[API categories](API-categories.md) | [API index](API-index.md)


# DpiAware (class)

Available only on Windows. All methods of this class are static, access them through [cefpython](cefpython.md).`WindowUtils`.

Usage of this class is not encouraged, as upstream chromium is already support high-dpi by default

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

Enabling High DPI support in app can be done by embedding a DPI awareness xml manifest in both main executable and subprocess executable (see [Issue #112](../issues/112) comment #2), or by calling the `cef.DpiAware.EnableHighDpiSupport` method.

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

DPI settings should not be cached. When `SetProcessDpiAware`
is not yet called, then OS returns 96 DPI, even though it
is set to 144 DPI. After DPI Awareness is enabled for the
running process it will return the correct 144 DPI.


### IsProcessDpiAware

| | |
| --- | --- |
| __Return__ | bool |

To check whether OS display scaling on high DPI settings was disabled. DPI awareness may be enabled by calling `SetProcessDpiAware`. It may also be enabled manually by user by changing options in .exe properties > Compatibility tab.

On Win8 this will return True if DPI awareness is set to either "System DPI aware" or "Per monitor DPI aware".


### SetProcessDpiAware

| | |
| --- | --- |
| __Return__ | void |

Calling this method is deprecated, it is a dummy function now.


### Scale

| Parameter | Type |
| --- | --- |
| size | int/tuple/list |
| __Return__ | tuple |

Scale units for high DPI devices.
