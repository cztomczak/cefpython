# RenderHandler callbacks #

Implement this interface to handle events when window rendering is disabled (off-screen rendering). The methods of this class will be called on the UI thread.

## CEF 3 ##

bool **GetRootScreenRect**([Browser](Browser) browser, list out `rect`)

> Called to retrieve the root window rectangle in screen coordinates. Return true if the rectangle was provided.

bool **GetViewRect**([Browser](Browser) `browser`, list out `rect`)

> Called to retrieve the view rectangle which is relative to screen coordinates. Return true if the rectangle was provided.

> The `rect` list should contain 4 elements: [x, y, width, height].

bool **GetScreenRect**([Browser](Browser) `browser`, list out `rect`)

> Called to retrieve the simulated screen rectangle. Return true if the rectangle was provided.

> The `rect` list should contain 4 elements: [x, y, width, height].

bool **GetScreenPoint**([Browser](Browser) `browser`, int `viewX`, int `viewY`, list out `screenCoordinates`)

> Called to retrieve the translation from view coordinates to actual screen coordinates. Return true if the screen coordinates were provided.

> The `screenCoordinates` list should contain 2 elements: [x, y].

bool **GetScreenInfo**([Browser](Browser) browser, `CefScreenInfo`& screen\_info)

> Not yet implemented.

> Called to allow the client to fill in the `CefScreenInfo` object with appropriate values. Return true if the |screen\_info| structure has been modified. If the screen info rectangle is left empty the rectangle from `GetViewRect` will be used. If the rectangle is still empty or invalid popups may not be drawn correctly.

> `CefScreenInfo` structure:

```
typedef struct _cef_screen_info_t {
  ///
  // Device scale factor. Specifies the ratio between physical and logical
  // pixels.
  ///
  float device_scale_factor;

  ///
  // The screen depth in bits per pixel.
  ///
  int depth;

  ///
  // The bits per color component. This assumes that the colors are balanced
  // equally.
  ///
  int depth_per_component;

  ///
  // This can be true for black and white printers.
  ///
  bool is_monochrome;

  ///
  // This is set from the rcMonitor member of MONITORINFOEX, to whit:
  //   "A RECT structure that specifies the display monitor rectangle,
  //   expressed in virtual-screen coordinates. Note that if the monitor
  //   is not the primary display monitor, some of the rectangle's
  //   coordinates may be negative values."
  //
  // The |rect| and |available_rect| properties are used to determine the
  // available surface for rendering popup views.
  ///
  cef_rect_t rect;

  ///
  // This is set from the rcWork member of MONITORINFOEX, to whit:
  //   "A RECT structure that specifies the work area rectangle of the
  //   display monitor that can be used by applications, expressed in
  //   virtual-screen coordinates. Windows uses this rectangle to
  //   maximize an application on the monitor. The rest of the area in
  //   rcMonitor contains system windows such as the task bar and side
  //   bars. Note that if the monitor is not the primary display monitor,
  //   some of the rectangle's coordinates may be negative values".
  //
  // The |rect| and |available_rect| properties are used to determine the
  // available surface for rendering popup views.
  ///
  cef_rect_t available_rect;
```

void **OnPopupShow**([Browser](Browser) `browser`, bool `show`)

> Called when the browser wants to show or hide the popup widget. The popup should be shown if |show| is true and hidden if |show| is false.

void **OnPopupSize**([Browser](Browser) `browser`, list `rect`)

> Called when the browser wants to move or resize the popup widget. |rect| contains the new location and size.

> The `rect` list should contain 4 elements: [x, y, width, height].

void **OnPaint**([Browser](Browser) `browser`, int `paintElementType`, list out  `dirtyRects`, [PaintBuffer](PaintBuffer) `buffer`, int width, int height)

> Called when an element should be painted. |paintElementType| indicates whether the element is the view or the popup widget. |buffer| contains the pixel data for the whole image. |dirtyRects| contains the set of rectangles that need to be repainted. On Windows |buffer| will be width\*height\*4 bytes in size and represents a BGRA image with an upper-left origin. The BrowserSettings.animation\_frame\_rate value controls the rate at which this method is called.

