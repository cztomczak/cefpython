# Tutorial

With CEF Python you can embed a web browser control based
on Chromium in a Python application. You can also use it to
create a HTML 5 based GUI in an application that can act as
a replacement for standard GUI toolkits such as wxWidgets,
Qt or GTK. With this tutorial you will learn CEF Python
basics. This tutorial will discuss the three featured examples:
[hello_world.py](../examples/hello_world.py),
[tutorial.py](../examples/tutorial.py)
and [screenshot.py](../examples/screenshot.py). There are many
more examples that you can find in the
[README-examples.md](../examples/README-examples.md)
file, but these examples are out of scope for this tutorial.


Table of contents:
* [Install and run example](#install-and-run-example)
* [Hello world](#hello-world)
* [Architecture](#architecture)
* [Handling Python exceptions](#handling-python-exceptions)
* [Settings](#settings)
* [Change user agent string](#change-user-agent-string)
* [Client handlers](#client-handlers)
* [Javascript integration](#javascript-integration)
* [Javascript exceptions and Python exceptions](#javascript-exceptions-and-python-exceptions)
* [Plugins and Flash support](#plugins-and-flash-support)
* [Message loop](#message-loop)
* [Off-screen rendering](#off-screen-rendering)
* [Build executable](#build-executable)
* [Support and documentation](#support-and-documentation)


## Install and run example

You can install with pip. On Linux pip 8.1+ is required. Alternatively
you can download packages for offline installation from [GitHub Releases](../../../releases).

Run the commands below to install the cefpython3 package, clone
the repository and run the Hello World example:

```commandline
pip install cefpython3==66.0
git clone https://github.com/cztomczak/cefpython.git
cd cefpython/examples/
python hello_world.py
```

The hello_world.py example's source code will be analyzed line
by line in the next section of this Tutorial.

This tutorial in its further sections will also reference the
tutorial.py and screenshot.py examples which will show how to
use more advanced CEF Python features. All these examples are
available in the examples/ root directory.


## Hello world

The [hello_world.py](../examples/hello_world.py) example is the
most basic example. It doesn't depend on any third party GUI framework.
It creates a browser widget without providing any window information
(parent window is not specified), thus CEF automatically takes care of
creating a top-level window, and in that window a Chromium widget
is being embedded. When creating the browser, the "url" parameter is
specified, which causes the browser to initially navigate to
Google website. Let's analyze the code from that example:

1. `from cefpython3 import cefpython as cef` - Import the cefpython
   module and make a short "cef" alias
2. `sys.excepthook = cef.ExceptHook` - Overwrite Python's default
   exception handler so that all CEF sub-processes are reliably
   terminated when Python exception occurs. To understand this
   better read the "Architecture" and "Handling Python exceptions"
   sections further down in this Tutorial.
3. `cef.Initialize()` - Initialize CEF. This function must be called
   somewhere in the beginning of your code. It must be called before
   any application window is created. It must be called only once
   during app's lifetime and must have a corresponding Shutdown()
   call.
4. `cef.CreateBrowserSync(url="https://www.google.com/", ...)` - Create
   a browser synchronously, this function returns a Browser object.
5. `cef.MessageLoop()` - Run CEF message loop. All desktop GUI programs
   run some message loop that waits and dispatches events or messages.
   Read more on message loop in the "Message loop" section further
   down in this tutorial.
6. `cef.Shutdown()` - Shut down CEF. This function must be called for
   CEF to shut down cleanly. It will free system resources acquired
   by CEF and terminate all sub-processes, and it will flush to disk any
   yet unsaved data like for example cookies and/or local storage. Call
   this function at the very end of your program execution. When using
   third party GUI frameworks such as Qt/wxWidgets, CEF should be shut down
   after these frameworks' shutdown procedures were called. For example
   in Qt, shut down CEF only after QApplication object was destroyed.

Documentation for the functions referenced in this example can
be found in API reference - the [api/](../api) root directory in GitHub's
repository:

* [ExceptHook](../api/cefpython.md#excepthook)
* [Initialize](../api/cefpython.md#initialize)
* [CreateBrowserSync](../api/cefpython.md#createbrowsersync)
* [Browser](../api/Browser.md) object
* [MessageLoop](../api/cefpython.md#messageloop)
* [Shutdown](../api/cefpython.md#shutdown)


## Architecture

- CEF uses multi-process architecture
  - The main application process is called the “Browser”
    process. In CEF Python this is the same process in
    which Python is running.
  - CEF Python uses a separate executable called "subprocess"
    for running sub-processes. Sub-processes will be created
    for renderers, plugins, GPU, etc.
  - In future CEF Python might allow to run Python also in
    sub-processes, for example in the Renderer process which
    would allow to access more CEF API ([Issue #320](../../../issues/320))
- Most processes in CEF have multiple threads
  - Handlers' callbacks and other interfaces callbacks may
    be called on various threads, this is stated in API reference
  - Some functions may only be used on particular threads,
    this is stated in API reference
  - CEF Python provides cef.[PostTask](../api/cefpython.md#posttask)
    function for posting tasks between these various threads
  - The "UI" thread is application main thread unless you
    use ApplicationSettings.[multi_threaded_message_loop](../api/ApplicationSettings.md#multi_threaded_messge_loop)
    option on Windows in which case the UI thread will no more
    be application main thread
  - Do not perform blocking operations on any CEF thread other
    than the Browser process FILE thread. Otherwise this can
    lead to serious performance issues.


## Handling Python exceptions

Due to CEF multi-process architecture Python exceptions need
special handling. When Python exception occurs then main process
is terminated. For CEF this means that the Browser process is
terminated, however there may still be running CEF sub-processes
like Renderer process, GPU process, etc. To terminate these
sub-processes cleanly cef.[Shutdown](../api/cefpython.md#shutdown)
must be called and if running CEF message loop then it must be
stopped first. In most of CEF Python examples you can find such
a line that overwrites the default exception handler in Python:

```python
sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
```

See Python docs for [sys.excepthook](https://docs.python.org/2/library/sys.html#sys.excepthook).

The cef.ExceptHook helper function does the following:
1. Writes exception to "error.log" file
2. Prints exception
3. Calls cef.[QuitMessageLoop](../api/cefpython.md#quitmessageloop)
4. Calls cef.[Shutdown](../api/cefpython.md#shutdown)
5. Calls [os._exit(1)](https://docs.python.org/2/library/os.html#os._exit) -
   which exits the process with status 1, without calling
   cleanup handlers, flushing stdio buffers, etc.

If you would like to modify `ExceptHook` behavior, see its source code
in src/[helpers.pyx](../src/helpers.pyx) file.


## Settings

CEF settings are provided in multiple ways. There are global
[application settings](../api/ApplicationSettings.md#application-settings)
and [command line switches](../api/CommandLineSwitches.md#command-line-switches)
that can be passed to cef.[Initialize](../api/cefpython.md#initialize).
There are also [browser settings](../api/BrowserSettings.md#browser-settings)
that can be passed to cef.[CreateBrowserSync](../api/cefpython.md#createbrowsersync).
Finally there are Chromium preferences, but these are not yet
implemented. See below for details on each of these settings.

**Application settings**

A dict of [application settings](../api/ApplicationSettings.md#application-settings)
can be passed to cef.[Initialize](../api/cefpython.md#initialize).
Here are some settings worth noting:
- [cache_path](../api/ApplicationSettings.md#cache_path) - set
  a directory path so that web cache data is persisted, otherwise
  an in-memory cache is used. Cookies and HTML 5 databases such
  as local storage will only persist if this option is set.
- [context_menu](../api/ApplicationSettings.md#context_menu) -
  customize context menu
- [locale](../api/ApplicationSettings.md#locale) - set language
  for localized resources
- [product_version](../api/ApplicationSettings.md#product_version) -
  set the product portion of the default User-Agent string.
  If user_agent option (below) is used then product_version will
  be ignored.
- [user_agent](../api/ApplicationSettings.md#user_agent) - set
  value that will be returned as the User-Agent HTTP header
  and js navigator.userAgent

To enable debugging set these settings:
```python
settings = {
    "debug": True,
    "log_severity": cef.LOGSEVERITY_INFO,
    "log_file": "debug.log",
}
cef.Initialize(settings=settings)
```

Alternatively you can pass `--debug` flag on the command line
and these settings will be set automatically.

**Browser settings**

A dict of [browser settings](../api/BrowserSettings.md#browser-settings)
can be passed to cef.[CreateBrowserSync](../api/cefpython.md#createbrowsersync).

**Command line switches**

A dict of [command line switches](../api/CommandLineSwitches.md)
can be passed to cef.[Initialize](../api/cefpython.md#initialize).
Examples switches:
- "enable-media-stream" - to enable media (WebRTC audio/video) streaming
- "proxy-server" - to set proxy server
- "disable-gpu" - use only CPU software rendering

Note that when setting switch that doesn't accept value then
must pass an empty string as value. Example code:

```python
switches = {
    "enable-media-stream": "",
    "proxy-server": "socks5://127.0.0.1:8888",
    "disable-gpu": "",
}
cef.Initialize(switches=switches)
```


**Chromium preferences**

There are lots of more settings that can be set using Chromium
preferences (and even changed during runtime), however this API
wasn't yet exposed to CEF Python, see [Issue #244](../../../issues/244)
for details.


## Change user agent string

There are two options in [application settings](../api/ApplicationSettings.md#application-settings)
for changing User-Agent string: [product_version](../api/ApplicationSettings.md#product_version)
and [user_agent](../api/ApplicationSettings.md#user_agent).

The "product_version" sets the product portion of the default
User-Agent string. If "user_agent" option is used then
"product_version" will be ignored. For example if you set
"product_version" to "MyProduct/10.00" then User-Agent will
be:

```text
Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)
MyProduct/10.00 Safari/537.36
```

To change the whole user agent string use the "user_agent"
option. For example set it to "MyAgent/20.00 MyProduct/10.00"
and both User-Agent HTTP header and js navigator.userAgent will be:

```text
MyAgent/20.00 MyProduct/10.00
```

Uncomment appropriate lines in [tutorial.py](../examples/tutorial.py)
example to see the effect:

```Python
# To change user agent use either "product_version"
# or "user_agent" options. Explained in Tutorial in
# "Change user agent string" section.
settings = {
    # "product_version": "MyProduct/10.00",
    # "user_agent": "MyAgent/20.00 MyProduct/10.00",
}
cef.Initialize(settings=settings)
```


## Client handlers

In CEF [client handlers](../api/API-categories.md#client-handlers-interfaces)
provide a way to be notified of Chromium events. There are client
handlers like DisplayHandler, LoadHandler, RequestHandler, etc.
These handlers are class interfaces for which you provide
implementation. We will refer to the methods of these objects
as "callbacks". You can set a client handler by calling
Browser.[SetClientHandler](../api/Browser.md#setclienthandler).
You are not required to implement whole interface, you can implement
only some callbacks. Some handlers due to cefpython limitations
have callbacks that can only be set globally by calling
cef.[SetGlobalClientCallback](../api/cefpython.md#setglobalclientcallback).
In API reference such global client callbacks are marked with an
underscore in its name.

The [tutorial.py](../examples/tutorial.py) example shows how to
implement client handlers like [DisplayHandler](../api/DisplayHandler.md)
and [LoadHandler](../api/LoadHandler.md). It also shows how to
implement a global client callback LifespanHandler.[_OnAfterCreated](../api/LifespanHandler.md#_onaftercreated). Here is part of its
source code:

```python
set_client_handlers(browser)
...
def set_client_handlers(browser):
    client_handlers = [LoadHandler(), DisplayHandler()]
    for handler in client_handlers:
        browser.SetClientHandler(handler)
...
class LoadHandler(object):
    def OnLoadingStateChange(self, browser, is_loading, **_):
        # This callback is called twice, once when loading starts
        # (is_loading=True) and second time when loading ends
        # (is_loading=False).
        if not is_loading:
            # Loading is complete. DOM is ready.
            js_print(browser, "Python", "OnLoadingStateChange",
                     "Loading is complete")
```


## Javascript integration

Python code is running in the main process (the Browser process),
while Javascript is running in the Renderer sub-process. Communication
between Python and Javascript is possible either using inter-process
asynchronous messaging or through http requests (both sync and
async possible).

**Asynchronous inter-process messaging**

Python and Javascript can communicate using inter-process
messaging:
 - Use the [JavascriptBindings](../api/JavascriptBindings.md)
   class methods to to expose Python functions, objects and properties
   to Javascript: [SetFunction](../api/JavascriptBindings.md#setfunction),
   [SetObject](../api/JavascriptBindings.md#setobject)
   and [SetProperty](../api/JavascriptBindings.md#setproperty)
 - To initiate communication from the Python side call
   Browser object methods: [ExecuteJavascript](../api/Browser.md#executejavascript)
   or [ExecuteFunction](../api/Browser.md#executefunction).
   Frame object also has the same methods.
 - To initiate communication from the Javascript side first
   you have to bind Python functions/objects using the
   JavascriptBindings class mentioned earlier. Then you call
   these functions/objects.
 - You can pass Javascript callbacks to Python. Just pass a
   javascript function as an argument when calling Python
   function/object. On the Python side that javascript function
   will be converted to [JavascriptCallback](../api/JavascriptCallback.md)
   object. Execute the [Call](../api/JavascriptCallback.md#call)
   method on it to call the javascript function asynchronously.
 - You can pass Python callbacks to Javascript, however you
   can do so only after the communication was initiated from
   the Javascript side and a javascript callback was passed.
   When executing JavascriptCallback.[Call](../api/JavascriptCallback.md#call)
   method you can pass Python callbacks to Javascript. In
   javascript these Python callbacks will act as native
   javascript functions, so call them as usual.
 - Note that when executing Browser.[ExecuteFunction](../api/Browser.md#executefunction) method you cannot pass Python functions
   nor objects here. Such feature is not yet supported. You can
   however pass Python functions when executing javascript
   callbacks mentioned earlier.

In [tutorial.py](../examples/tutorial.py) example you will find
example usage of javascript bindings, javascript callbacks
and python callbacks. Here is part of its source code:

```python
set_javascript_bindings(browser)
...
def set_javascript_bindings(browser):
    bindings = cef.JavascriptBindings(
            bindToFrames=False, bindToPopups=False)
    bindings.SetFunction("html_to_data_uri", html_to_data_uri)
    browser.SetJavascriptBindings(bindings)
...
def html_to_data_uri(html, js_callback=None):
    # This function is called in two ways:
    # 1. From Python: in this case value is returned
    # 2. From Javascript: in this case value cannot be returned because
    #    inter-process messaging is asynchronous, so must return value
    #    by calling js_callback.
    html = html.encode("utf-8", "replace")
    b64 = base64.b64encode(html).decode("utf-8", "replace")
    ret = "data:text/html;base64,{data}".format(data=b64)
    if js_callback:
        js_print(js_callback.GetFrame().GetBrowser(),
                 "Python", "html_to_data_uri",
                 "Called from Javascript. Will call Javascript callback now.")
        js_callback.Call(ret)
    else:
        return ret
...
<script>
function js_callback_1(ret) {
    js_print("Javascript", "html_to_data_uri", ret);
}
html_to_data_uri("test", js_callback_1);
</script>
```

**Communication using http requests**

Python and Javascript can also communicate using http requests
by running an internal web-server. See for example [SimpleHTTPServer](https://docs.python.org/2/library/simplehttpserver.html)
in Python docs. In upstream CEF there is available a fast built-in
web server and [Issue #445](../../../issues/445) is to expose its API.

With http requests it is possible for synchronous
communication from Javascript to Python by performing
synchronous AJAX requests.

To initiate communication from the Python side call
Browser object methods: [ExecuteJavascript](../api/Browser.md#executejavascript)
or [ExecuteFunction](../api/Browser.md#executefunction).
Frame object also has the same methods.

You can also serve requests directly in CEF using for example
[ResourceHandler](../api/ResourceHandler.md) object. You can find
an example usage of this object in one of examples listed in
the [README-examples.md](../examples/README-examples.md) file.

On a side note, upstream CEF also supports custom scheme handlers,
however these APIs were not yet exposed to CEF Python.


## Javascript exceptions and Python exceptions

When a Python function is invoked from Javascript and it fails,
a Python exception will be thrown. When Python executes a Javascript
callback and it fails, a Javascript exception will be thrown.

To see Javascript exceptions open Developer Tools
window using mouse context menu and switch to Console tab.

There are multiple ways to intercept javascript exceptions programmaticaly
in CEF:

1. In Javascript you can register "window.onerror" event to
   catch all Javascript exceptions
2. In Python you can intercept Javascript exceptions using
   DisplayHandler.[OnConsoleMessage](../api/DisplayHandler.md#onconsolemessage)
3. In upstream CEF there is also CefRenderProcessHandler::OnUncaughtException
   callback for catching Javascript exceptions, however this
   wasn't yet exposed to CEF Python


## Plugins and Flash support

Latest CEF supports only [PPAPI plugins](https://www.chromium.org/developers/design-documents/pepper-plugin-implementation).
NPAPI plugins are no more supported.

Instructions for enabling Flash support are available in [Issue #235](../../../issues/235) ("Flash support in CEF 51+").

For the old CEF Python v31 release instructions for enabling Flash
support are available on Wiki pages.


## Message loop

Message loop is a programming construct that waits for and
dispatches events or messages in a program. All desktop GUI
programs must run some kind of message loop. The hello_world.py
example doesn't depend on any third party GUI framework and thus
can run CEF message loop directly by calling cef.MessageLoop().
However in other examples that embed CEF browser with GUI frameworks
such as Qt/wxPython/Tkinter you can't call cef.MessageLoop(), because
these frameworks run a message loop of its own. For such cases CEF
provides cef.MessageLoopWork() which is for integrating CEF message
loop into existing application message loop. Usually
cef.MessageLoopWork() is called in a 10ms timer.

**Performance**

Calling cef.MessageLoopWork() in a timer is not the best performant
way to run CEF message loop, also there are known bugs on some
platforms when calling message loop work in a timer. There are two
options to increase performance depending on platform. On Windows
use a multi-threaded message loop for best performance. On Mac use
an external message pump for best performance.

**Windows: multi-threaded message loop**

On Windows for best performance a multi-threaded message loop should
be used instead of cef.MessageLoopWork() or external message pump. To do
so, set ApplicationSettings.[multi_threaded_message_loop](../api/ApplicationSettings.md#multi_threaded_message_loop)
to True and run a native message loop in your app. Don't call CEF's
message loop. Create browser using `cef.PostTask(cef.TID_UI, cef.CreateBrowserSync, ...)`.
Note that when using multi-threaded message loop, CEF's UI thread
is no more application's main thread, and that makes it a bit harder
to correctly use CEF API. API docs explain on which threads a function
may be called and in case of handlers' callbacks (and other interfaces)
it is stated on which thread a callback will be called. See also
[Issue #133](../../../issues/133).

**Mac: external message pump**

CEF provides ApplicationSettings.[external_message_pump](../api/ApplicationSettings.md#external_message_pump)
option for running an external message pump that you should use for
best performance and to get rid of some bugs that appear when using
cef.MessageLoopWork() in a timer.

This option is currently marked experimental as it wasn't yet fully
tested. This option should work good on Mac - in upstream CEF it was
tested mainly on Mac. If you've successfully used this option on Mac
please let us know on the Forum.

**Linux**

External message pump option is not recommended to use on Linux,
as during testing it actually made app x2 slower - it's a bug in
upstream CEF. See [Issue #246](../../../issues/246) for more details.


## Off-screen rendering

Off-screen rendering, in short OSR, also known as windowless
rendering, is a method of rendering pages into a memory buffer
without creating an actual visible window. This method of
rendering has its uses, some pluses and some minuses. Its main
use is so that web page rendering can be integrated into apps
that have its own rendering systems and they can draw web browser
contents only if they are provided a pixel buffer to draw. CEF Python
provides a few examples of integrating CEF off-screen rendering
with frameworks such as Kivy, Panda3D and Pygame/PyOpenGl.

In this tutorial it will be discussed [screenshot.py](../examples/screenshot.py)
example which is a very basic example of off-screen rendering.
This example creates a screenshot of a web page with viewport
size set to 800px width and 5000px height which is an equivalent
of scrolling down page multiple times, but you get all this in
one single screenshot.

Before running this script you have to install Pillow image
library (PIL module):

```text
pip install Pillow
```

This example accepts optional arguments so that you can change
url and viewport size. Example usage:

```text
python screenshot.py
python screenshot.py https://github.com/cztomczak/cefpython 1024 5000
python screenshot.py https://www.google.com/ncr 1024 768
```

Let's discuss code in this example.

To be able to use off-screen rendering mode in CEF you have to set
[windowless_rendering_enabled](../api/ApplicationSettings.md#windowless_rendering_enabled)
option to True, eg.:

```Python
cef.Initialize(settings={"windowless_rendering_enabled": True})
```

Do not enable this value if the application does not use off-screen
rendering as it may reduce rendering performance on some systems.

Another thing that distincts windowed rendering from off-screen
rendering is that when creating browser you have to call SetAsOffscreen
method on the WindowInfo object. Code from the example:

```Python
parent_window_handle = 0
window_info = cef.WindowInfo()
window_info.SetAsOffscreen(parent_window_handle)
browser = cef.CreateBrowserSync(window_info=window_info,
                                url=URL)
```

Also after creating browser it is required to let CEF know that
viewport size is available and that OnPaint callback may be called
(this callback will be explained in a moment) by calling
WasResized method:

```Python
browser.WasResized()
```

Off-screen rendering requires implementing [RenderHandler](../api/RenderHandler.md#renderhandler-interface)
which is one of client handlers and how to use them was
explained earlier in the tutorial in the [Client handlers](#client-handlers)
section. For basic off-screen rendering it is enough to
implement only two methods: [GetViewRect](../api/RenderHandler.md#getviewrect)
and [OnPaint](../api/RenderHandler.md#onpaint). In the GetViewRect
callback information on viewport size will be provided to CEF:

```Python
def GetViewRect(self, rect_out, **_):
    rect_out.extend([0, 0, VIEWPORT_SIZE[0], VIEWPORT_SIZE[1]])
    return True
```

In this callback viewport size is returned via |rect_out| which
is of type "list" and thus is passed by reference. Additionally
a True value is returned by function to notify CEF that rectangle
was provided.

In the OnPaint callback CEF provides a [PaintBufer](../api/PaintBuffer.md#paintbuffer-object) object, which is a pixel buffer of the
browser view. This object has [GetIntPointer](../api/PaintBuffer.md#getintpointer)
and [GetString](../api/PaintBuffer.md#getstring) methods. In the
example the latter method is used which returns bytes. The method
name is a bit confusing for Python 3 users, but in Python 2 bytes
were strings and thus the name. Here is the code:

```Python
def OnPaint(self, browser, element_type, paint_buffer, **_):
    if element_type == cef.PET_VIEW:
        buffer_string = paint_buffer.GetString(mode="rgba",
                                               origin="top-left")
        browser.SetUserData("OnPaint.buffer_string", buffer_string)
```

The |element_type| argument can be either of cef.PET_VIEW
(main view) or cef.PET_POPUP (for drawing popup widgets like
`<select>` element). You can see a call to [SetUserData](../api/Browser.md#setuserdata)
which is a helper method for storing custom data associated with
browser. This data is stored for later use when page completes
loading. During loading of a page there are many calls to OnPaint
callback and it is not yet known which call is the last when
loading completes and thus image buffer is stored for later use.

The screenshot example also implements another handler named
[LoadHanadler](../api/LoadHandler.md#loadhandler-interface)
and two of its callbacks: [OnLoadingStateChange](../api/LoadHandler.md#onloadingstatechange)
and [OnLoadError](../api/LoadHandler.md#onloaderror). The
OnLoadingStateChange callbacks notifies when web page loading
completes and OnLoadError callback notifies if loading of
page failed. When loading succeeds a function save_screenshot()
is called which retrieves image buffer that was earlier stored
in the browser object and then uses Pillow image library to save
it as a PNG image.

The screenshot example could be further extended, so that it
makes a screenshot of the whole page no matter how long it is.
Detecting page length could be done in Javascript and then
communicated back with Python using [Javascript bindings](#javscript-integration).
After whole page length is known a call to browser.WasResized()
should be done so that GetViewRect and OnPaint are called again.

At the end, it is worth noting that there is yet an another
option for off-screen rendering named [windowless_frame_rate](../api/BrowserSettings.md#windowless_frame_rate)
(can be passed to [CreateBrowserSync](../api/cefpython.md#createbrowsersync)),
but is not used by this example. It sets the maximum rate
in frames per second (fps) that OnPaint callback will be called

Currently CEF requires a window manager on Linux even in off-screen
rendering mode. On systems without screen or any input you can use
something like [Xvfb](https://en.wikipedia.org/wiki/Xvfb) which
performs all graphical operations in memory without showing any
screen output. Pure headless mode is currently not supported in
CEF, but that may change in the future. CEF currently depends on
X11 window manager, but there are plans to support alternative
window managers by adding Ozone support - [upstream issue #1989](https://bitbucket.org/chromiumembedded/cef/issues/1989/linux-add-ozone-support-as-an-alternative).

The screenshot.py example is just a basic showcase of off-screen
rendering features. That screenshot feature should also be possible
to implement using windowed rendering using a normal GUI window,
but a hidden one with height set to some very big value that it
wouldn't fit on screen. You could then render contents of this
window to an image. For example in Qt you can do this by using
QImage/QPainter classes along with a call to QWidget.render().

## Build executable

Currently there is available [PyInstaller example](../examples/pyinstaller/README-pyinstaller.md)
for building executable, by default it packages the wxpython.py example.

There are many more Python packagers available, however no
official examples are provided for these. See the following
issues in the tracker for all available packagers:

* cx_Freeze - see [Issue #338](../../../issues/338)
* Cython - see [Issue #407](../../../issues/407)
* py2exe - see [Issue #35](../../../issues/35)
* py2app - see [Issue #337](../../../issues/337)
* Nuitka - see [Issue #396](../../../issues/396)
* Pyinstaller - see [Issue #135](../../../issues/135)


If you have any problems building executable ask on the [Forum](https://groups.google.com/group/cefpython).

**Files in the cefpython3 package**

The cefpython3 package has the following components:
1. The CEF Python modules (cefpython_pyxx.pyd on Windows,
   cefpython_pyxx.so on Linux/Mac)
2. The CEF dynamic library (libcef.dll on Windows, libcef.so on Linux,
   “Chromium Embedded Framework.framework” on OS X).
3. Other dynamic libraries CEF depends on (libEGL, libGLES,
   d3dcompiler, etc.) and some optional (widevinecdmadapter, etc.)
4. Support files (*.pak, *.dat, *.bin, etc).

See README.txt in the cefpython3 package which provides
extended details about all CEF binary files.


## Support and documentation

For support and documentation see the [Support](../README.md#support)
section in README.
