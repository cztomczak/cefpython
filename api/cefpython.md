[API categories](API-categories.md) | [API index](API-index.md)


# cefpython

Functions in the cefpython module.


Table of contents:
* [Functions](#functions)
  * [CreateBrowser](#createbrowser)
  * [CreateBrowserSync](#createbrowsersync)
  * [ExceptHook](#excepthook)
  * [GetAppSetting](#getappsetting)
  * [GetAppPath](#getapppath)
  * [GetBrowserByWindowHandle](#getbrowserbywindowhandle)
  * [GetCommandLineSwitch](#getcommandlineswitch)
  * [GetGlobalClientCallback](#getglobalclientcallback)
  * [GetModuleDirectory](#getmoduledirectory)
  * [Initialize](#initialize)
  * [IsThread](#isthread)
  * [MessageLoop](#messageloop)
  * [MessageLoopWork](#messageloopwork)
  * [PostTask](#posttask)
  * [QuitMessageLoop](#quitmessageloop)
  * [SetGlobalClientCallback](#setglobalclientcallback)
  * [SetOsModalLoop](#setosmodalloop)
  * [Shutdown](#shutdown)


## Functions


### CreateBrowser

Create browser asynchronously (does not return Browser object).
See `CreateBrowserSync()` for params list.

NOTE: currently this is just an alias and actually creates browser
synchronously. The async call to CefCreateBrowser is yet TODO.


### CreateBrowserSync

| Parameter | Type |
| --- | --- |
| window_info | [WindowInfo](WindowInfo.md) |
| [settings](BrowserSettings.md) | [BrowserSettings](BrowserSettings.md) |
| url | string |
| request_context | void |
| __Return__ | [Browser](Browser.md) |

This function should only be called on the UI thread. The 'request_context' parameter is not yet implemented. You must first create a window and initialize 'window_info' by calling WindowInfo.SetAsChild().

After the call to CreateBrowserSync() the page is not yet loaded, if you want your next lines of code to do some stuff on the webpage you will have to implement [LoadHandler](LoadHandler.md).OnLoadEnd() callback, see example below:

```python
def OnLoadEnd(browser, frame, httpCode):
    if frame == browser.GetMainFrame():
        print("Finished loading main frame: %s (http code = %d)"
              % (frame.GetUrl(), httpCode))

browser = cefpython.CreateBrowserSync(windowInfo, settings, url)
browser.SetClientCallback("OnLoadEnd", OnLoadEnd)
```


### ExceptHook

| Parameter | Type |
| --- | --- |
| excType | - |
| excValue | - |
| traceObject | - |
| __Return__ | string |

Global except hook to exit app cleanly on error. CEF has a multiprocess
architecture and when exiting you need to close all processes (main Browser
process, Renderer process, GPU process, etc.) by calling Shutdown().
This hook does the following: in case of exception write it to
the "error.log" file, display it to the console, shutdown CEF
and exit application immediately by ignoring "finally" (_exit()).

If you would like to implement a custom hook take a look at the
source code of ExceptHook in the cefpython/src/helpers.pyx file.


### GetAppSetting

| Parameter | Type |
| --- | --- |
| key | string |
| __Return__ | object |

Returns [ApplicationSettings](ApplicationSettings.md) option that was passed to Initialize(). Returns None if key is not found.


### GetAppPath

| | |
| --- | --- |
| __Return__ | string |

Get path to where application resides.


### GetBrowserByWindowHandle

| Parameter | Type |
| --- | --- |
| windowHandle | long |
| __Return__ | void |

Get browser by outer or inner window handle. An outer window handle is the one that was passed to CreateBrowserSync(). An inner window handle is a CEF internal window handle.


### GetCommandLineSwitch

| Parameter | Type |
| --- | --- |
| key | string |
| __Return__ | object |

Returns the [CommandLineSwitches](CommandLineSwitches.md) switch that was passed to Initialize(). Returns None if key is not found.


### GetGlobalClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | object |

Returns a global client callback that was set using SetGlobalClientCallback(). Returns None if callback was not set.


### GetModuleDirectory

| | |
| --- | --- |
| __Return__ | string |

Get the cefpython module directory. This method is useful to get full path to CEF binaries. This is required when setting [ApplicationSettings](ApplicationSettings.md) options like: 'browser_subprocess_path', 'resources_dir_pat' and 'locales_dir_path'.


### Initialize

| Parameter | Type |
| --- | --- |
| [ApplicationSettings](ApplicationSettings.md)=None | dict |
| [CommandLineSwitches](CommandLineSwitches.md)=None | dict |
| __Return__ | bool |

This function should be called on the main application thread (UI thread) to initialize CEF when the application is started. A call to Initialize() must have a corresponding call to Shutdown() so that CEF exits cleanly. Otherwise when application closes data (eg. storage, cookies) might not be saved to disk or the process might freeze (experienced on Windows XP).


### IsThread

| Parameter | Type |
| --- | --- |
| threadID | int |
| __Return__ | bool |

Returns true if called on the specified thread.

CEF maintains multiple internal threads that are used for handling different types of tasks. The UI thread creates the browser window and is used for all interaction with the webkit rendering engine and V8 Javascript engine. The UI thread will be the same as the main application thread if CefInitialize() is called with an [ApplicationSettings](ApplicationSettings.md) 'multi_threaded_message_loop' option set to false. The IO thread is used for handling schema and network requests. The FILE thread is used for the application cache and other miscellaneous activities.

List of threads in the Browser process. These are constants defined in the cefpython module:

* TID_UI: The main thread in the browser. This will be the same as the main application thread if cefpython.Initialize() is called with a ApplicationSettings.multi_threaded_message_loop value of false.
* TID_DB: Used to interact with the database.
* TID_FILE: Used to interact with the file system.
* TID_FILE_USER_BLOCKING: Used for file system operations that block user interactions. Responsiveness of this thread affects users.
* TID_PROCESS_LAUNCHER: Used to launch and terminate browser processes.
* TID_CACHE: Used to handle slow HTTP cache operations.
* TID_IO: Used to process IPC and network messages.

List of threads in the Renderer process:
* TID_RENDERER: The main thread in the renderer. Used for all webkit and V8 interaction.


### MessageLoop

| | |
| --- | --- |
| __Return__ | void |

Run the CEF message loop. Use this function instead of an application-
provided message loop to get the best balance between performance and CPU usage. This function should only be called on the main application thread (UI thread) and only if cefpython.Initialize() is called with a
[ApplicationSettings](ApplicationSettings.md).multi_threaded_message_loop value of false. This function will block until a quit message is received by the system.


### MessageLoopWork

| | |
| --- | --- |
| __Return__ | void |

Description from upstream CEF:

> Perform a single iteration of CEF message loop processing. This function is
> provided for cases where the CEF message loop must be integrated into an
> existing application message loop. Use of this function is not recommended
> for most users; use either the CefRunMessageLoop() function or
> CefSettings.multi_threaded_message_loop if possible. When using this function
> care must be taken to balance performance against excessive CPU usage. It is
> recommended to enable the CefSettings.external_message_pump option when using
> this function so that CefBrowserProcessHandler::OnScheduleMessagePumpWork()
> callbacks can facilitate the scheduling process. This function should only be
> called on the main application thread and only if CefInitialize() is called
> with a CefSettings.multi_threaded_message_loop value of false. This function
> will not block.

Alternatively you could create a periodic timer (with 10 ms interval) that calls
cefpython.MessageLoopWork().

MessageLoopWork() is not tested on OS X and there are known issues - according to
[this post](http://www.magpcss.org/ceforum/viewtopic.php?p=27124#p27124) by
Marshall.


### PostTask

| Parameter | Type |
| --- | --- |
| threadId | int |
| func | object |
| ... | *args |
| __Return__ | void |

Post a task for execution on the thread associated with this task runner. Execution will occur asynchronously. Only Browser process threads are allowed, see IsThread() for a list of available threads and their descriptions.

An example usage is in the wxpython.py example on Windows, in implementation of LifespanHandler.OnBeforePopup().


### QuitMessageLoop

| | |
| --- | --- |
| __Return__ | void |

Quit the CEF message loop that was started by calling cefpython.MessageLoop(). This function should only be called on the main application thread (UI thread) and only if cefpython.MessageLoop() was used.


### SetGlobalClientCallback

| Parameter | Type |
| --- | --- |
| name | string |
| callback | function |
| __Return__ | void |

Current CEF Python implementation is limited in handling callbacks that occur during browser creation, in such cases a callback set with Browser.SetClientCallback() or Browser.SetClientHandler() won't work, as this methods can be called only after browser was created. An example of such callback is LifespanHandler.OnAfterCreated().

Some client callbacks are not associated with any browser. In such case use this function instead of the SetClientCallback() and SetClientHandler() [Browser](Browser.md) methods. An example of such callback is OnCertificateError() in [RequestHandler](RequestHandler.md).

Example of using SetGlobalClientCallback() is provided in the wxpython.py example.


### SetOsModalLoop

| Parameter | Type |
| --- | --- |
| modalLoop | bool |
| __Return__ | void |

Set to true before calling Windows APIs like 'TrackPopupMenu' that enter a
modal message loop. Set to false after exiting the modal message loop.


### Shutdown

| | |
| --- | --- |
| __Return__ | void |

This function should be called on the main application thread (UI thread) to shut down CEF before the application exits.

You must call this function so that CEF shuts down cleanly. Remember also to delete all CEF browsers references for the browsers to shut down cleanly. For an example see the wxpython.py example MainFrame.OnClose().