> `paintElementType` is one of:

> cefpython.`PET_VIEW`<br>
<blockquote>cefpython.<code>PET_POPUP</code><br></blockquote>

<blockquote><code>dirtyRects</code> is a list of rects: [[x, y, width, height], [..]]</blockquote>

void <b>OnCursorChange</b>(<a href='Browser'>Browser</a> <code>browser</code>, CursorHandle <code>cursor</code>)<br>
<br>
<blockquote>Called when the browser window's cursor has changed.</blockquote>

<blockquote><code>CursorHandle</code> is an int pointer.</blockquote>

void <b>OnScrollOffsetChanged</b>(<a href='Browser'>Browser</a> browser)<br>
<br>
<blockquote>Called when the scroll offset has changed.</blockquote>

<h2>CEF 1</h2>

In CEF 1 off-screen rendering is not supported on Linux.<br>
<br>
bool <b>GetViewRect</b>(<a href='Browser'>Browser</a> <code>browser</code>, list out <code>rect</code>)<br>
<br>
<blockquote>Called to retrieve the view rectangle which is relative to screen coordinates. Return true if the rectangle was provided.</blockquote>

<blockquote>The <code>rect</code> list should contain 4 elements: [x, y, width, height].</blockquote>

bool <b>GetScreenRect</b>(<a href='Browser'>Browser</a> <code>browser</code>, list out <code>rect</code>)<br>
<br>
<blockquote>Called to retrieve the simulated screen rectangle. Return true if the rectangle was provided.</blockquote>

<blockquote>The <code>rect</code> list should contain 4 elements: [x, y, width, height].</blockquote>

bool <b>GetScreenPoint</b>(<a href='Browser'>Browser</a> <code>browser</code>, int <code>viewX</code>, int <code>viewY</code>, list out <code>screenCoordinates</code>)<br>
<br>
<blockquote>Called to retrieve the translation from view coordinates to actual screen coordinates. Return true if the screen coordinates were provided.</blockquote>

<blockquote>The <code>screenCoordinates</code> list should contain 2 elements: [x, y].</blockquote>

void <b>OnPopupShow</b>(<a href='Browser'>Browser</a> <code>browser</code>, bool <code>show</code>)<br>
<br>
<blockquote>Called when the browser wants to show or hide the popup widget. The popup should be shown if |show| is true and hidden if |show| is false.</blockquote>

void <b>OnPopupSize</b>(<a href='Browser'>Browser</a> <code>browser</code>, list <code>rect</code>)<br>
<br>
<blockquote>Called when the browser wants to move or resize the popup widget. |rect| contains the new location and size.</blockquote>

<blockquote>The <code>rect</code> list should contain 4 elements: [x, y, width, height].</blockquote>

void <b>OnPaint</b>(<a href='Browser'>Browser</a> <code>browser</code>, int <code>paintElementType</code>, list out  <code>dirtyRects</code>, <a href='PaintBuffer'>PaintBuffer</a> <code>buffer</code>)<br>
<br>
<blockquote>Called when an element should be painted. |paintElementType| indicates whether the element is the view or the popup widget. |buffer| contains the pixel data for the whole image. |dirtyRects| contains the set of rectangles that need to be repainted. On Windows |buffer| will be width*height*4 bytes in size and represents a BGRA image with an upper-left origin. The BrowserSettings.animation_frame_rate value controls the rate at which this method is called.</blockquote>

<blockquote><code>paintElementType</code> is one of:</blockquote>

<blockquote>cefpython.<code>PET_VIEW</code><br>
cefpython.<code>PET_POPUP</code><br></blockquote>

<blockquote><code>dirtyRects</code> is a list of rects: [[x, y, width, height], [..]]</blockquote>

void <b>OnCursorChange</b>(<a href='Browser'>Browser</a> <code>browser</code>, CursorHandle <code>cursor</code>)<br>
<br>
<blockquote>Called when the browser window's cursor has changed.</blockquote>

<blockquote>On Windows CursorHandle is an int pointer of a HANDLE.