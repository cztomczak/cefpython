# DisplayHandler callbacks #

Implement this interface to handle events related to browser display state. The methods of this class will be called on the UI thread.

For an example of how to implement handler see [cefpython](cefpython).CreateBrowser(). For a list of all handler interfaces see [API > Client handlers](API#Client_handlers).

## CEF 3 ##

void **OnAddressChange**([Browser](Browser) browser, [Frame](Frame) frame, string url)

> Called when a frame's address has changed.

void **OnTitleChange**([Browser](Browser) browser, string title)

> Called when the page title changes.

bool **OnTooltip**([Browser](Browser) browser, `list& textOut`)

> Called when the browser is about to display a tooltip. `textOut[0]` contains the
> text that will be displayed in the tooltip. To handle the display of the
> tooltip yourself return true. Otherwise, you can optionally modify `textOut[0]`
> and then return false to allow the browser to display the tooltip.
> When window rendering is disabled the application is responsible for
> drawing tooltips and the return value is ignored.

void **OnStatusMessage**([Browser](Browser) browser, string value)

> Called when the browser receives a status message.

bool **OnConsoleMessage**([Browser](Browser) browser, string message, string source, int line)

> Called to display a console message. Return true to stop the message from
> being output to the console.

## CEF 1 ##

void **OnAddressChange**([Browser](Browser) `browser`, [Frame](Frame) `frame`, string `url`)

> Called when a frame's address has changed.

bool **OnConsoleMessage**([Browser](Browser) `browser`, string `message`, string `source`, int `line`)

> Called to display a console message. Return true to stop the message from being output to the console.

> From testing it seems that this function gets called only for console.log(), console.warn(), console.error() and console.info(). You will not get all the messages that appear in developer tools console, see this thread: http://magpcss.org/ceforum/viewtopic.php?f=6&t=3347

void **OnContentsSizeChange**([Browser](Browser) `browser`, [Frame](Frame) `frame`, int `width`, int `height`)

> Called when the size of the content area has changed.

void **OnFaviconUrlChange**([Browser](Browser) `browser`, string`[]`& `icon_urls`)

> Not yet implemented in CEF Python.

void **OnNavStateChange**([Browser](Browser) `browser`, bool `canGoBack`, bool `canGoForward`)

> Called when the navigation state has changed.

void **OnStatusMessage**([Browser](Browser) `browser`, string `text`, int `statusType`)

> Called when the browser receives a status message. |text| contains the text that will be displayed in the status message and |statusType| indicates the status message type.

> `statusType` can be one of:

> cefpython.`STATUSTYPE_TEXT`<br>
<blockquote>cefpython.<code>STATUSTYPE_MOUSEOVER_URL</code><br>
cefpython.<code>STATUSTYPE_KEYBOARD_FOCUS_URL</code></blockquote>

bool <b>OnTitleChange</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>title</code>)<br>
<br>
<blockquote>Called when the page title changes. Implement this function to handle window titles for popup windows.</blockquote>

<blockquote>There is a default implementation  of this function that sets titles for popup windows, otherwise they appeared on the taskbar with no title:<br>
<pre><code>	cefpython.WindowUtils.SetTitle(browser, title)<br>
	cefpython.WindowUtils.SetIcon(browser, "inherit")<br>
</code></pre></blockquote>

<blockquote>Return True to call these two functions automatically, otherwise return False.</blockquote>

<blockquote>If you would like to implement it differently, have a look at the default implementation of SetTitle() & SetIcon() in WindowUtils:<br>
<a href='../blob/master/cefpython/window_utils_win.pyx'>../blob/master/cefpython/window_utils_win.pyx</a></blockquote>

bool <b>OnTooltip</b>(<a href='Browser'>Browser</a> <code>browser</code>, string <code>&amp;text[0]</code>)<br>
<br>
<blockquote>Called when the browser is about to display a tooltip. |text| contains the text that will be displayed in the tooltip. To handle the display of the tooltip yourself return true. Otherwise, you can optionally modify |text| and then return false to allow the browser to display the tooltip.