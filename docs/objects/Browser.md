# `Browser` object #

## Notes ##

**Closing browser cleanly**

Remember to delete all browser references for the browser to shut down cleanly. For an example see [wxpython.py > MainFrame.OnClose()](../blob/master/cefpython/cef3/windows/binaries_32bit/wxpython.py#L209).

## Methods ##

### CanGoBack() (bool) ###

> Returns true if the browser can navigate backwards.

### CanGoForward() (bool) ###

> Returns true if the browser can navigate forwards.

### ClearHistory() (void) ###

> Available only in CEF 1.

> Clear the back/forward browsing history.

### CloseBrowser(bool `forceClose`) (void) ###

> Closes the browser. If the window was created explicitily by you (not a popup) you still need to post WM\_DESTROY message to the window.

> Request that the browser close. The Javascript 'onbeforeunload' event will
> be fired. If |force\_close| is false the event handler, if any, will be
> allowed to prompt the user and the user can optionally cancel the close.
> If |force\_close| is true the prompt will not be displayed and the close
> will proceed. Results in a call to LifespanHandler::`DoClose()` if the
> event handler allows the close or if |force\_close| is true. See
> LifespanHandler::`DoClose()` documentation for additional usage
> information.

### CloseDevTools() (void) ###

> Available only in cefpython 1. Not yet implemented in cefpython 3.

> Explicitly close the developer tools window if one exists for this browser instance.

### ExecuteFunction(string `funcName`, `[`mixed param `[`, mixed `param` `[, ..]]]`) (void) ###

> Call javascript function asynchronously. This can also call object's methods, just pass "object.method" as `funcName`. Any valid javascript syntax is allowed as `funcName`, you could even pass an anonymous function here.

> For a list of allowed types for `mixed` see [JavascriptBindings](JavascriptBindings).IsValueAllowed() (except function, method and instance).

> Passing a python function here is not allowed, it is only possible through JavascriptCallback object.

### ExecuteJavascript(string `jsCode`, string `scriptURL`=None, int `startLine`=None) (void) ###

> Execute a string of JavaScript code in this frame. The `sciptURL` parameter is the URL where the script in question can be found, if any. The renderer may request this URL to show the developer the source of the error.  The `startLine` parameter is the base line number to use for error reporting.

> This function executes asynchronously so there is no way to get the returned value.

> Calling javascript from native code synchronously is not possible in CEF 3. It is also not possible doing it synchronously the other way around ie. js->native.

### Find(int `searchID`, string `searchText`, bool `forward`, bool `matchCase`, bool `findNext`) (void) ###

> Search for |searchText|. |searchID| can be custom, it is so that you can  have multiple searches running simultaneously. |forward| indicates whether to search forward or backward within the page. |matchCase| indicates whether the search should be case-sensitive. |findNext| indicates whether this is the first request or a follow-up.

### GetClientCallback(string `name`) (func) ###

> Get client callback by name.

### GetClientCallbacksDict() (dict) ###

> Get client callbacks as a dictionary.

### GetFocusedFrame() (Frame) ###

> Returns the focused [frame](Frame) for the browser window. In CEF 1 this method should only be called on the UI thread.

### GetFrame(string `name`) (Frame) ###

> Returns the [frame](Frame) with the specified name, or NULL if not found. In CEF 1 this method should only be called on the UI thread.

### GetFrameByIdentifier(long identifier) (Frame) ###

> Available only in CEF 3. Returns the [frame](Frame) with the specified identifier, or None if not found.

### GetFrames() (list) ###

> Get all frames. This is an internal CEF Python implementation that uses `GetFrameNames()` and `GetFrame()` methods to list through all frames. The main frame is not included in that list.

### GetFrameCount() (int) ###

> Available only in CEF 3. Not yet implemented.

> Returns the number of frames that currently exist.

### GetFrameIdentifiers() (void) ###

> Available only in CEF 3. Not yet implemented.

> Returns the identifiers of all existing frames.

### GetFrameNames() (string`[]`) ###

> Returns the names of all existing frames. This list does not include the main frame. In CEF 1 this method should only be called on the UI thread.

### GetImage(`PaintElementType` `type`, int `width`, int `height`) (`PaintBuffer`) ###

> Available only in cefpython 1. Not yet implemented in CEF 3. Not supported on Linux.

> Get the raw image data contained in the specified element without performing validation. The specified |width| and |height| dimensions must match the current element size. On Windows |buffer| must be width\*height\*4 bytes in size and represents a BGRA image with an upper-left origin. This method should only be called on the UI thread.

> Returns [PaintBuffer](PaintBuffer) object.

### GetJavascriptBindings() (`JavascriptBindings`) ###

> Returns the [JavascriptBindings](JavascriptBindings) object that was passed to [cefpython](cefpython).`CreateBrowserSync()`.

### GetMainFrame() (Frame) ###

> Returns the main (top-level) [frame](Frame) for the browser window.

### GetNSTextInputContext() (`TextInputContext`) ###

> Not yet ported. Available only in CEF 3.

> Get the NSTextInputContext implementation for enabling IME on Mac when
> window rendering is disabled.

### GetOpenerWindowHandle() (windowHandle) ###

> Retrieve the CEF-internal (inner or outer) window handle of the browser that opened this browser. Will return None for non-popup windows. See `GetWindowHandle()` for an explanation of inner/outer window handles.

### GetOuterWindowHandle() (windowHandle) ###

> Get the most outer window handle.

### GetSize(int `paintElementType`) (tuple) ###

> Available only in CEF 1. This method is not available in CEF 3.

> Get the size of the specified element. This method should only be called on the UI thread.

> `paintElementType` is one of:

> cefpython.`PET_VIEW`<br>
<blockquote>cefpython.<code>PET_POPUP</code><br></blockquote>

<blockquote>Returns tuple(width, height) or tuple(0, 0) if failed.</blockquote>

<h3>GetUrl() (string)</h3>

<blockquote>Get url of the main frame.</blockquote>

<h3>GetUserData(mixed <code>key</code>) (mixed)</h3>

<blockquote>Get user data. See also <code>SetUserData()</code>.</blockquote>

<h3>GetWindowHandle() (windowHandle)</h3>

<blockquote>Returns an inner or outer window handle for the browser. If the browser was created using <code>CreateBrowserSync()</code> then this will return an inner CEF-internal window handle. If this is a popup browser created from javascript using <code>window.open()</code> and its WindowInfo has not been set in LifespanHandler.<code>OnAfterCreated()</code>, then it returns CEF-internal window handle which is the most outer window handle in this case.</blockquote>

<h3>GetIdentifier() (int)</h3>

<blockquote>Returns the globally unique identifier for this browser.</blockquote>

<h3>GetZoomLevel() (float)</h3>

<blockquote>Get the current zoom level. The default zoom level is 0.0. In CEF 1 this method may only be called on the UI thread.</blockquote>

<h3>GoBack() (void)</h3>

<blockquote>Navigate backwards.</blockquote>

<h3>GoForward() (void)</h3>

<blockquote>Navigate forwards.</blockquote>

<h3>HandleKeyEventAfterTextInputClient(eventHandle <code>keyEvent</code>) (void)</h3>

<blockquote>Available only in CEF 3. Not yet implemented.</blockquote>

<blockquote>Performs any additional actions after NSTextInputClient handles the event.</blockquote>

<h3>HandleKeyEventBeforeTextInputClient() (void)</h3>

<blockquote>Available only in CEF 3. Not yet implemented.</blockquote>

<blockquote>Handles a keyDown event prior to passing it through the NSTextInputClient<br>
machinery.</blockquote>

<h3>HasDocument() (bool)</h3>

<blockquote>Returns true if a document has been loaded in the browser.</blockquote>

<h3>HidePopup() (void)</h3>

<blockquote>Available only in CEF 1.</blockquote>

<blockquote>Hide the currently visible popup, if any.</blockquote>

<h3>Invalidate(list <code>dirtyRect</code>) (void)</h3>

<blockquote>Available only in cefpython 1. Not yet implemented in cefpython 3.</blockquote>

<blockquote>Invalidate the |dirtyRect| region of the view. This method is only used when window rendering is disabled and will result in a call to <code>HandlePaint()</code>.</blockquote>

<blockquote><code>dirtyRect</code> is a list: [x, y, width, height].</blockquote>

<h3>IsFullscreen() (void)</h3>

<blockquote>Whether in fullscreen mode, see <code>ToggleFullscreen()</code>.</blockquote>

<blockquote>This function is Windows-only.</blockquote>

<h3>IsLoading() (bool)</h3>

<blockquote>Available only in CEF 3. Not yet implemented.</blockquote>

<blockquote>Returns true if the browser is currently loading.</blockquote>

<h3>IsMouseCursorChangeDisabled() (bool)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Returns true if mouse cursor change is disabled.</blockquote>

<h3>IsPopup() (bool)</h3>

<blockquote>Returns true if the window is a popup window.</blockquote>

<h3>IsPopupVisible() (bool)</h3>

<blockquote>Available only in CEF 1.</blockquote>

<blockquote>Returns true if a popup is currently visible. In CEF 1 this method should only be called on the UI thread.</blockquote>

<h3>IsWindowRenderingDisabled() (bool)</h3>

<blockquote>Returns true if window rendering is disabled.</blockquote>

<h3>LoadUrl(string <code>url</code>) (void)</h3>

<blockquote>Load url in the main frame.</blockquote>

<h3>Navigate(string <code>url</code>) (void)</h3>

<blockquote>This is an alias for the <code>LoadUrl</code> method.</blockquote>

<h3>NotifyScreenInfoChanged() (void)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Send a notification to the browser that the screen info has changed. The<br>
browser will then call <a href='RenderHandler'>RenderHandler</a>.<code>GetScreenInfo()</code> to update the<br>
screen information with the new values. This simulates moving the webview<br>
window from one display to another, or changing the properties of the<br>
current display. This method is only used when window rendering is<br>
disabled.</blockquote>

<h3>ParentWindowWillClose() (void)</h3>

<blockquote>Call this method before destroying a contained browser window. This method<br>
performs any internal cleanup that may be needed before the browser window<br>
is destroyed. See <a href='LifespanHandler'>LifespanHandler</a>::<code>DoClose()</code> documentation for<br>
additional usage information.</blockquote>

<h3>Reload() (void)</h3>

<blockquote>Reload the current page.</blockquote>

<h3>ReloadIgnoreCache() (void)</h3>

<blockquote>Reload the current page ignoring any cached data.</blockquote>

<h3>SendKeyEvent(int <code>keyType</code>, tuple <code>keyInfo</code>, int <code>modifiers</code>) (void)</h3>

<blockquote>These arguments and description apply for CEF 1 only. In CEF 3 this<br>
function has a different number of arguments, see the next function<br>
listed on this wiki page.</blockquote>

<blockquote>Sending keyboard input using this function is not trivial, it is<br>
recommended to use one of <code>SendKeys</code> libraries available on Windows:</blockquote>

<ul><li><a href='http://code.google.com/p/pywinauto/source/browse/pywinauto/SendKeysCtypes.py'>http://code.google.com/p/pywinauto/source/browse/pywinauto/SendKeysCtypes.py</a>
</li><li><a href='http://code.google.com/p/sendkeys-ctypes/'>http://code.google.com/p/sendkeys-ctypes/</a>
</li><li><a href='https://github.com/zvodd/sendkeys-py-si'>https://github.com/zvodd/sendkeys-py-si</a>
</li><li><a href='https://bitbucket.org/orutherfurd/sendkeys/overview'>https://bitbucket.org/orutherfurd/sendkeys/overview</a></li></ul>

<blockquote>Send a key event to the browser.</blockquote>

<blockquote><code>keyType</code> may be one of:</blockquote>

<blockquote>cefpython.<code>KEYTYPE_KEYUP</code><br>
cefpython.<code>KEYTYPE_KEYDOWN</code><br>
cefpython.<code>KEYTYPE_CHAR</code><br></blockquote>

<blockquote><code>keyInfo</code> on Windows is a tuple(int key, BOOL sysChar, BOOL imeChar).</blockquote>

<blockquote><code>keyInfo</code> on Mac is a tuple(int keyCode, int character, int characterNoModifiers).</blockquote>

<blockquote><code>keyInfo</code> on Linux is a tuple(int key).</blockquote>

<blockquote><code>key</code> in <code>keyInfo</code> is a <a href='VirtualKey'>VirtualKey</a>.</blockquote>

<blockquote><code>modifiers</code> parameter is a <a href='VirtualKey'>VirtualKey</a>.</blockquote>

<h3>SendKeyEvent(<code>KeyEvent</code> event) (void)</h3>

<blockquote>These arguments and description apply for CEF 3 only. In CEF 1 this<br>
function has a different number of arguments, see the previous<br>
function listed on this wiki page.</blockquote>

<blockquote><code>KeyEvent</code> is a dictionary, see <a href='KeyboardHandler'>KeyboardHandler</a>.<code>OnPreKeyEvent()</code>
for a description of the available keys.</blockquote>

<h3>SendMouseClickEvent(int <code>x</code>, int <code>y</code>, int <code>mouseButtonType</code>, bool <code>mouseUp</code>, int <code>clickCount</code>) (void)</h3>

<blockquote>Send a mouse click event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view.</blockquote>

<blockquote><code>mouseButtonType</code> may be one of:</blockquote>

<blockquote>cefpython.<code>MOUSEBUTTON_LEFT</code><br>
cefpython.<code>MOUSEBUTTON_MIDDLE</code><br>
cefpython.<code>MOUSEBUTTON_RIGHT</code><br></blockquote>

<blockquote>TODO: allow to pass modifiers which represents bit flags<br>
describing any pressed modifier keys. Modifiers can also<br>
be passed to <code>SendMouseMoveEvent()</code>, <code>SendMouseWheelEvent()</code>.<br>
See cef_event_flags_t enum for modifiers values:</blockquote>

<pre><code>    enum cef_event_flags_t {<br>
        EVENTFLAG_NONE                = 0,<br>
        EVENTFLAG_CAPS_LOCK_ON        = 1 &lt;&lt; 0,<br>
        EVENTFLAG_SHIFT_DOWN          = 1 &lt;&lt; 1,<br>
        EVENTFLAG_CONTROL_DOWN        = 1 &lt;&lt; 2,<br>
        EVENTFLAG_ALT_DOWN            = 1 &lt;&lt; 3,<br>
        EVENTFLAG_LEFT_MOUSE_BUTTON   = 1 &lt;&lt; 4,<br>
        EVENTFLAG_MIDDLE_MOUSE_BUTTON = 1 &lt;&lt; 5,<br>
        EVENTFLAG_RIGHT_MOUSE_BUTTON  = 1 &lt;&lt; 6,<br>
        // Mac OS-X command key.<br>
        EVENTFLAG_COMMAND_DOWN        = 1 &lt;&lt; 7,<br>
        EVENTFLAG_NUM_LOCK_ON         = 1 &lt;&lt; 8,<br>
        EVENTFLAG_IS_KEY_PAD          = 1 &lt;&lt; 9,<br>
        EVENTFLAG_IS_LEFT             = 1 &lt;&lt; 10,<br>
        EVENTFLAG_IS_RIGHT            = 1 &lt;&lt; 11,<br>
</code></pre>

<h3>SendMouseMoveEvent(int x, int y, bool mouseLeave) (void)</h3>

<blockquote>Send a mouse move event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view.</blockquote>

<h3>SendMouseWheelEvent(int x, int y, int deltaX, int deltaY) (void)</h3>

<blockquote>Send a mouse wheel event to the browser. The |x| and |y| coordinates are relative to the upper-left corner of the view. The |deltaX| and |deltaY| values represent the movement delta in the X and Y directions respectively. In order to scroll inside select popups with window rendering disabled <a href='RenderHandler'>RenderHandler</a>.<code>GetScreenPoint()</code> should be implemented properly.</blockquote>

<h3>SendFocusEvent(bool setFocus) (void)</h3>

<blockquote>Send a focus event to the browser.</blockquote>

<h3>SendCaptureLostEvent() (void)</h3>

<blockquote>Send a capture lost event to the browser.</blockquote>

<h3>SetClientCallback(string <code>name</code>, function <code>callback</code>) (void)</h3>

<blockquote>Set client callback.</blockquote>

<h3>SetClientHandler(object <code>clientHandler</code>) (void)</h3>

<blockquote>Set client handler object (class instance), its members will be inspected. Private methods that are not meant to be callbacks should have their names prepended with an underscore.</blockquote>

<h3>SetFocus(bool <code>enable</code>) (void)</h3>

<blockquote>Set focus for the browser window. If |enable| is true focus will be set to the window. Otherwise, focus will be removed.</blockquote>

<h3>SetMouseCursorChangeDisabled(bool <code>disabled</code>) (void)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Set whether mouse cursor change is disabled.</blockquote>

<h3>SetSize(int <code>paintElementType</code>, int <code>width</code>, int <code>height</code>) (void)</h3>

<blockquote>Available only in cefpython 1. Not yet implemented in cefpython 3.</blockquote>

<blockquote>Set the size of the specified element. This method is only used when window rendering is disabled (off-screen browser). This function is asynchronous, after a call to <code>SetSize()</code> the <a href='RenderHandler'>RenderHandler</a>.<code>OnPaint()</code> event might still have the old size, you would have to ignore it and wait for the next one <a href='RenderHandler'>RenderHandler</a>.<code>OnPaint()</code> event.</blockquote>

<blockquote>See <code>GetSize()</code> for possible values of <code>paintElementType</code>.</blockquote>

<h3>SetUserData(mixed<code>key</code>, mixed <code>value</code>) (void)</h3>

<blockquote>Set user data. Use this function to keep data associated with this browser. See also <code>GetUserData()</code>.</blockquote>

<h3>SetZoomLevel(float <code>zoomLevel</code>) (void)</h3>

<blockquote>Change the zoom level to the specified value. Specify 0.0 to reset the zoom level. If called on the UI thread the change will be applied immediately. Otherwise, the change will be applied asynchronously on the UI thread.</blockquote>

<h3>ShowDevTools() (void)</h3>

<blockquote>Open developer tools in a popup window.</blockquote>

<h3>StartDownload(string url) (void)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Download the file at |url| using <a href='DownloadHandler'>DownloadHandler</a>.</blockquote>

<h3>StopLoad() (void)</h3>

<blockquote>Stop loading the page.</blockquote>

<h3>StopFinding(bool clearSelection) (void)</h3>

<blockquote>Cancel all searches that are currently going on.</blockquote>

<h3>ToggleFullscreen() (bool)</h3>

<blockquote>Switch between fullscreen mode / windowed mode. To check whether in fullscreen mode call <code>IsFullscreen()</code>.</blockquote>

<blockquote>This function is Windows-only.</blockquote>

<h3>WasResized() (void)</h3>

<blockquote>Notify the browser that the widget has been resized. The browser will<br>
first call <a href='RenderHandler'>RenderHandler</a>::<code>GetViewRect</code> to get the new size and then<br>
call <a href='RenderHandler'>RenderHandler</a>::<code>OnPaint</code> asynchronously with the updated regions.<br>
This method is only used when window rendering is disabled.</blockquote>

<h3>WasHidden(bool <code>hidden</code>) (void)</h3>

<blockquote>Available only in CEF 3.</blockquote>

<blockquote>Notify the browser that it has been hidden or shown. Layouting and<br>
<a href='RenderHandler'>RenderHandler</a>::<code>OnPaint</code> notification will stop when the browser is<br>
hidden. This method is only used when window rendering is disabled.