[API categories](API-categories.md) | [API index](API-index.md)


# WindowInfo (class)

This class is passed to functions: [cefpython](cefpython.md).CreateBrowserSync(), LifespanHandler.OnBeforePopup().

To instantiate this class call: [cefpython](cefpython.md).WindowInfo().


Table of contents:
* [Methods](#methods)
  * [SetAsChild](#setaschild)
  * [SetAsPopup](#setaspopup)
  * [SetAsOffscreen](#setasoffscreen)
  * [SetTransparentPainting](#settransparentpainting)

## Methods


### SetAsChild

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| windowRect=None | list |
| __Return__ | void |

 `windowRect` param is optional on Windows. On Linux & Mac it is required. Example value: [left, top, right, bottom].

 This is the method you want to call in most cases.


### SetAsPopup

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| windowName | string |
| __Return__ | void |

 Available only on Windows.


### SetAsOffscreen

| Parameter | Type |
| --- | --- |
| parentWindowHandle | int |
| __Return__ | void |

 Call this method to disable window rendering and to use RenderHandler. See the Panda3D and Kivy examples.

 You can pass 0 to `parentWindowHandle`, but then some things like context menus and plugins may not display correctly.


### SetTransparentPainting

| Parameter | Type |
| --- | --- |
| transparentPainting | bool |
| __Return__ | void |

 This method is intended for use with off-screen rendering. (not sure if it works with windowed rendering)
